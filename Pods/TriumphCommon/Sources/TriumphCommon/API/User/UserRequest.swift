// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct UserRequest: Request {
    typealias Output = User
    var path: String
    
    init(uid: String) {
        self.path = "appUsers/\(uid)"
    }
}
