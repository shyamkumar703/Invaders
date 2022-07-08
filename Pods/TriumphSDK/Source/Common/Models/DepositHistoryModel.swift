// Copyright © TriumphSDK. All rights reserved.

import TriumphCommon

public enum DepositType: String, Codable {
    case startTournament = "start-tournament"
    case finishTournament = "finish-tournament"
    case hotStreakAward = "hotStreak-award"
    case startBlitz = "start-blitz"
    case finishBlitz = "finish-blitz"
    case deposit
    case withdrawal
    case withdrawalRedeposit = "withdrawal-redeposit"
    case accountCreationDeposit = "account-creation-deposit"
    case finishMission = "finish-mission"
    case referral = "referrer-bonus"
    case newGame = "new-game"
}

public struct DepositHistoryModel: Response, HistoryModel {
    public var id: String?
    public var userId: String
    public var requestId: String?
    public var tournamentId: String?
    public var gameUID: String?
    public var game: String?
    public var type: DepositType?
    public var rawAmount: Double
    public var transactionTimestamp: Double?
    public var createdAt: Double
    public var description: String?
    public var missionId: String?
    public var missionName: String?
    public var missionEmojiWrapped: String?
    public var totalFee: Double?
    public var rewardTypeWrapped: String?
    public var refereeUid: String?
    public var tokenAmount: Int?
    
    public init(
        id: String? = nil,
        userId: String,
        requestId: String? = nil,
        tournamentId: String? = nil,
        gameUID: String? = nil,
        game: String? = nil,
        type: DepositType? = nil,
        rawAmount: Double,
        transactionTimestamp: Double? = nil,
        createdAt: Double,
        description: String? = nil,
        missionId: String? = nil,
        missionName: String? = nil,
        missionEmojiWrapped: String? = nil,
        totalFee: Double? = nil,
        rewardTypeWrapped: String? = nil,
        refereeUid: String? = nil,
        tokenAmount: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.requestId = requestId
        self.tournamentId = tournamentId
        self.gameUID = gameUID
        self.game = game
        self.type = type
        self.rawAmount = rawAmount
        self.transactionTimestamp = transactionTimestamp
        self.createdAt = createdAt
        self.description = description
        self.missionId = missionId
        self.missionName = missionName
        self.missionEmojiWrapped = missionEmojiWrapped
        self.totalFee = totalFee
        self.rewardTypeWrapped = rewardTypeWrapped
        self.refereeUid = refereeUid
        self.tokenAmount = tokenAmount
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "transactionId"
        case tournamentId
        case userId = "appUserUid"
        case requestId
        case game
        case gameUID = "gameuid"
        case type
        case rawAmount = "amount"
        case transactionTimestamp = "transactionDate"
        case createdAt
        case description
        case missionId
        case missionName
        case missionEmojiWrapped = "missionEmoji"
        case rewardTypeWrapped = "rewardType"
        case totalFee
        case refereeUid
        case tokenAmount
    }

    private enum MissionEmoji: String {
        case referral
        case playSilver
        case playBlitz
        
        var emoji: String {
            switch self {
            case .referral: return "🤝"
            case .playBlitz: return "⚡️"
            case .playSilver: return "🥈"
            }
        }
    }

    public var amount: Double {
        rawAmount / 100
    }
    
    public var date: Date {
        Date(timeIntervalSince1970: (transactionTimestamp ?? createdAt) / 1000)
    }
    
    public var missionEmoji: String? {
        if missionEmojiWrapped != nil {
            return missionEmojiWrapped
        } else {
            guard let missionId = missionId else {
                return nil
            }
            return MissionEmoji(rawValue: missionId)?.emoji
        }
    }
    
    public var rewardType: MissionRewardType? {
        if let rewardTypeWrapped = rewardTypeWrapped {
            return MissionRewardType(rawValue: rewardTypeWrapped)
        } else {
            return nil
        }
    }
    
    // FIXME: Move to view model
    public var title: String? {
        nil
    }
    
    // FIXME: Move to view model
    public var resultTitle: String? {
        nil
    }
}
