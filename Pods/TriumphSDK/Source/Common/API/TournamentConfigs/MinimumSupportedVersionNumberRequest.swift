// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct MinimumSupportedVersionNumberQuery: RequestQuery {
    var versionNumber: Double
}

struct MinimumSupportedVersionNumberRequest: Request {
    typealias Output = EmptyResponse
    var path: String
    
    init(gameId: String) {
        self.path = "games/\(gameId)"
    }
}
