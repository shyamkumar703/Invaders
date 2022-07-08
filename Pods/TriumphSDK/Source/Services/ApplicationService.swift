// Copyright © TriumphSDK. All rights reserved.
// Documented April 11, 2022 by Shyam Kumar

import UIKit
import Foundation
import TriumphCommon

// swiftlint:disable line_length
/*
 ApplicationService contains all of the swizzling code we use to customize handling of AppDelegate methods for consumers of the SDK.
 Swizzling is a way for us to change the implementation of an EXISTING selector at runtime.  With swizzling, we can add to or completely replace the implementation of any selector at runtime, provided that the consumer calls TriumphSDK.configure(), which subsequently calls the setup() method in this file.
 The setup() method below has two main tasks:
    1) Retrieve the selectors we want to edit (namely applicationDidFinishLaunchingWithOptions, applicationDidEnterBackground, and notificationCenterDidReceiveResponse) using class_getInstanceMethod
    2) Replace the selectors with new implementations (newApplicationDidFinishLaunchingWithOptions, newUserNotificationCenter, newApplicationDidEnterBackground) using method_exchangeImplementations
 */

protocol ApplicationService {
    func setup()
}

final class ApplicationServiceImplementation: ApplicationService {
    private typealias AppDelegate = UIResponder & UIApplicationDelegate
    private typealias ApplicationDidFinishLaunchingWithOptions = @convention(c) (
        Any, Selector, UIApplication, [UIApplication.LaunchOptionsKey: Any]) -> Bool

    private var targetClassInstance: AppDelegate?
    private var didFinishLaunchingSelector: Selector?
    private var didFinishLaunchingWithOptions: ApplicationDidFinishLaunchingWithOptions?
    
    /*
     We need this singleton because the allocation/deallocation behavior of swizzling is unknown. The class variables above
     are different in memory than normal variables, as we are working directly with memory addresses here and things can be overwritten
     quite quickly. The current safe and working way to make sure that this service works as intended is with this singleton.
     */
    private static var shared = ApplicationServiceImplementation()
    
    /// Set up AppDelegate swizzling
    func setup() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        ApplicationServiceImplementation.shared.targetClassInstance = appDelegate
        ApplicationServiceImplementation.shared.didFinishLaunchingSelector = #selector(appDelegate.application(_:didFinishLaunchingWithOptions:))

        if let selector = ApplicationServiceImplementation.shared.didFinishLaunchingSelector {
            let originalImplementation = class_getMethodImplementation(type(of: appDelegate), selector)
            ApplicationServiceImplementation.shared.didFinishLaunchingWithOptions = unsafeBitCast(
                originalImplementation,
                to: ApplicationDidFinishLaunchingWithOptions.self
            )
        }

        // get original UNN selector and swizzle
        if let notificationDelegate = UNUserNotificationCenter.current().delegate {
            let originMethod = class_getInstanceMethod(
                type(of: notificationDelegate),
                #selector(notificationDelegate.userNotificationCenter(_:didReceive:))
            )
            let swizzleSelector = #selector(newUserNotificationCenter(_:didReceive:withCompletionHandler:))
            let swizzleMethod = class_getInstanceMethod(ApplicationServiceImplementation.self, swizzleSelector)
            
            if let originMethod = originMethod, let swizzleMethod = swizzleMethod {
                method_exchangeImplementations(originMethod, swizzleMethod)
            }
        }
        
        // swizzle didFinishLaunching
        if let selector = ApplicationServiceImplementation.shared.didFinishLaunchingSelector {
            let newSwizzleSelector = #selector(newApplicationDidFinishLaunchingWithOptions(_:didFinishLaunchingWithOptions:))
            let newOriginalMethod = class_getInstanceMethod(type(of: appDelegate), selector)
            let newSwizzleMethod = class_getInstanceMethod(ApplicationServiceImplementation.self, newSwizzleSelector)
            if let newOriginalMethod = newOriginalMethod,
               let newSwizzleMethod = newSwizzleMethod {
                method_exchangeImplementations(newOriginalMethod, newSwizzleMethod)
            }
        }
        
        // swizzle didEnterBackground
        let selector = #selector(appDelegate.applicationDidEnterBackground(_:))
        let newSwizzleSelector = #selector(newApplicationDidEnterBackground(_:))
        let newOriginalMethod = class_getInstanceMethod(type(of: appDelegate), selector)
        let newSwizzleMethod = class_getInstanceMethod(ApplicationServiceImplementation.self, newSwizzleSelector)
        if let newOriginalMethod = newOriginalMethod,
           let newSwizzleMethod = newSwizzleMethod {
            method_exchangeImplementations(newOriginalMethod, newSwizzleMethod)
        }
        
        // swizzle willEnterForeground
        let oldWillEnterForegroundSelector = #selector(appDelegate.applicationWillEnterForeground(_:))
        let newWillEnterForegroundSelector = #selector(newApplicationWillEnterForeground(_:))
        let newOriginalWillEnterForegroundMethod = class_getInstanceMethod(type(of: appDelegate), oldWillEnterForegroundSelector)
        let newSwizzledWillEnterForegroundMethod = class_getInstanceMethod(
            ApplicationServiceImplementation.self,
            newWillEnterForegroundSelector
        )
        if let newOriginalWillEnterForegroundMethod = newOriginalWillEnterForegroundMethod,
           let newSwizzledWillEnterForegroundMethod = newSwizzledWillEnterForegroundMethod {
            method_exchangeImplementations(newOriginalWillEnterForegroundMethod, newSwizzledWillEnterForegroundMethod)
        }
    }
    
    /// Every time the app enters the background, we want to invalidate the current analytics task ID
    @objc func newApplicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: .invalidateTask, object: nil)
    }
    
    /// Handling for notifications arriving when the app is backgrounded
    @objc func newUserNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        TriumphSDK.dependencies.logger.log(userInfo)

        if let tournamentId = userInfo["tournamentId"] as? String {
            Task { @MainActor in
                let view = UIView()
                view.backgroundColor = .clear
                UIApplication.shared.delegate?.window??.addSubview(view)
                guard let gameHistoryModel = await TriumphSDK.dependencies.session.getGameHistory(with: tournamentId) else {
                    completionHandler()
                    return
                }
                if TriumphSDK.isControllerPresented {
                    TriumphSDK.dependencies.location.checkEligibility { _ in
                        guard TriumphSDK.dependencies.location.isEligable == true else { return }
                        // Not using [weak self] here because we are not reading from self
                        Task {
                            let user = await TriumphSDK.dependencies.sharedSession.user
                            let lockdown = await TriumphSDK.dependencies.sharedSession.lockdown
                            if user?.banned == false && lockdown?.isLockedDown == false {
                                TriumphSDK.showGameOver(with: gameHistoryModel)
                                completionHandler()
                                return
                            } else {
                                if lockdown?.isLockedDown == true {
                                    TriumphSDK.showLockdown()
                                }
                            }
                        }
                    }
                } else {
                    await TriumphSDK.presentTriumphViewController(with: gameHistoryModel)
                    // await TriumphSDK.coordinator?.start(with: gameHistoryModel)
                }
                view.removeFromSuperview()
            }
        } else if let _ = userInfo["type"] as? String {
            Task { @MainActor in
                TriumphSDK.presentTriumphViewController(shouldShowReferralCompletedMessage: true)
                completionHandler()
            }
        }
    }
    
    /// Handling for notifications arriving when the app is fully quit
    @objc func newApplicationDidFinishLaunchingWithOptions(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Call original implementation
        if let targetClassInstance = ApplicationServiceImplementation.shared.targetClassInstance,
           let didFinishLaunchingSelector = ApplicationServiceImplementation.shared.didFinishLaunchingSelector,
           let didFinishLaunchingWithOptions = ApplicationServiceImplementation.shared.didFinishLaunchingWithOptions {
            if let options = launchOptions {
                _ = didFinishLaunchingWithOptions(targetClassInstance, didFinishLaunchingSelector, application, options)
            } else {
                _ = didFinishLaunchingWithOptions(targetClassInstance, didFinishLaunchingSelector, application, [:])
            }
        }
        
        // Store current minimum supported version number
        TriumphSDK.dependencies.localStorage.updateLastMinimumSupportedVersionNumber(UIApplication.minimumSupportedVersionNumber)
        
//        // Handle tournament finished notification
        if let launchOptions = launchOptions,
           let data = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any],
           let tournamentId = data["tournamentId"] as? String {
            Task { @MainActor in
                let view = UIView()
                view.backgroundColor = .clear
                let progressView = ProgressHUD()
                progressView.center = view.center
                view.addSubview(progressView)
                progressView.start()
                UIApplication.shared.delegate?.window??.addSubview(view)
                if TriumphSDK.isControllerPresented {
                    Task { [weak self] in
                        guard let gameHistoryModel = await TriumphSDK.dependencies.session.getGameHistory(with: tournamentId) else { return }
                        await TriumphSDK.presentTriumphViewController(with: gameHistoryModel)
                    }
                }
                progressView.stop()
                view.removeFromSuperview()
            }
        } else if let launchOptions = launchOptions,
            let data = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any],
            let _ = data["type"] as? String {
            Task { @MainActor in
                TriumphSDK.presentTriumphViewController(shouldShowReferralCompletedMessage: true)
            }
        }

        return true
    }
    
    @objc func newApplicationWillEnterForeground(_ application: UIApplication) {
        /*
         If app is in foreground and SDK is up after update, we want to dismiss SDK
         */
        let currentMinimumSupportedVersionNumber = UIApplication.minimumSupportedVersionNumber
        if let storedMinimumSupportedVersionNumber = TriumphSDK.dependencies.localStorage.readLastMinimumSupportedVersionNumber() {
            if currentMinimumSupportedVersionNumber != storedMinimumSupportedVersionNumber {
                TriumphSDK.dismissController()
            }
        }
    }
}
