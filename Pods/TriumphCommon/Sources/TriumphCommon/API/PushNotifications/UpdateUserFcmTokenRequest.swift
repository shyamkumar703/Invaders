// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct UpdateUserFcmTokenQuery: RequestQuery {
    var fcmTokens: [String: String]
    var updatedAt: Int64
}

struct UpdateUserFcmTokenRequest: Request {
    typealias Output = EmptyResponse
    var path: String
    var query: RequestQuery?
    var dict: [AnyHashable : Any]?
    
    init(userId: String, appId: String, fcmToken: String?) {
        self.path = "appUsers/\(userId)"
        if let fcmToken = fcmToken {
            self.dict = ["fcmTokens.\(appId)": fcmToken, "updatedAt": Date().millisecondsSince1970]
        }
    }
}
