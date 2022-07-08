// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct AllUsersPublicInfoRequest: IdentifiableOutputRequest {
    typealias Output = UserPublicInfo
    var path: String = "appUsersPublic"
}
