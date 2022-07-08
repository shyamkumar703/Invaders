// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct SubmitBlitzScoreQuery: RequestQuery {
    var score: Double
    var tournamentId: String?
}

struct SubmitBlitzScoreRequest: Request {
    typealias Output = EmptyResponse
    var path: String = "tournaments/blitz/v2/report_score"
    var query: RequestQuery?
    var body: String?
    
    init(query: SubmitBlitzScoreQuery) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}
