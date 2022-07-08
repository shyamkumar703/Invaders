// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct ClaimUnclaimedBalanceQuery: RequestQuery {
    var game: String
}

struct ClaimUnclaimedBalanceRequest: Request {
    typealias Output = EmptyResponse
    var path: String = "users/claim_unclaimed_balance"
    var query: RequestQuery?
    var body: String?
    
    init(query: ClaimUnclaimedBalanceQuery) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}
