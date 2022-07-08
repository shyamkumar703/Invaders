//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation
import TriumphCommon

struct GameStatesRequest: Request {
    typealias Output = GameStates
    var path: String
    
    init(userId: String, gameId: String) {
        self.path = "appUsers/\(userId)/gameStates/\(gameId)"
    }
}

struct GameStatesUpdateRequest: Request {
    typealias Output = GameStates
    var path: String
    var query: RequestQuery?
    
    init(userId: String, gameId: String) {
        self.path = "appUsers/\(userId)/gameStates/\(gameId)"
        self.query = GameStates(
            createdAt: Int(Date().timeIntervalSince1970*1000),
            hotStreak: 0,
            hotStreakConfetti: false,
            skillRank: [:]
        )
    }
}
