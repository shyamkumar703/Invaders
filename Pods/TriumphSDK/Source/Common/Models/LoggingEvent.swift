// Copyright © TriumphSDK. All rights reserved.

import Foundation

enum Event: String {
    case sdkOpened
    case sdkClosed
    case accountCreationStarted
    case accountCreationFinished
    case claimOnboardingReward
    case missionTapped
    case missionCompleted
    case playAgainTapped
    case gameBuyIn
    case gameEnd
    case locationDenial
    case deposit
    case cashOut
    case faq
    case logOut
    case tutorialScreen1
    case tutorialScreen2
    case tutorialScreen3
    case tutorialScreen4
    case babyGame
    
    var name: String { rawValue }
}

struct LoggingEvent {
    var event: Event
    var parameters: [String: Any]?
    
    init(_ event: Event, parameters: [String: Any]? = nil) {
        var newParameters = parameters ?? [:]
        newParameters["time"] = Date()
        
        self.event = event
        self.parameters = parameters
    }
}
