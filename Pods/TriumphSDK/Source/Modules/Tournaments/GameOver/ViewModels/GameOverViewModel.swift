// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol GameOverViewModelViewDelegate: AnyObject {
    func gameOverStartPlayButtonLoading()
    func gameOverFinishPlayButtonLoading()
    func gameOverStartLoading()
    func gameOverFinishLoading()
    func paymentAuthorizationViewControllerDidFinish()
    func updatePlayAgainButton()
}

protocol GameOverViewModel {
    var viewDelegate: GameOverViewModelViewDelegate? { get set }
    var tournamentsDashboardViewModel: TournamentsDashboardViewModel { get }
    var gameOverResultViewModel: GameOverResultViewModel { get }
    var startButtonTitle: String { get }
    var isResultReady: Bool { get }
    var animationDuration: AnimationDuration { get }
    
    func startButtonPressed() async -> Bool
    func viewDidLoad()
    func viewDidDisapear()
    func startIntercom()
}

// MARK: - Implementation

class GameOverViewModelImplementation: GameOverViewModel {

    weak var viewDelegate: GameOverViewModelViewDelegate?

    private weak var coordinator: TournamentsCoordinator?
    private var dependencies: AllDependencies
    private var historyModel: GameHistoryModel?

    init(
        coordinator: TournamentsCoordinator,
        dependencies: AllDependencies,
        model: GameHistoryModel?
    ) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        self.historyModel = model
        
        coordinator.viewModelDelegate = self
        dependencies.game.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tokensUpdated),
            name: .tokenBalanceUpdated,
            object: nil
        )
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .tokenBalanceUpdated, object: nil)
        print("DEINIT \(self)")
    }

    lazy var tokens: Int = {
        return dependencies.localStorage.readUser()?.tokenBalance ?? 0
    }()

    var isResultReady: Bool {
        historyModel != nil
    }

    var animationDuration: AnimationDuration {
        let playerScore = historyModel?.player?.score ?? 0
        if historyModel?.state == .waiting && playerScore == 0 {
            return .noAnimation
        }
        return historyModel?.isZeroDraw == true ? .noAnimation : .twoPointFiveSec
    }
    
    var tournamentConfig: TournamentModel? {
        historyModel?.tournamentConfig ?? self.dependencies.game.tournament
    }
    
    var startButtonTitle: String {
        if let tournamentConfig = tournamentConfig {
            return tournamentConfig.entryPrice == 0 ? "Play Free" : "Play again \(tournamentConfig.getPriceAfterTokens(tokens: tokens).formatCurrency())"
        } else {
            return "Play again"
        }
    }
    
    func startIntercom() {
        if let tournamentConfig = historyModel?.tournamentConfig, let id = historyModel?.id {
            dependencies.intercom.showGameIssue(title: tournamentConfig.gameTitle, id: id)
            return
        }
        
        if let id = dependencies.game.gameHistoryModel?.id, let title = dependencies.game.tournament?.gameTitle {
            dependencies.intercom.showGameIssue(title: title, id: id)
            return
        }
    }

    @objc func tokensUpdated(_ notification: Notification) {
        if let tokens = notification.userInfo?["balance"] as? Int {
            self.tokens = tokens
            viewDelegate?.updatePlayAgainButton()
        }
    }
}

// MARK: - View Models

extension GameOverViewModelImplementation {
    var tournamentsDashboardViewModel: TournamentsDashboardViewModel {
        let viewModel = TournamentsDashboardViewModelImplementation(
            coordinator: coordinator,
            dependencies: dependencies,
            screen: .gameOver(0),
            viewDelegate: nil,
            model: historyModel
        )
        viewModel.animationDuration = animationDuration
        return viewModel
    }
    
    var gameOverResultViewModel: GameOverResultViewModel {
        let viewModel = GameOverResultViewModelImplementation(
            dependencies: dependencies,
            model: historyModel
        )
        viewModel.animationDuration = animationDuration
        return viewModel
    }
}

// MARK: - Lifecycle

extension GameOverViewModelImplementation {
    func viewDidLoad() {
        if isResultReady == false {
            viewDelegate?.gameOverStartLoading()
        }
    }
    
    func viewDidDisapear() {
        if isResultReady == false {
            coordinator?.gameOverDidDisapear()
        }
    }
}

// MARK: - Start Button Pressed

extension GameOverViewModelImplementation {
    func startButtonPressed() async -> Bool {
        // TODO: - In the future, we should probably check for matching tournaments by id instead of title
        // FIXME: - Function should not return boolean, use a model property

        dependencies.analytics.logEvent(
            LoggingEvent(
                .playAgainTapped,
                parameters: [
                    "gameType": "async1v1"
                ]
            )
        )

        guard let tournamentModel = tournamentConfig, let id = tournamentModel.id else {
            viewDelegate?.gameOverFinishPlayButtonLoading()
            return false
        }

        let tournamentDefinitions = await dependencies.session.presets.tournamentDefinitions
        if tournamentDefinitions.filter({ $0.id == id }).isEmpty {
            dependencies.logger.log("Tournament definitions ", .warning)
            coordinator?.showTournamentNoLongerOfferedMessage()
            return false
        } else {
            coordinator?.playDidPress(tournamentType: .versus, tournament: tournamentModel, blitz: nil)
            viewDelegate?.gameOverStartPlayButtonLoading()
            return true
        }
    }
}

// MARK: - GameManagerDelegate

extension GameOverViewModelImplementation: GameManagerDelegate {
    func gameRunConfetti() {
        Task { [weak self] in
            if await self?.dependencies.session.gameStates?.hotStreak == 5 {
                self?.coordinator?.runConfettiAndHotStreak()
            } else {
                self?.coordinator?.runConfettiWithAction {}
            }
        }
    }
    
    func gameFinishLoadingData() {
        // FIXME: Show confetti - it should be called from the single place
        viewDelegate?.gameOverFinishLoading()
    }
}

// MARK: - Localization

extension GameOverViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}

// MARK: - TournamentsCoordinatorViewModelDelegate

extension GameOverViewModelImplementation: TournamentsCoordinatorViewModelDelegate {
    func paymentAuthorizationViewControllerDidFinish() {
        viewDelegate?.paymentAuthorizationViewControllerDidFinish()
    }
    
    func tournamentCoordinatorFinishLoading() {
        viewDelegate?.gameOverFinishPlayButtonLoading()
    }
}
