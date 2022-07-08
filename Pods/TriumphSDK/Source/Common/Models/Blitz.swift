// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct BlitzDefinition: Response, SelfIdentifiable {
    var id: String?
    var entryPrice: Int?
    var maxTokens: Int?
    var archived: Bool
}

struct BlitzData: Response, SelfIdentifiable {
    var id: String?
    var tournamentDefinitionId: String?
    var tournamentDefinition: BlitzDefinition?
    var percentile: Double?
    var seed: Int?
    var score: Double?
    var uid: String?
    var payout: Double?
    var status: TournamentStatus?
    var createdAt: Int?
    var finishedAt: Int?
}

public struct BlitzSeedCycleData: Response {
    public var gameNumber: Int
    
    public init(gameNumber: Int) {
        self.gameNumber = gameNumber
    }
}
