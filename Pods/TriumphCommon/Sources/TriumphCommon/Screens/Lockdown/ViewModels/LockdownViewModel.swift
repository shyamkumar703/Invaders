// Copyright © TriumphSDK. All rights reserved.

import Foundation

public protocol LockdownViewModelCoordinatorDelegate: Coordinator {
    func lockdownViewModel(_ viewModel: LockdownViewModel, openAppStoreUrl url: URL)
}

public protocol LockdownViewModel {
    /// Message to show on our lockdown screen
    var message: String { get async }
    /// Whether we should include an update button that links to the app store or not
    /// We will display this when a new update is available
    var shouldShowLockdownButton: Bool { get async }
    var updateButtonTitle: String { get }

    /// When update button is tapped, pull app store url for the current app
    func updateButtonTapped()
}

public final class LockdownViewModelImplementation: LockdownViewModel {
    
    public var coordinatorDelegate: LockdownViewModelCoordinatorDelegate?
    
    public typealias Dependencies = HasSharedSession
    private var dependencies: Dependencies
    private var appUrlString: String
    
    public init(dependencies: Dependencies, appUrlString: String) {
        self.dependencies = dependencies
        self.appUrlString = appUrlString
    }
    
    public var message: String {
        get async {
            await dependencies.sharedSession.lockdown?.lockdownScreenMessage ?? "Please update your app!"
        }
    }
    
    public var updateButtonTitle: String {
        "Update"
    }
    
    public var shouldShowLockdownButton: Bool {
        get async {
            await dependencies.sharedSession.lockdown?.shouldShowUpdateButton ?? false
        }
    }
    
    public func updateButtonTapped() {
        if let url = URL(string: appUrlString) {
            coordinatorDelegate?.lockdownViewModel(self, openAppStoreUrl: url)
        }
    }
}
