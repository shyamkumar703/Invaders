// Copyright © TriumphSDK. All rights reserved.

import Foundation

public struct User: Response {
    public var shouldShowOnboarding: Bool?
    public var phoneNumber: String?
    public var id: String?
    public var balance: Int = 0
    public var withdrawableBalance: Int = 0
    public var withdrawalLimit: Int = 0
    public var hotstreak: Int?
    public var shouldShowConfetti: Bool?
    public var unclaimedBalance: Int?
    public var banned: Bool?
    public var disableLocationCheck: Bool = false
    public var random1: Int?
    public var passbaseKey: String?
    public var kycStatus: Bool?
    public var fcmToken: String?
    public var fcmTokens: [String: String]?
    public var createdAt: Double = Date().timeIntervalSince1970
    public var updatedAt: Double = Date().timeIntervalSince1970
//    public var birthday: String?
    public var isInSupportedLocation: Bool
    public var tokenBalance: Int
    public var hasSeenTutorial: Bool?
    
    public init(
        shouldShowOnboarding: Bool? = nil,
        phoneNumber: String? = nil,
        id: String? = nil,
        balance: Int = 0,
        withdrawableBalance: Int = 0,
        withdrawalLimit: Int = 0,
        hotstreak: Int? = nil,
        shouldShowConfetti: Bool? = nil,
        unclaimedBalance: Int? = nil,
        banned: Bool? = nil,
        disableLocationCheck: Bool = false,
        random1: Int? = nil,
        passbaseKey: String? = nil,
        kycStatus: Bool? = nil,
        fcmToken: String? = nil,
        fcmTokens: [String: String]? = nil,
        createdAt: Double = Date().timeIntervalSince1970,
        updatedAt: Double = Date().timeIntervalSince1970,
//        birthday: String? = nil,
        isInSupportedLocation: Bool,
        tokenBalance: Int,
        hasSeenTutorial: Bool? = nil
    ) {
        self.shouldShowOnboarding = shouldShowOnboarding
        self.phoneNumber = phoneNumber
        self.id = id
        self.balance = balance
        self.withdrawableBalance = withdrawableBalance
        self.withdrawalLimit = withdrawalLimit
        self.hotstreak = hotstreak
        self.shouldShowConfetti = shouldShowConfetti
        self.unclaimedBalance = unclaimedBalance
        self.banned = banned
        self.disableLocationCheck = disableLocationCheck
        self.random1 = random1
        self.passbaseKey = passbaseKey
        self.kycStatus = kycStatus
        self.fcmToken = fcmToken
        self.fcmTokens = fcmTokens
        self.createdAt = createdAt
        self.updatedAt = updatedAt
//        self.birthday = birthday
        self.isInSupportedLocation = isInSupportedLocation
        self.tokenBalance = tokenBalance
        self.hasSeenTutorial = hasSeenTutorial
    }
    
    private enum CodingKeys: String, CodingKey {
        case phoneNumber
        case id = "uid"
        case fcmToken
        case fcmTokens
        case balance
        case banned
        case unclaimedBalance
        case withdrawableBalance
        case withdrawalLimit
        case shouldShowOnboarding
        case disableLocationCheck
        case random1
        case passbaseKey
        case kycStatus
        case createdAt
        case updatedAt
//        case birthday
        case isInSupportedLocation
        case tokenBalance
        case hasSeenTutorial
    }
}

extension User: Hashable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
         hasher.combine(id)
    }
}
