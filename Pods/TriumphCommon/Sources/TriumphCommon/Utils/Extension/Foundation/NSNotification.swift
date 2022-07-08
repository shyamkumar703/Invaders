// Copyright © TriumphSDK. All rights reserved.

import Foundation

public extension Notification.Name {
    static let balanceUpdated = Notification.Name("com.triumph.balanceUpdated")
    static let profileUpdated = Notification.Name("com.triumph.profileUpdated")
    static let networkChecker = Notification.Name("com.triumph.networkChecker")
    static let random1Updated = Notification.Name("com.triumph.random1Updated")
    static let invalidateTask = Notification.Name("com.triumph.invalidateTask")
    static let lockdownUpdated = Notification.Name("com.triumph.lockdownUpdated")
    static let transactionsUpdated = Notification.Name("com.triumph.transactionsUpdated")
    static let tokenBalanceUpdated = Notification.Name("com.triumph.tokenBalanceUpdated")
    static let disableLocationCheckUpdate = Notification.Name("com.triumph.disableLocationCheckUpdated")
    static let showServerUnavailableAlert = Notification.Name("com.triumph.showServerUnavailable")
    static let kycStatusUpdated = Notification.Name("com.triumph.kycStatusUpdated")
    static let locationUpdated = Notification.Name("com.triumph.locationUpdated")
    static let hostConfigUpdated = Notification.Name("com.triumph.hostConfigUpdated")
    static let passedCheatingDetection = Notification.Name("com.triumph.passedCheatingDetection")
}

@objc extension NSNotification {
    public static let balanceUpdated = Notification.Name.balanceUpdated
    public static let profileUpdated = Notification.Name.profileUpdated
    public static let networkChecker = Notification.Name.networkChecker
    public static let invalidateTask = Notification.Name.invalidateTask
    public static let lockdownUpdated = Notification.Name.lockdownUpdated
    public static let transactionsUpdated = Notification.Name.transactionsUpdated
    public static let tokenBalanceUpdated = Notification.Name.tokenBalanceUpdated
    public static let disableLocationCheckUpdate = Notification.Name.disableLocationCheckUpdate
    public static let showServerUnavailable = Notification.Name.showServerUnavailableAlert
    public static let kycStatusUpdated = Notification.Name.kycStatusUpdated
    public static let locationUpdated = Notification.Name.locationUpdated
    public static let hostConfigUpdated = Notification.Name.hostConfigUpdated
    public static let passedCheatingDetection = Notification.Name.passedCheatingDetection
}
