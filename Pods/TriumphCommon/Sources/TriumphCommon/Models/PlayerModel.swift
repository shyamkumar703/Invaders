// Copyright © TriumphSDK. All rights reserved.

import Foundation

public struct PlayerFinalScore: Codable, Equatable {
    public var createdAt: Double
    public var value: Double
    
    public init(createdAt: Double, value: Double) {
        self.createdAt = createdAt
        self.value = value
    }
}

public struct PlayerModel: Equatable, Codable {
    public var uid: String
    public var finalScore: PlayerFinalScore?
    public var score: Double? {
        get {
            finalScore?.value
        }
        set {}
    }
    public var username: String?
    public var userpic: String?

    public init?(uid: String?, score: Double?, username: String?, userpic: String? = nil) {
        guard let uid = uid, uid.lowercased() != "none",
            username?.lowercased() != "none" else { return nil }
        self.uid = uid
        self.score = score
        self.username = username
        self.userpic = userpic
        
        guard let value = score else { return }
        self.finalScore = PlayerFinalScore(createdAt: Date().timeIntervalSince1970, value: value)
    }

    private enum CodingKeys: String, CodingKey {
        case uid
        case finalScore
        case username
        case userpic = "profilePic"
    }
}
