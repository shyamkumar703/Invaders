//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation
import TriumphCommon

struct GameStates: Response, RequestQuery {
    var createdAt: Int?
    var hotStreak: Int?
    var hotStreakConfetti: Bool?
    var skillRank: [String: SkillRank]?
    var percentile: Double?
}

struct SkillRank: Codable {
    var deviation: Double
    var rating: Double
    var vol: Double
}
