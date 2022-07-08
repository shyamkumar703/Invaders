// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct ApplePayMakePaymentQuery: RequestQuery {
    var token: String
    var amount: Int
    var game: String
    var triumphTokens: Int
}

struct ApplePayMakePaymentRequest: Request {
    typealias Output = EmptyResponse
    var path: String = "checkout/"
    var query: RequestQuery?
    var body: String?
    
    init(query: ApplePayMakePaymentQuery) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}
