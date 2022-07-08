// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct TournamentsHistoryRequest: IdentifiableOutputRequest {
    typealias Output = TournamentData
    var path: String
    var queryPredicate: NSPredicate?
    
    init(userId: String, gameId: String) {
        self.path = "games/\(gameId)/tournaments"
        self.queryPredicate = NSPredicate(format: "participants CONTAINS %@", userId)
    }
}
