//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation

public protocol Dependencies:
    HasAppInfo,
    HasSharedSession,
    HasAlertFabric,
    HasLocalization,
    HasLocalStorage,
    HasAuthentication,
    HasNetworkChecker,
    HasSecure,
    HasLogger,
    HasPushNotifications,
    HasSwiftMessage,
    HasPerformance,
    HasNetworkService,
    HasIntercom,
    HasCheatingPreventionService,
    HasLocation
{
    
}

// MARK: - Dependencies protocols

public protocol HasAppInfo: AnyObject {
    var appInfo: AppInfoModel { get }
}

public protocol HasSharedSession: AnyObject {
    var sharedSession: SharedSession { get set }
}

public protocol HasAlertFabric: AnyObject {
    var alertFabric: AlertFabric { get set }
}

public protocol HasLocalStorage: AnyObject {
    var localStorage: LocalStorage { get set }
}

public protocol HasLocalization: AnyObject {
    var localization: Localization { get set }
}

public protocol HasAuthentication: AnyObject {
    var authentication: Authentication { get set }
}

public protocol HasLogger: AnyObject {
    var logger: Logger { get set }
}

public protocol HasNetworkChecker: AnyObject {
    var networkChecker: NetworkChecker { get set }
}

public protocol HasNetworkService: AnyObject {
    var network: NetworkService { get set }
}

public protocol HasSecure: AnyObject {
    var secure: Secure { get set }
}

public protocol HasPushNotifications: AnyObject {
    var pushNotifications: PushNotifications { get set }
}

public protocol HasSwiftMessage: AnyObject {
    var swiftMessage: SwiftMessage { get set }
}

public protocol HasPerformance: AnyObject {
    var performance: PerformanceService { get set }
}

public protocol HasIntercom: AnyObject {
    var intercom: IntercomService { get set }
}

public protocol HasCheatingPreventionService: AnyObject {
    var cheatingPreventionService: CheatingPreventionService { get set }
}

public protocol HasLocation: AnyObject {
    var location: Location { get set }
}

// MARK: - SDKDependencies

open class TriumphDependencies: Dependencies {
    
    public var appInfo: AppInfoModel
    
    public init(appInfo: AppInfoModel) {
        self.appInfo = appInfo
    }

    public lazy var logger: Logger = LoggerService()
    public lazy var secure: Secure = SecureService(dependencies: self)
    public lazy var localization: Localization = LocalizationService()
    public lazy var sharedSession: SharedSession = SharedSessionManager(dependencies: self)
    public lazy var alertFabric: AlertFabric = AlertFabricService(dependecies: self)
    public lazy var localStorage: LocalStorage = LocalStorageService(dependencies: self)
    public lazy var authentication: Authentication = AuthenticationService(dependencies: self)
    public lazy var network: NetworkService = NetworkServiceImplementation(dependencies: self)
    public lazy var networkChecker: NetworkChecker = NetworkCheckerService(dependencies: self)
    public lazy var pushNotifications: PushNotifications = PushNotificationsService(dependencies: self)
    public lazy var swiftMessage: SwiftMessage = SwiftMessageService(dependencies: self)
    public lazy var performance: PerformanceService = PerformanceImplementation(dependencies: self)
    public lazy var intercom: IntercomService = IntercomeServiceImplementation(dependencies: self)
    public lazy var cheatingPreventionService: CheatingPreventionService = CheatingPreventionService()
    public lazy var location: Location = LocationManager(dependencies: self)
}
