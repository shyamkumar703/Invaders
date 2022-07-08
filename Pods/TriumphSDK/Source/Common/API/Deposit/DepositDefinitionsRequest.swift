// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct DepositDefinitionResponse: Response, SelfIdentifiable {
    var id: String?
    var depositAmount: Int
    var tokens: Int?
    var isBestValue: Bool?
}

struct DepositDefinitionsRequest: IdentifiableOutputRequest {
    typealias Output = DepositDefinitionResponse
    var path: String
    
    init(gameId: String) {
        path = "games/\(gameId)/depositDefinitions"
    }
}
