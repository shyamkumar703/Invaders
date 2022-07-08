// Copyright © TriumphSDK. All rights reserved.

import UIKit
import FirebaseMessaging

public enum PushNotificationsError: Error {
    case pushTokenUpdatingFailed
    case removePushTokenFailed
}

public protocol PushNotifications {
    var isRegistered: Bool { get async }
    
    /// Show the system alert controller that allows users to accept push notifications
    func registerForPushNotifications() async throws
}

// MARK: - Impl.

class PushNotificationsService: NSObject, PushNotifications {

    typealias Dependencies = HasLogger & HasSharedSession
    private var dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    var isRegistered: Bool {
        get async {
            guard await dependencies.sharedSession.user?.fcmToken != nil else { return false }
            return await UIApplication.shared.isRegisteredForRemoteNotifications
        }
    }

    func registerForPushNotifications() async throws {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
        if granted == true {
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
            try await self.updateFirebasePushTokenIfNeeded()
        }
        Messaging.messaging().delegate = self
    }
}

private extension PushNotificationsService {
    
    /// Update FCM token under the User object in Firestore
    func updateFirebasePushTokenIfNeeded() async throws {
        guard let token = Messaging.messaging().fcmToken else {
            throw PushNotificationsError.pushTokenUpdatingFailed
        }
        
        try await dependencies.sharedSession.updateUserFcmToken(token)
    }

    func removePushToken() async throws {
        try await dependencies.sharedSession.updateUserFcmToken(nil)
    }
}

// MARK: - MessagingDelegate

extension PushNotificationsService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task { [weak self] in
            do {
                try await updateFirebasePushTokenIfNeeded()
            } catch {
                self?.dependencies.logger.log("didReceiveRegistrationToken - update firebase push token failed", .error)
            }
        }
    }
}
