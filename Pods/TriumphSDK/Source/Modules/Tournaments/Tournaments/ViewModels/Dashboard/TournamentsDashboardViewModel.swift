// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol TournamentsDashboardViewModelDelegate: DashboardAccountViewModelDelegate {}

protocol TournamentsDashboardViewDelegate: AnyObject {
    func balanceDidUpdate()
    func tokenBalanceDidUpdate()
    func hotstreakDidUpdate ()
}

protocol TournamentsDashboardViewModel: TournamentsCellViewModel {

    // MARK: General
    var screen: TournamentScreen { get }
    var viewDelegate: TournamentsDashboardViewDelegate? { get set }

    // MARK: Balance Info
    var balanceTitle: String { get }
    var hotStreakTitle: String { get }
    var balanceAmount: Double { get }
    var streak: [Bool] { get }
    var balanceAdditionalInfo: FlexibleString { get }
    var dashboardAccountViewModel: DashboardAccountViewModel { get }
    var gameOverWinViewModel: GameOverWinViewModel { get }
    
    func cashOutPressed()
    func depositPressed()
}

// MARK: - Impl.

final class TournamentsDashboardViewModelImplementation: TournamentsDashboardViewModel {
   // var dashboardHotStreakViewModel: DashboardHotStreakViewModel
    

    private weak var coordinator: TournamentsCoordinator?
    private var dependencies: AllDependencies
    var animationDuration: AnimationDuration?
    var screen: TournamentScreen
    weak var tournamentsViewDelegate: TournamentsViewModelViewDelegate?
    weak var viewDelegate: TournamentsDashboardViewDelegate?
    weak var delegate: TournamentsDashboardViewModelDelegate?
    private let notificationCenter = NotificationCenter.default

    private var historyModel: GameHistoryModel?

    init(
        coordinator: TournamentsCoordinator?,
        dependencies: AllDependencies,
        screen: TournamentScreen,
        viewDelegate: TournamentsViewModelViewDelegate?,
        model: GameHistoryModel? = nil
    ) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        self.screen = screen
        self.tournamentsViewDelegate = viewDelegate
        self.historyModel = model
        
        retrieveBalance()
        retrieveBalanceAdditionalInfo()
        setHotStreak()
        
        notificationCenter.addObserver(self, selector: #selector(balanceUpdated), name: .balanceUpdated, object: nil)
        notificationCenter.addObserver(self, selector: #selector(tokenBalanceUpdated), name: .tokenBalanceUpdated, object: nil)
        notificationCenter.addObserver(self, selector: #selector(hotstreakUpdated), name: .hotstreak, object: nil)
        notificationCenter.addObserver(self, selector: #selector(infoTapped), name: .hotstreakInfoButton, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .balanceUpdated, object: nil)
        notificationCenter.removeObserver(self, name: .tokenBalanceUpdated, object: nil)
        notificationCenter.removeObserver(self, name: .hotstreak, object: nil)
        notificationCenter.removeObserver(self, name: .hotstreakInfoButton, object: nil)
    }

    lazy var dashboardAccountViewModel: DashboardAccountViewModel = {
        let viewModel = DashboardAccountViewModelImplementation(
            coordinator: coordinator,
            dependencies: dependencies
        )
        viewModel.delegate = self
        return viewModel
    }()

    lazy var gameOverWinViewModel: GameOverWinViewModel = {
        let amount = historyModel?.resultStatus == .lost
            ? historyModel?.potAmount
            : historyModel?.wonAmount

        let state = historyModel?.state ?? dependencies.game.gameHistoryModel?.state
        let viewModel = GameOverWinViewModelImplementation(
            dependencies: dependencies,
            amount: amount,
            status: historyModel?.resultStatus,
            isWaitingOpponent: state == .waiting
        )
        viewModel.animationDuration = animationDuration
        return viewModel
    }()
    
    var balanceTitle: String {
        "Cash balance"
    }
    
    var balanceAmount: Double = 0 {
        didSet {
            viewDelegate?.balanceDidUpdate()
        }
    }

    var balanceAdditionalInfo: FlexibleString = .attributedString(0.formatTokens(tintColor: .lightGreen)) {
        didSet {
            viewDelegate?.tokenBalanceDidUpdate()
        }
    }
    
    var hotStreakTitle: String {
            "Hot Streak"
        }
    
//    private var hotstreak: Int = 0
    
    var streak: [Bool] = [Bool](repeatElement(false, count: Constants.HOT_STREAK_COUNT)) {
        didSet {
            viewDelegate?.hotstreakDidUpdate()
        }
    }
    
    @objc func balanceUpdated() {
        dependencies.logger.log("balance did update", .warning)
        retrieveBalance()
    }
    
    @objc func tokenBalanceUpdated() {
        dependencies.logger.log("token balance did update", .warning)
        retrieveBalanceAdditionalInfo()
    }
    
    @objc func hotstreakUpdated(_ notification: Notification) {
        setHotStreak()
    }
    
    @objc
    func infoTapped() {
         dependencies.swiftMessage.showHotStreakInfoMessage()
    }
    
    func retrieveBalanceAdditionalInfo() {
        Task { [weak self] in
            switch screen {
            case .tournaments:
                if let tokens = await self?.dependencies.sharedSession.user?.tokenBalance {
                    self?.balanceAdditionalInfo = .attributedString(tokens.formatTokens(tintColor: .lightGreen, shouldIncludeWordTokens: true))
                } else {
                    self?.balanceAdditionalInfo = .attributedString(0.formatTokens(tintColor: .lightGreen, shouldIncludeWordTokens: true))
                }
            default:
                if let tokens = await self?.dependencies.sharedSession.user?.tokenBalance {
                    self?.balanceAdditionalInfo = .attributedString(tokens.formatTokens(tintColor: .lightGreen))
                } else {
                    self?.balanceAdditionalInfo = .attributedString(0.formatTokens(tintColor: .lightGreen))
                }
            }
        }
    }
    
    func retrieveBalance() {
        Task { [weak self] in
            let isAuthenticated = await self?.dependencies.sharedSession.isSignedUp
            let balance = await self?.dependencies.sharedSession.user?.balance ?? 0
            let balanceAmount = isAuthenticated == true ? Double(balance) / 100.0 : 0
            // let balanceFormat = String(format: "%.2f", balanceAmount)
            self?.balanceAmount = balanceAmount
        }
    }
    
    func setHotStreak() {
        Task { [weak self] in
            let isAuthenticated = await self?.dependencies.sharedSession.isSignedUp
            let hotstreak = await self?.dependencies.session.gameStates?.hotStreak ?? 0
        
            var hotStreakValues: [Bool] = [Bool](repeatElement(false, count: hotstreak ?? Constants.HOT_STREAK_COUNT))
            hotStreakValues.removeAll()
            
            if hotstreak > 0 {
                for _ in 1...hotstreak {
                    hotStreakValues.append(true)
                }
            }
            
            if( 5 - hotstreak != 0) {
                for _ in 1...(5 - hotstreak) {
                    hotStreakValues.append(false)
                }
            }

            self?.streak = isAuthenticated == true ? hotStreakValues : [Bool](repeatElement(false, count: hotstreak ?? Constants.HOT_STREAK_COUNT))
        }
    }
    
    func cashOutPressed() {
        Task { @MainActor [weak self] in
            self?.coordinator?.cashout()
        }
    }
    
    func depositPressed() {
        Task { @MainActor [weak self] in
            self?.coordinator?.showDepositSheet()
        }
    }
}

// MARK: - DashboardAccountViewModelDelegate

extension TournamentsDashboardViewModelImplementation: DashboardAccountViewModelDelegate {
    func dashboardAccountStartLoading() {
        delegate?.dashboardAccountStartLoading()
    }
    
    func dashboardAccountFinishLoading() {
        delegate?.dashboardAccountFinishLoading()
    }
    
    func depositDidPress() {
        delegate?.depositDidPress()
    }
}

// MARK: - Localization

private extension TournamentsDashboardViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
