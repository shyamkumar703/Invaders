// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct TournamentConfigsRequest: IdentifiableOutputRequest {
    typealias Output = TournamentModel
    var path: String
    
    init(id: String) {
        self.path = "games/\(id)/tournamentDefinitions"
    }
}
