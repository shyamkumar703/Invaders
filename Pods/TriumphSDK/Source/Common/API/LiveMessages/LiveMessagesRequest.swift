// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct LiveMessagesRequest: IdentifiableOutputRequest {
    typealias Output = LiveMessage
    var path: String
    var limit: Int? = 100
    var orderBy: String? = "createdAt"
    var shouldSortDescending: Bool? = true
    
    init(gameId: String) {
        self.path = "games/\(gameId)/liveMessages"
    }
}
