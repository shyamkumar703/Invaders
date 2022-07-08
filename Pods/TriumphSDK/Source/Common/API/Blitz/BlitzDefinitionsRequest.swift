// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct BlitzDefinitionsRequest: IdentifiableOutputRequest {
    typealias Output = BlitzDefinition
    var path: String
    
    init(id: String) {
        path = "games/\(id)/blitzTournamentDefinitions"
    }
}
