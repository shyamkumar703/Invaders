// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct DepositHistoryRequest: IdentifiableOutputRequest {
    typealias Output = DepositHistoryModel
    var path: String
    
    init(id: String) {
        self.path = "appUsers/\(id)/balanceTransactions"
    }
}
