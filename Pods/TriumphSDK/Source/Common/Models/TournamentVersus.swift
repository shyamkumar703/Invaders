// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

public enum TournamentStatus: String, Codable {
    case waitingToMatch = "waiting-to-match"
    case inProgress = "in-progress"
    case finished = "finished"
}

public enum TournamentDataType: String, Codable {
    case versus = "async-1v1"
    case blitz = "blitz"
}

public enum TournamentResponseStatus: String, Codable {
    case foundMatch = "found-match"
    case createdNew = "created-new"
}

public struct TournamentVersus: Response {
    public var id: String
    public var status: TournamentResponseStatus?
    public var tournament: TournamentData?
    
    public init(
        id: String,
        status: TournamentResponseStatus? = nil,
        tournament: TournamentData? = nil
    ) {
        self.id = id
        self.status = status
        self.tournament = tournament
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "tournamentId"
        case status
        case tournament
    }
}

public struct TournamentData: Response, SelfIdentifiable {
    public var id: String?
    public var randomSeed: Int?
    public var config: TournamentModel?
    public var configId: String?
    public var createdAt: Int?
    public var finishedAt: Int?
    public var loserUid: String?
    public var matchedAt: Int?
    public var player1: PlayerModel
    public var player2: PlayerModel?
    public var status: TournamentStatus?
    public var type: TournamentDataType
    public var tie: Bool?
    public var version: String?
    public var winnerUid: String?
    
    public init(
        id: String? = nil,
        randomSeed: Int? = nil,
        config: TournamentModel? = nil,
        configId: String? = nil,
        createdAt: Int? = nil,
        finishedAt: Int? = nil,
        loserUid: String? = nil,
        matchedAt: Int? = nil,
        player1: PlayerModel,
        player2: PlayerModel? = nil,
        status: TournamentStatus? = nil,
        type: TournamentDataType,
        tie: Bool? = nil,
        version: String? = nil,
        winnerUid: String? = nil
    ) {
        self.id = id
        self.randomSeed = randomSeed
        self.config = config
        self.configId = configId
        self.createdAt = createdAt
        self.finishedAt = finishedAt
        self.loserUid = loserUid
        self.matchedAt = matchedAt
        self.player1 = player1
        self.player2 = player2
        self.status = status
        self.type = type
        self.tie = tie
        self.version = version
        self.winnerUid = winnerUid
    }
    
    private enum CodingKeys: String, CodingKey {
        case randomSeed = "RNG"
        case config
        case configId
        case createdAt
        case finishedAt
        case loserUid
        case matchedAt
        case player1
        case player2
        case status
        case type
        case tie
        case version
        case winnerUid
    }
}
