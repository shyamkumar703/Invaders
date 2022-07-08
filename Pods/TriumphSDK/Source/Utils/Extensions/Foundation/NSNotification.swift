// Copyright © TriumphSDK. All rights reserved.

import Foundation

extension Notification.Name {
    static let gameOver = Notification.Name("com.triumph.gameover")
    static let blitzOver = Notification.Name("com.triumph.blitzOver")
    static let locationUpdated = Notification.Name("com.triumph.locationUpdated")
    static let showAsyncExplanation = Notification.Name("com.triumph.showAsyncExplanation")
    static let beginScrollingLiveTicker = Notification.Name("com.triumph.beginLiveTicker")
    static let showServerUnavailableAlert = Notification.Name("com.triumph.showServerUnavailable")
    static let stopMatchingHaptics = Notification.Name("com.triumph.stopMatchingHaptics")
    static let tournamentsSectionsUpdated = Notification.Name("com.triumph.tournamentsSectionsUpdated")
    static let tournamentDefinitionsUpdated = Notification.Name("com.triumph.tournamentDefinitionsUpdated")
    static let depositAmountSelected = Notification.Name("com.triumph.depositAmountSelected")
    static let showApplePay = Notification.Name("com.triumph.showApplePay")
    static let respondToReferralFromDepositSheet = Notification.Name("com.triumph.respondToReferralFromDeposit")
    static let missionsUpdated = Notification.Name("com.triumph.missionsUpdated")
    static let hotstreak = Notification.Name("com.triumph.hotstreak")
    static let missionFinished = Notification.Name("com.triumph.missionFinished")
    static let liveMessagesUpdated = Notification.Name("com.triumph.liveMessagesUpdated")
    static let historyUpdate = Notification.Name("com.triumph.historyUpdate")
    static let didRetrieveOtherGames = Notification.Name("com.triumph.didRetrieveOtherGames")
    static let enablePageControlInteraction = Notification.Name("com.triumph.enablePageControlInteraction")
    static let percentileUpdated = Notification.Name("com.triumph.percentileUpdated")
    static let hotstreakInfoButton = Notification.Name("com.triumph.hotstreakInfoButton")
    static let blitzDefinitionsFetched = Notification.Name("com.triumph.blitzDefinitionsFetched")
}

@objc extension NSNotification {
    public static let gameOver = Notification.Name.gameOver
    public static let blitzOver = Notification.Name.blitzOver
    public static let locationUpdated = Notification.Name.locationUpdated
    public static let showAsyncExplanation = Notification.Name.showAsyncExplanation
    public static let showServerUnavailable = Notification.Name.showServerUnavailableAlert
    public static let stopMatchingHaptics = Notification.Name.stopMatchingHaptics
    public static let tournamentsSectionsUpdated = Notification.Name.tournamentsSectionsUpdated
    public static let tournamentDefinitionsUpdated = Notification.Name.tournamentDefinitionsUpdated
    public static let depositAmountSelected = Notification.Name.depositAmountSelected
    public static let showApplePay = Notification.Name.showApplePay
    public static let respondToReferralFromDepositSheet = Notification.Name.respondToReferralFromDepositSheet
    public static let missionsUpdated = Notification.Name.missionsUpdated
    public static let hotstreak = Notification.Name.hotstreak
    public static let missionFinished = Notification.Name.missionFinished
    public static let liveMessagesUpdated = Notification.Name.liveMessagesUpdated
    public static let historyUpdate = Notification.Name.historyUpdate
    public static let didRetrieveOtherGames = Notification.Name.didRetrieveOtherGames
    public static let enablePageControlInteraction = Notification.Name.enablePageControlInteraction
    public static let percentileUpdated = Notification.Name.percentileUpdated
    public static let hotstreakInfoButton = Notification.Name.hotstreakInfoButton
    public static let blitzDefinitionsFetched = Notification.Name.blitzDefinitionsFetched
}
