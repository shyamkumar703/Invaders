//
//  TriumphSDK.swift
//  TriumphSDK
//
//  Created by Maksim Kalik on 3/11/22.
//

import Foundation
import FirebaseCore
import FirebaseAppCheck
import UIKit
import TriumphCommon

public struct TriumphColors {
    public var TRIUMPH_PRIMARY_COLOR: UIColor
    public var TRIUMPH_GRADIENT_COLORS: [UIColor]
    
    public init(primary: UIColor = #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1),
                gradient: [UIColor] = [#colorLiteral(red: 0.9136844277, green: 0.2966261506, blue: 0.2330961823, alpha: 1), #colorLiteral(red: 0.9810395837, green: 0.5708991885, blue: 0.154723525, alpha: 1)]) {
        self.TRIUMPH_PRIMARY_COLOR = primary
        self.TRIUMPH_GRADIENT_COLORS = gradient
    }
}

public final class TriumphSDK: NSObject {

    @objc
    public static var delegate: TriumphSDKDelegate?
    
    /// The Game Id
    /// (By default it will be bundleIdentifier String)
    public static var gameId: String?
    
    /// The Game Title
    /// (By default it will be CFBundleDisplayName from Bundle)
    public static var gameTitle: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    
    /// Game App Icon or an Image name
    /// (By default it will be Triumph logo)
    public static var gameAppIcon: String?
    
    /// Print the score in your own way
    /// (By default it will be double)
    /// ```
    /// enum GameScoreType {
    ///     case zero
    ///     case one
    ///     case two
    /// }
    /// ```
    public static var scoreDecimalPoints: DecimalPoints = .zero {
        didSet {
            dependencies.appInfo.scoreType = scoreDecimalPoints
        }
    }

    /// Configure SDK with your own colors useing TriumphColors object
    /// (By default the color will be orange)
    public static var colors: TriumphColors = TriumphColors()
    

    /// Configure the SDK with your own merchant ID
    public static var merchantId = "merchant.triumph.production.decrypt-use"
    public static var isControllerPresented: Bool = coordinator?.navigationController != nil
    
    public static var appleId: String = "1595159783"
    internal static var dependencies = AppDependencies(gameInfo: gameInfo)
    private static var coordinator: MainCoordinator?

    private static var gameInfo = AppInfoModel(
        // TODO: bugbash
        id: gameId ?? Bundle.main.bundleIdentifier ?? "",
        title: gameTitle,
        icon: gameAppIcon,
        scoreType: scoreDecimalPoints
    )

    @MainActor @objc
    public static func enterTriumph() {
        presentTriumphViewController()
    }
}

// MARK: - Configure

public extension TriumphSDK {
    
    /// Configure TriumphSDK
    /// If you need to use specific game id then set gameId before this method
    @objc
    static func configure(gameId: String? = nil) {
        self.gameId = gameId
        configureFirebase()
        dependencies.intercom.configure()
        dependencies.application.setup()
    }

    /// Provide score when game over as Double
    @MainActor @objc
    static func onGameOver(with score: Double, showGameOverViewController: Bool = true) {
        if showGameOverViewController == false {
            dependencies.gamePlay.finishGameInBackground()
            return
        }
        presentTriumphViewController(with: score)
    }
    
    /// Provide score when game over as Double
    @MainActor @objc
    static func onGameOverInt(with score: Int, showGameOverViewController: Bool = true) {
        onGameOver(with: Double(score), showGameOverViewController: showGameOverViewController)
    }
    
    internal static func showGameOver(with gameHistoryModel: GameHistoryModel) {
        coordinator?.pushGameOver(with: gameHistoryModel)
    }
    
    internal static func showLockdown() {
        coordinator?.startLockdown()
    }
    
    /// Update score as Double
    static func updateScore(_ score: Int) {
        dependencies.gamePlay.updateScore(score: Double(score))
    }
    
    /// Update score as Int
    static func updateScore(_ score: Double) {
        dependencies.gamePlay.updateScore(score: score)
    }
    
    /// If your game paused use this method to resume the game
    static func resumeGame() {
        dependencies.gamePlay.resumeGame()
    }
    
    static func dismissController() {
        if coordinator?.navigationController?.viewControllers.isEmpty == false {
            coordinator?.didFinish()
        }
    }
}

extension TriumphSDK {
    @MainActor static func presentTriumphViewController(with score: Double? = nil) {
        // let coordinator = MainCoordinatorImplementation(gameInfo: gameInfo, dependencies: dependencies)
        coordinator = MainCoordinatorImplementation(gameInfo: gameInfo, dependencies: dependencies)
        coordinator?.triumphDelegate = delegate

        if let score = score {
            coordinator?.startWithScore(score: score)
        } else {
            coordinator?.start()
        }
    }
    
    static func presentTriumphViewController(with gameHistoryModel: GameHistoryModel) async {
        if coordinator == nil {
            coordinator = MainCoordinatorImplementation(gameInfo: gameInfo, dependencies: dependencies)
        }
        await coordinator?.start(with: gameHistoryModel)
    }
    
    static func presentTriumphViewController(shouldShowReferralCompletedMessage: Bool) {
        if coordinator == nil {
            coordinator = MainCoordinatorImplementation(gameInfo: gameInfo, dependencies: dependencies)
        }

        coordinator?.start()
        
        if shouldShowReferralCompletedMessage {
            coordinator?.showReferralCompletedMessage()
        }
    }
    
    static func configureFirebase() {
        if FirebaseApp.app() == nil {
            switch UIApplication.environment {
            case .debug: configureFor(.debug)
            case .develop: configureFor(.dev)
            case .production: configureFor(.prod)
            }
            let providerFactory = AppCheckProviderFactoryImplementation()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            AppCheck.appCheck().isTokenAutoRefreshEnabled = true
//            let settings = FirestoreSettings()
//            settings.isPersistenceEnabled = false
//            Firestore.firestore().settings = settings
        }
    }

    private static func configureFor(_ env: Env) {
        guard let filePath = Bundle.main.path(forResource: env.rawValue, ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: filePath)
        else { return }
        FirebaseApp.configure(options: options)
    }
    
    internal static func triumphViewControllerDidClose() {
        coordinator = nil
    }
}

enum Env: String {
    case debug = "debug_GoogleService-Info"
    case dev = "dev_GoogleService-Info"
    case prod = "prod_GoogleService-Info"
}

// MARK: - AppCheckProviderFactory

fileprivate class AppCheckProviderFactoryImplementation: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        if #available(iOS 14.0, *) { // FIXME: SDK is only from iOS 14
            return AppAttestProvider(app: app)
        } else {
            return DeviceCheckProvider(app: app)
        }
    }
}

extension TriumphSDK {
    static var bundle: Bundle? = {
        let bundle = Bundle(for: TriumphSDK.self)
        guard let bundleURL = bundle.resourceURL?.appendingPathComponent("TriumphSDKResources.bundle") else {
            return nil
        }
        return Bundle(url: bundleURL)
    }()
}
