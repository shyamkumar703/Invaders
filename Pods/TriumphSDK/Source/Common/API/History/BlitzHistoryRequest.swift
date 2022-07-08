// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct BlitzHistoryRequest: IdentifiableOutputRequest {
    typealias Output = BlitzData
    var path: String
    var queryPredicate: NSPredicate?
    
    init(userId: String, gameId: String) {
        self.path = "games/\(gameId)/blitzTournamentsV2"
        self.queryPredicate = NSPredicate(format: "uid == %@", userId)
    }
}
