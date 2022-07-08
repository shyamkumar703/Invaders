// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct DeleteUserPhotoRequest: Request {

    typealias Output = EmptyResponse
    var path: String
    
    init(uid: String) {
        self.path = "profile_photo/\(uid)"
    }
}
