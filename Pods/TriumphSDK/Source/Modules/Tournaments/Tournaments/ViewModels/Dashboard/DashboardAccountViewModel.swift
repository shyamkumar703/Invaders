// Copyright © TriumphSDK. All rights reserved.

import UIKit

typealias DashboardButtonContent = (icon: String, title: String)

protocol DashboardAccountViewModelDelegate: AnyObject {
    func dashboardAccountStartLoading()
    func dashboardAccountFinishLoading()
    func depositDidPress()
}

protocol DashboardAccountViewModel {
    var title: String { get }
    var subtitle: String { get }
    var delegate: DashboardAccountViewModelDelegate? { get set }
    var depositButtonContent: DashboardButtonContent { get }
    var cashOutButtonContent: DashboardButtonContent { get }
    func depositButtonPress()
    func cashOutButtonPress()
}

// MARK: - Impl.

final class DashboardAccountViewModelImplementation: DashboardAccountViewModel {
    
    private weak var coordinator: TournamentsCoordinator?
    weak var delegate: DashboardAccountViewModelDelegate?

    private var dependencies: AllDependencies
    
    init(coordinator: TournamentsCoordinator?, dependencies: AllDependencies) {
        self.coordinator = coordinator
        self.dependencies = dependencies
    }
    
    var title: String {
        "Account"
    }
    
    var subtitle: String {
        "Cash out anytime"
    }
    
    var depositButtonContent: DashboardButtonContent {
        (icon: "square.and.arrow.down.fill", title: "Deposit")
    }
    
    var cashOutButtonContent: DashboardButtonContent {
        (icon: "square.and.arrow.up.fill", title: "Cash Out")
    }
    
    func depositButtonPress() {
        self.delegate?.depositDidPress()
    }
    
    func cashOutButtonPress() {
        coordinator?.cashout()
    }
}

private extension DashboardAccountViewModelImplementation {

}

// MARK: - Localization

private extension DashboardAccountViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
