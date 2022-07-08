// Copyright © TriumphSDK. All rights reserved.

import Foundation

public struct StorageKey: RawRepresentable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public extension StorageKey {
    static let isAuthenticated = StorageKey(rawValue: "isAuthenticated")
    static let isSignedUp = StorageKey(rawValue: "isSignedUp")
    static let phoneVerificationID = StorageKey(rawValue: "phoneVerificationID")
    static let lockdown = StorageKey(rawValue: "lockdown")
    static let user = StorageKey(rawValue: "user")
    static let passbaseState = StorageKey(rawValue: "passbaseState")
    static let userPublicInfo = StorageKey(rawValue: "userPublicInfo")
    static let isEligibleLocation = StorageKey(rawValue: "isEligibleLocation")
    static let lastMinimumSupportedVersionNumber = StorageKey(rawValue: "lastMinimumSupportedVersionNumber")
    static let hostConfig = StorageKey(rawValue: "hostConfig")
    static let referrerUsername = StorageKey(rawValue: "referrerUsername")
    static let birthday = StorageKey(rawValue: "birthday")
    static let terms = StorageKey(rawValue: "terms")
}
