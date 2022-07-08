// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct CashoutRequest: Request {
    typealias Output = EmptyResponse
    var path: String = "cashout"
    var query: RequestQuery?
    var body: String?
    
    init(query: CashoutRequestQuery) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}

struct CashoutRequestQuery: RequestQuery {
    var cardNum: String
    var cardExp: String
}
