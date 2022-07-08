// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

enum BlitzState: Equatable {
    case start
    case finish
    case history(game: GameHistoryModel?)
}

// MARK: - Delegate

protocol BlitzViewModelViewDelegate: BaseViewModelViewDelegate {
    func blitzBuyInDidUpdate()
    func blitzDidShowLoading()
    func blitzDidHideLoading()
    func segmentedControlItemsDidUpdate()
}

// MARK: - View Model

protocol BlitzViewModel {
    var viewDelegate: BlitzViewModelViewDelegate? { get set }
    var title: String { get }
    var isGameFinished: Bool { get }
    var subTitle: String { get }
//    var segmentControlItems: [String] { get }
    var segmentControlSelectedItem: Int { get }
    var scoreTitle: String { get }
    var prizeTitle: String { get }
    var startButtonTitle: String { get }
    var infographicViewModel: BlitzInfographicViewModel? { get }

    func segmentControlChanged(index: Int)
    func startButtonPressed()
    func infoButtonPressed()
    func prepareBlitzSeed() -> TriumphRNG?
    func viewDidDisapear()
    func getSegmentControlItems() async -> [String]
}

// MARK: - Impl.

final class BlitzViewModelImplementation: BlitzViewModel {

    // TODO: - update blitzmode data
    weak var viewDelegate: BlitzViewModelViewDelegate?
    private weak var coordinator: TournamentsCoordinator?
    private var dependencies: AllDependencies
    private var state: BlitzState
    private var segmentItems: [Int] = [] {
        didSet(old) {
            segmentControlSelectedItem = getSelectedControlItemIndex()
            if old.isEmpty && !segmentItems.isEmpty {
                viewDelegate?.segmentedControlItemsDidUpdate()
            }
            infographicViewModel?.selectedAmount = selectedAmount ?? 5
            viewDelegate?.blitzBuyInDidUpdate()
        }
    }

    lazy var segmentControlSelectedItem: Int = getSelectedControlItemIndex() {
        didSet {
            viewDelegate?.blitzBuyInDidUpdate()
            if segmentControlSelectedItem < segmentItems.count {
                infographicViewModel?.updateContent(
                    with: Double(segmentItems[segmentControlSelectedItem]) / 100
                )
            }
        }
    }
    
    init(
        coordinator: TournamentsCoordinator,
        dependencies: AllDependencies,
        state: BlitzState
    ) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        self.state = state

        coordinator.viewModelDelegate = self

        setupInfographicViewModel()
        infographicViewModel?.setBlitzDelegate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(percentileUpdated), name: .percentileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(segmentedControlItemsFetched), name: .blitzDefinitionsFetched, object: nil)
    }
    
    deinit {
        print("DEINIT \(self)")
        NotificationCenter.default.removeObserver(self, name: .percentileUpdated, object: nil)
    }

    var infographicViewModel: BlitzInfographicViewModel?
    
    var title: String {
        switch state {
        case .finish:
            return GameManager.getBlitzPayoutForScore(totalScore: dependencies.game.score)
        case .start:
            return "Blitz ⚡"
        case .history(let game):
            let winnings = game?.blitzConfig?.payout ?? 0
            return (winnings / 100.0).formatCurrency()
        }
    }
    
    var subTitle: String {
        let moneyAmt = selectedAmount?.formatCurrency() ?? ""
        return "Buy in: \(moneyAmt)"
    }

    var scoreTitle: String {
        "Score"
    }
    
    var prizeTitle: String {
        "Prize"
    }
    
//    var segmentControlItems: [String] {
//        Dummy.Blitz.segmentItems.map { "$\(Int($0))" }
//    }
    
    var startButtonTitle: String {
        "Play \(selectedAmount?.formatCurrency() ?? "")"
    }
    
    var isGameFinished: Bool {
        state != .start
    }
    
    var seed: TriumphRNG?

    func startButtonPressed() {
        if state == .finish {
            dependencies.analytics.logEvent(
                LoggingEvent(
                    .playAgainTapped,
                    parameters: [
                        "gameType": "blitz"
                    ]
                )
            )
        }
        
        viewDelegate?.blitzDidShowLoading()
        
        GameManager.setRandomSeedIntegerRaw(seed: Int(prepareBlitzSeed()?.seed ?? 0))
        
        Task.init(priority: .userInitiated) { [weak self] in
            await dependencies.session.removeBlitzListener()
            let blitz = BlitzModel(
                score: 0,
                entryPrice: selectedAmount ?? 1,
                seed: prepareBlitzSeed()?.seed,
                multipliers: GameManager.blitzScoreArray
            )
            
            dependencies.game.setBlitzAmount(blitzBuyIn: Double(selectedAmount ?? 1))
            coordinator?.playDidPress(tournamentType: .blitz, tournament: nil, blitz: blitz)
        }
    }
    
    func segmentControlChanged(index: Int) {
        segmentControlSelectedItem = index
    }
    
    func infoButtonPressed() {
        switch state {
        case .start:
            handleInfoButtonTap()
        case .finish:
            dependencies.intercom.showGameIssue(
                title: "Blitz \(selectedAmount?.formatCurrency() ?? "")",
                id: dependencies.game.tournamentResponseId
            )
        case .history(let game):
            dependencies.intercom.showGameIssue(
                title: "Blitz \(selectedAmount?.formatCurrency() ?? "")",
                id: game?.id
            )
        }
    }
    
    // Prepares blitz random seed as the current hour of the date time
    
    /*
     * Prepares the blitz RNG for the blitz game. The way we seed blitz is as follows:
     *
     * 1. Take the current hour. This is our "Default Base Seed." This will increase once an hour
     * 2. Compute a window of +- 2 from the default seed.
     * 3. Each game, we will cycle through this window. Eg. first game, we will do the first one, second game we will do the second, etc. We mod by 5 to ensure we're in range.
     *    We store this in localStorage to keep persistence between games.
     * 4. Each hour, because all seeds increase, we throw out one game grid and add one new one. This is to make the distribution have smoothness
     */
    func prepareBlitzSeed() -> TriumphRNG? {
        
//        guard let serverTime = GameManager.blitzTimestamp else { return nil }
        
        let time1 = Date(timeIntervalSince1970: 1)
        let time2 = Date()
        let difference = Calendar.current.dateComponents([.hour], from: time1, to: time2)
        let baseSeed = difference.hour
        
        guard let baseSeed = baseSeed else {
            return nil
        }
        
        // 2.
        let seeds = [baseSeed - 2, baseSeed - 1, baseSeed, baseSeed + 1, baseSeed + 2]
        var chosenSeed = 0
        
        // 3.
        let gameNumberData = dependencies.localStorage.getBlitzSeedCycleValue()
        
        if var gameNumberData = gameNumberData {
            chosenSeed = seeds[gameNumberData.gameNumber % 5]
            gameNumberData.gameNumber += 1
            dependencies.localStorage.updateBlitzSeedCycleValue(gameNumberData)
        } else {
            chosenSeed = seeds[0]
            let gameNumberData = BlitzSeedCycleData(gameNumber: 1)
            dependencies.localStorage.updateBlitzSeedCycleValue(gameNumberData)
        }
        return TriumphRNG(seed: UInt64(chosenSeed))
    }
    
    func getSegmentControlItems() async -> [String] {
        let definitions = await dependencies.session.blitzDefinitions.sorted(by: { $0.entryPrice ?? 0 < $1.entryPrice ?? 0 })
        segmentItems = definitions.compactMap { $0.entryPrice }
        return definitions.compactMap {
            if let entryPrice = $0.entryPrice { return "\(entryPrice.formatCurrency())"}
            return nil
        }
    }
    
    @objc func segmentedControlItemsFetched() {
        Task { [weak self] in
            await self?.getSegmentControlItems()
        }
    }
}

private extension BlitzViewModelImplementation {
    var selectedAmount: Double? {
        segmentControlSelectedItem < segmentItems.count ? Double(segmentItems[segmentControlSelectedItem]) / 100 : nil
    }
    
    var blitzItems: [BlitzModel] {
        Dummy.Blitz.blitzItems.map { BlitzModel(score: $0, entryPrice: $1) }
    }
    
    func setupInfographicViewModel() {
        self.infographicViewModel = BlitzInfographicViewModelImplementation(
            dependencies: dependencies,
            selectedAmount: selectedAmount ?? 5,
            state: state
        )
        self.infographicViewModel?.delegate = self
    }
    
    func handleInfoButtonTap() {
        dependencies.swiftMessage.showBlitzModeInfoMessage()
    }
    
    func getSelectedControlItemIndex() -> Int {
        let amount: Double
        switch state {
        case .history(let game):
            amount = Double(game?.blitzConfig?.tournamentDefinition?.entryPrice ?? 1)
            return segmentItems.firstIndex(of: Int(amount)) ?? 1
        default:
            amount = GameManager.amount / 100
            return segmentItems.firstIndex(of: Int(amount * 100)) ?? 1
        }
    }

    func play() {
        coordinator?.startCountdown()
        coordinator?.startGameDelegate = self
    }
    
    @objc func percentileUpdated() {
        Task { [weak self] in
            if let blitzDataPoints = try? await self?.dependencies.session.getBlitzDataPoints() {
                await self?.dependencies.game.getBucket(response: blitzDataPoints)
                infographicViewModel?.updateContent(with: Double(segmentItems[segmentControlSelectedItem]) / 100)
            }
            
        }
    }
}

// MARK: - Localization

extension BlitzViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
    func viewDidDisapear() {
        coordinator?.gameOverDidDisapear()
    }
}

// MARK: - TournamentsCoordinatorViewModelDelegate

extension BlitzViewModelImplementation: TournamentsCoordinatorViewModelDelegate {
    func paymentAuthorizationViewControllerDidFinish() {
        viewDelegate?.blitzDidHideLoading() // need to continue loading
    }

    func tournamentDidStartPlayBlitz() {
        play()
    }
    
    func messageDidPresent() {
        viewDelegate?.blitzDidHideLoading()
    }

    func startBlitzLoading() {
        viewDelegate?.blitzDidShowLoading()
    }
    
    func tournamentCoordinatorFinishLoading() {
        viewDelegate?.blitzDidHideLoading()
    }
}

// MARK: - TournamentsCoordinatorStartGameDelegate

extension BlitzViewModelImplementation: TournamentsCoordinatorStartGameDelegate {
    @MainActor func gameAboutToStart() {
        guard let triumphRNG = dependencies.game.getRandomSeed() else {
            return
        }
        dependencies.triumphDelegate?.triumphGameDidStart(rngGenerator: triumphRNG)
    }
}

extension BlitzViewModelImplementation: BlitzInfographicViewModelDelegate {
    func blitzInfographicRunConfetti() {
        coordinator?.runConfettiWithAction {}
    }
}
