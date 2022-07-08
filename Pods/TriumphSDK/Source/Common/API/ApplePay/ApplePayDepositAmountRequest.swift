// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct ApplePayDepositAmountQuery: RequestQuery {
    var amount: String
}

struct ApplePayDepositAmountRequest: Request {
    typealias Output = EmptyResponse
    var path: String = "deposit-depositAmount"
    var query: RequestQuery?
    
    init(amount: String) {
        self.query = ApplePayDepositAmountQuery(amount: amount)
    }
}
