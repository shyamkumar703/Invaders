// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct UserPublicInfoRequest: Request {
    typealias Output = UserPublicInfo
    
    var path: String
    
    init(uid: String) {
        self.path = "appUsersPublic/\(uid)"
    }
}
