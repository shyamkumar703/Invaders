// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct BlitzModeRequest: Request {
    typealias Output = BlitzResponse
    var path: String = "tournaments/blitz/v2"
    var query: RequestQuery?
    var body: String?
    
    init(query: BlitzModeQuery) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}

struct BlitzModeQuery: RequestQuery {
    var tournamentDefinitionId: String
    var blitzMultipliers: [BlitzMultiplier]
    var seed: Int
}

struct BlitzResponse: Response {
    var id: String
    var status: TournamentResponseStatus?
    var tournament: BlitzData?
    
    private enum CodingKeys: String, CodingKey {
        case id = "tournamentId"
        case status
        case tournament
    }
}
