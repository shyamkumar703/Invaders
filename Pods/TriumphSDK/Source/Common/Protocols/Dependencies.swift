// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol AllDependencies: Dependencies,
                          HasApplePay,
                          HasGameManager,
                          HasConfetti,
                          HasGamePlay,
                          HasAnalytics,
                          HasSession,
                          HasBattery,
                          HasNetworkStrength

{
    var triumphDelegate: TriumphSDKDelegate? { get set }
}

final class AppDependencies: TriumphDependencies, AllDependencies {
    var triumphDelegate: TriumphSDKDelegate?

    init(gameInfo: AppInfoModel) {
        super.init(appInfo: gameInfo)
    }

    lazy var game: GameProtocol = GameManager(dependencies: self)
    lazy var applePay: ApplePay = ApplePayManager(dependencies: self)
    lazy var confetti: Confetti = ConfettiService(dependencies: self)
    lazy var gamePlay: GamePlay = GamePlayService(dependencies: self)
    lazy var application: ApplicationService = ApplicationServiceImplementation()
    lazy var analytics: AnalyticsService = AnalyticsService(dependencies: self)
    lazy var session: Session = SessionManager(dependencies: self)
    lazy var battery: Battery = BatteryService()
    var networkStrength: Network = NetworkStrengthService()
}

// MARK: - Dependencies protocols

protocol HasSession: AnyObject {
    var session: Session { get set }
}

protocol HasApplePay: AnyObject {
    var applePay: ApplePay { get set }
}

protocol HasGameManager: AnyObject {
    var game: GameProtocol { get set }
}

protocol HasConfetti: AnyObject {
    var confetti: Confetti { get set }
}

protocol HasGamePlay: AnyObject {
    var gamePlay: GamePlay { get set }
}

protocol HasApplicationService: AnyObject {
    var application: ApplicationService { get set }
}

protocol HasAnalytics: AnyObject {
    var analytics: AnalyticsService { get set }
}

protocol HasBattery: AnyObject {
    var battery: Battery { get set }
}

protocol HasNetworkStrength: AnyObject {
    var networkStrength: Network { get set }
}
