// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct TournamentSubmitScoreRequest: Request {
    typealias Output = TournamentVersus
    var path: String = "tournaments/async1v1/report_score"
    var query: RequestQuery?
    var body: String?
    
    init(query: TournamentSubmitScoreQuery) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}

struct TournamentSubmitScoreQuery: RequestQuery {
    var game: String
    var score: Double
    var tournamentId: String
}

