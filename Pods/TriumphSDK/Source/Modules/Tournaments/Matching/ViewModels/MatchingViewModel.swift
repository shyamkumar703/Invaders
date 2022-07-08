// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon
import UIKit

// MARK: - View Model

protocol MatchingViewModel: BaseViewModel {
    var matchingViewModel: MatchingPlayersViewModel { get }
    var startButtonTitle: String { get }
    var items: [(icon: String, title: String)] { get }
    var matchingConditionViewModels: [MatchingConditionViewModel] { get }
    func startButtonPressed()
}

// MARK: - Implementation

final class MatchingViewModelImplementation: MatchingViewModel {

    private weak var coordinator: TournamentsCoordinator?
    var dependencies: AllDependencies
    
    init(coordinator: TournamentsCoordinator, dependencies: AllDependencies) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        self.dependencies.networkChecker.stop()
    }
    
    deinit {
        print("DEINIT \(self)")
    }

    var matchingViewModel: MatchingPlayersViewModel {
        MatchingPlayersViewModelImplementation(dependencies: dependencies)
    }
    
    var startButtonTitle: String {
        localizedString(Content.Matching.buttonStartTitle)
    }
    
    var items: [(icon: String, title: String)] {
        Content.Matching.items.map { ($0.0, localizedString($0.1)) }
    }
    
    lazy var matchingConditionViewModels: [MatchingConditionViewModel] =  {
        MatchingCondition.allCases.map { MatchingConditionViewModel(condition: $0, dependencies: dependencies) }
    }()

    func startButtonPressed() {
        coordinator?.startCountdown()
        coordinator?.startGameDelegate = self
        NotificationCenter.default.post(name: .stopMatchingHaptics, object: nil)
    }

    func showRngErrorAlert() {
        let alert = AlertModel(
            title: localizedString(Content.Matching.error),
            message: localizedString(Content.Matching.rngError),
            okButtonTitle: commonLocalizedString("btn_close_title")
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
}

// MARK: - TournamentsCoordinatorStartGameDelegate

extension MatchingViewModelImplementation: TournamentsCoordinatorStartGameDelegate {
    @MainActor func gameAboutToStart() {
        if let rngGenerator = self.dependencies.game.getRandomSeed() {
            self.dependencies.triumphDelegate?.triumphGameDidStart(rngGenerator: rngGenerator)
        } else {
            self.showRngErrorAlert()
        }
    }
}
