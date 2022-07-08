// Copyright © TriumphSDK. All rights reserved.

import Foundation
import FirebaseFirestore

public struct RemoveFCMTokenRequest: Request {
    public typealias Output = EmptyResponse
    public var path: String
    public var query: RequestQuery?
    public var dict: [AnyHashable: Any]?
    
    public init(uid: String, gameId: String) {
        self.path = "appUsers/\(uid)"
        self.dict = ["fcmTokens.\(gameId)": FieldValue.delete(), "updatedAt": Date().millisecondsSince1970]
    }
}
