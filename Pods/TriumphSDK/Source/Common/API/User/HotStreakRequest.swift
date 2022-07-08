// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct HotStreakQuery: RequestQuery {
    var hotStreakConfetti = false
}

struct HotStreakRequest: Request {
    typealias Output = EmptyResponse
    var path: String
    var query: RequestQuery?
    
    init(id: String, gameId: String) {
        self.path = "appUsers/\(id)/gameStates/\(gameId)"
        self.query = HotStreakQuery()
    }
}
