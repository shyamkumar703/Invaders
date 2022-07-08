// Copyright © TriumphSDK. All rights reserved.

import Foundation
import FirebaseFirestore
import TriumphCommon

struct RemoveFCMTokenRequest: Request {
    typealias Output = EmptyResponse
    var path: String
    var query: RequestQuery?
    var dict: [AnyHashable: Any]?
    
    init(uid: String, gameId: String) {
        self.path = "appUsers/\(uid)"
        self.dict = ["fcmTokens.\(gameId)": FieldValue.delete(), "updatedAt": Date().millisecondsSince1970]
    }
}
