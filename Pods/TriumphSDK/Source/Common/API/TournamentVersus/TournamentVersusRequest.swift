// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct TournamentVersusRequest: Request {
    typealias Output = TournamentData
    var path: String
    
    init(gameId: String, tournamentId: String) {
        self.path = "games/\(gameId)/tournaments/\(tournamentId)"
    }
}
