// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

public enum MessageTransactionType: String {
    case finishTournament = "finish-tournament"
    case hotStreakAward = "hotStreak-award"
    case finishBlitz = "finish-blitz"
    case referrerBonus = "referrer-bonus"
    case finishMission = "finish-mission"
    case none
}

public struct LiveMessage: Response, SelfIdentifiable {
    public var id: String?
    public var name: String
    public var wonAmount: Int
    private var rawType: String
    public var missionName:  String?
    public var missionEmoji: String?
    public var rewardType: String?
    public var tournamentName: String?
    public var emoji: String?
    
    public init(
        id: String? = nil,
        name: String,
        wonAmount: Int,
        rawType: String,
        missionName: String? = nil,
        missionEmoji: String? = nil,
        rewardType: String? = nil,
        tournamentName: String? = nil,
        emoji: String? = nil
    ) {
        self.id = id
        self.name = name
        self.wonAmount = wonAmount
        self.rawType = rawType
        self.missionName = missionName
        self.missionEmoji = missionEmoji
        self.rewardType = rewardType
        self.tournamentName = tournamentName
        self.emoji = emoji
    }
    
    public var type: MessageTransactionType {
        MessageTransactionType(rawValue: rawType) ?? .none
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case wonAmount
        case rawType = "type"
        case missionName
        case missionEmoji
        case rewardType
        case tournamentName
        case emoji
    }
}
