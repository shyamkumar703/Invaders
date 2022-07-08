// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

public struct MissionModel: Response {
    public var id: String
    public var emoji: String
    public var title: String
    public var unlockedFor: [String: Int]
    public var isCompleted: Bool
    public var completedFor: [String: Int]
    public var incentiveAmount: Int
    public var rewardReceived: [String: Int]
    public var displayOrder: Int
    public var missionAction: MissionAction = .makeReferral
    public var description: String?
    public var rewardType: MissionRewardType
    public var missionProgress: Int?
    public var missionCompletion: Int?
    
    public init(config: MissionConfig, missionUser: MissionUser) {
        self.emoji = config.emoji
        self.title = config.name
        self.incentiveAmount = config.reward
        self.displayOrder = config.displayOrder
        self.isCompleted = missionUser.isCompleted
        self.id = config.id ?? ""
        self.rewardReceived = missionUser.rewardReceived
        self.unlockedFor = missionUser.unlockedFor
        self.completedFor = missionUser.completedFor
        self.description = config.description
        self.rewardType = config.rewardType
        self.missionProgress = missionUser.missionProgress
        self.missionCompletion = config.missionCompletion
    }
}

// MARK: - MissionConfig

public struct MissionConfig: Response, SelfIdentifiable {
    public var id: String?
    public var displayOrder: Int
    public var emoji: String
    public var name: String
    public var reward: Int
    public var rewardTypeWrapped: String
    public var rewardType: MissionRewardType {
        MissionRewardType(rawValue: rewardTypeWrapped) ?? .money
    }
    public var description: String?
    public var missionCompletion: Int?
    
    public init(
        id: String? = nil,
        displayOrder: Int,
        emoji: String,
        name: String,
        reward: Int,
        rewardTypeWrapped: String,
        description: String? = nil,
        missionCompletion: Int? = nil
    ) {
        self.id = id
        self.displayOrder = displayOrder
        self.emoji = emoji
        self.name = name
        self.reward = reward
        self.rewardTypeWrapped = rewardTypeWrapped
        self.description = description
        self.missionCompletion = missionCompletion
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case displayOrder
        case emoji
        case name
        case reward
        case rewardTypeWrapped = "rewardType"
        case description
        case missionCompletion
    }
}

// MARK: - MissionUser

public struct MissionUser: Response, SelfIdentifiable {
    public var id: String?
    public var completedFor: [String: Int]
    public var isCompleted: Bool
    public var rewardReceived: [String: Int]
    public var unlockedFor: [String: Int]
    public var missionProgress: Int?
    
    public init(
        id: String? = nil,
        completedFor: [String : Int],
        isCompleted: Bool,
        rewardReceived: [String : Int],
        unlockedFor: [String : Int],
        missionProgress: Int? = nil
    ) {
        self.id = id
        self.completedFor = completedFor
        self.isCompleted = isCompleted
        self.rewardReceived = rewardReceived
        self.unlockedFor = unlockedFor
        self.missionProgress = missionProgress
    }
}

public enum MissionRewardType: String, Codable {
    case money
    case tree
    case token
}

public enum MissionAction: String, Codable {
    case makeReferral
    case playBlitz
    case playSilver
    case description
}
