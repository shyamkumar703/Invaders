// Copyright © TriumphSDK. All rights reserved.

import Foundation

extension SharedSessionManager {
    func updateUserFcmToken(_ token: String?) async throws {
        let uid = try getUserId()
        let request = UpdateUserFcmTokenRequest(
            userId: uid,
            appId: dependencies.appInfo.id,
            fcmToken: token
        )
        try await dependencies.network.update(request: request)
    }
}
