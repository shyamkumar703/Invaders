// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct TournamentBuyIntoGameRequest: Request {
    typealias Output = TournamentVersus
    var path: String = "tournaments/async1v1/"
    var query: RequestQuery?
    var body: String?
    
    init(query: TournamentBuyIntoGameQuery) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}

struct TournamentBuyIntoGameQuery: RequestQuery {
    var game: String
    var config: TournamentModel
    var configId: String
}
