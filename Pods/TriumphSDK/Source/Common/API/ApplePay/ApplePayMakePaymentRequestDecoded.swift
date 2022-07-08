// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon
import Frames

struct ApplePayMakePaymentQueryDecoded: RequestQuery {
    var token: ApplePayTokenData
    var merchantId: String
    var triumphTokens: Int
}

struct ApplePayMakePaymentRequestDecoded: Request {
    typealias Output = EmptyResponse
    var path: String = "checkout/decoded"
    var query: RequestQuery?
    var body: String?
    
    init(query: ApplePayMakePaymentQueryDecoded) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}
