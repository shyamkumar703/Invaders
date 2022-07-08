// Copyright © TriumphSDK. All rights reserved.

import Foundation
import PassKit
import StoreKit
import TriumphCommon

enum TournamentsSection {
    case dashboard(TournamentsDashboardViewModel)
    case missions(TournamentsMissionsCellViewModel)
    case blitz(TournamentsBlitzCellViewModel)
    case tournaments(TournamentsVersusSectionViewModel)
    case history(TournamentsHistorySectionViewModel)
    case welcome(WelcomeRewardCellViewModel)
    case liveMessage(TournamentsLiveCellViewModel)
    case otherGames(TournamentsOtherGamesCellViewModel)
}

enum AuthType {
    case buyIn
    case deposit
    case getBlitzData
}

// MARK: - Delegates

protocol TournamentsViewModelDelegate: AnyObject {

}

protocol TournamentsViewModelViewDelegate: BaseViewModelViewDelegate {
    func tournamentsReload()
}

// MARK: - View Model

protocol TournamentsViewModel {
    
    // Connection to the TournamentsView(s)
    var viewDelegate: TournamentsViewModelViewDelegate? { get set }

    /// Sections
    /// 1. Dashboard - We try not to reload this through the tableview to redice flickering visible to the user
    /// 2. LiveBar
    /// 3. Missions / Welcome amount - We try not to reload this through the tableview to redice flickering visible to the user
    /// 4. Blitzmode - this cell never changes
    /// 5. Tounaments config - This is the first completely generated cell based on data from the server. this should NEVER be blank
    /// 6. History
    func getSection(at index: Int) -> TournamentsSection?
    var numberOfSections: Int { get }
    
    //If this is nonzero then a cell header is expected to be deququed
    func getSectionHeight(at index: Int) -> Int
    
    func getCellHeight(at index: Int) -> Int
    func getMinimumLineSpacingForSection(at index: Int) -> Int
    func getNumberOfItems(at index: Int) -> Int
    
    /// Properly deals with cells being tapped
    /// - Parameter indexPath: the index path that has been tapped
    func didSelectItem(at indexPath: IndexPath)
    func supportButtonTap()

    func didFinish()
    func viewDidLoad()
}

protocol TournamentsSectionViewModel {}
protocol TournamentsCellViewModel {}

// MARK: - Implementation

// Sections is the dataSource of the main collection view of the app
// Sections changes from non-user-initiated input and therefore is exposted to risk of a data - race
// Currently sections is set every time the datasource is updated
// When the tableview is reloaded sections is read and put into the tableView's true datasource on the main actor,
// the main actor can be thought about like a single thread,
// this makes the process thread safe

actor Sections {
    var sections: [TournamentsSection] = []
    
    init(sections: [TournamentsSection] = []) {
        self.sections = sections
    }
    
    func append(_ section: TournamentsSection) {
        sections.append(section)
    }

    func `prefix`(upTo: Int) -> [TournamentsSection] {
        return Array(sections.prefix(upTo: upTo))
    }
}

final class TournamentsViewModelImplementation: TournamentsViewModel {
    
    weak var viewDelegate: TournamentsViewModelViewDelegate?
    private weak var coordinator: TournamentsCoordinator?
    var dependencies: AllDependencies
    
    private var type: TournamentType = .versus {
        didSet {
            dependencies.game.setTournamentType(type)
        }
    }
    
    private var entryPriceToPurchase: Double?
    private var gameTitleToPurchase: String?
    private var authType: AuthType?
    private var isWelcomeCellCollapsed: Bool = false
    
    private var tournamentToPurchase: TournamentModel?
    private var blitzToPurchase: BlitzModel?
    private var historyDict: SplitedByDateHistoryDict?
    private var stopUserObserver: Bool = false
    private var hasRunViewDidLoad: Bool = false

    init(coordinator: TournamentsCoordinator, dependencies: AllDependencies) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        coordinator.delegate = self
        dependencies.networkChecker.start()
        dependencies.networkChecker.startTestConnectionSpeed()
        dependencies.networkChecker.delegate = self
        
        prepareViewModels()

        // Need to set delegates here so that when the tutorial runs they are still set, eventhough view did load does not run
        Task { [weak self] in
            await self?.dependencies.sharedSession.delegate = self
            await self?.dependencies.session.delegate = self
            await self?.dependencies.session.prepareSession()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sectionsUpdated),
            name: .tournamentsSectionsUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showApplePay),
            name: .showApplePay,
            object: nil
        )
    }
    
    // Reading from sections and updating the dataSource on a single thread prevents any dataraces on the tableview datasource
    @objc func sectionsUpdated() {
        Task { @MainActor [weak self] in
            dataSource = await self?.sections.sections ?? dataSource
            viewDelegate?.tournamentsReload()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .historyUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .tournamentsSectionsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .showApplePay, object: nil)

        dependencies.networkChecker.stop()
        
        print("DEINIT \(self)")
    }

    private var balance: Double {
        Double(dependencies.localStorage.readUser()?.balance ?? 0) / 100.0
    }
    
    var sections = Sections()
    
    // The datasource for the main collection view
    var dataSource: [TournamentsSection] = []
    
    var numberOfSections: Int {
//        sections.count
        dataSource.count
    }
}

// MARK: - Prepare View Model

extension TournamentsViewModelImplementation {
    
    // Each cell has a view model, this sets them up
    func prepareViewModels() {
        Task { [weak self] in
            await self?.prepareDashboardViewModel()
//            await self?.prepareMissionsViewModel()
            await self?.prepareLiveMessageViewModel()
            await self?.prepareBlitzCellViewModel()
            await self?.prepareTournamentsVersusSectionViewModel()
            await self?.prepareOtherGamesViewModel()
            await self?.prepareHistorySectionViewModels()
        }
    }
    
    func prepareOtherGamesViewModel() async {
        let viewModel = TournamentsOtherGamesCellViewModel(dependencies: dependencies, coordinator: coordinator)
        viewModel.items = await dependencies.session.otherGames
            .filter { $0.appStoreURL != nil && $0.image != nil && $0.gameId != dependencies.appInfo.id }
            .map({ OtherGamesCollectionViewModel(
                otherGame: $0,
                dependencies: dependencies,
                imageType: $0.imageType ?? .link
            )
        })
        await sections.append(.otherGames(viewModel))
    }
    
    func prepareLiveMessageViewModel() async {
        let viewModel = TournamentsLiveCellViewModelImplementation(
            dependencies: dependencies
        )
        await sections.append(.liveMessage(viewModel))
    }
    
    // On the first open right after login the unclaimedBalance is claimed by hitting an endpoint
    func runFirstOpen() {
        Task { [weak self] in
            if await self?.dependencies.sharedSession.user?.unclaimedBalance != nil {
                self?.stopUserObserver = true
                do {
                    
                    try await self?.dependencies.session.claimUnclaimedBalance()
                    self?.dependencies.analytics.logEvent(LoggingEvent(.claimOnboardingReward))
                    self?.stopUserObserver = false
                } catch {
                    self?.dependencies.logger.log("otpSignup-claimUnclaimedBalance", .error)
                    self?.stopUserObserver = false
                }
            }
        }

    }
    
    // Makes the missions viewModel and adds it to sections
    @discardableResult func prepareMissionsViewModel(append: Bool = true, shouldRetrieve: Bool = true) async -> TournamentsSection {
        let viewModel = TournamentsMissionsCellViewModelImplementation(
            dependencies: dependencies,
            coordinator: coordinator
        )
        if append { await sections.append(.missions(viewModel)) }
        return .missions(viewModel)
    }
    
    // Makes the dashboard viewModel and adds it to sections
    func prepareDashboardViewModel() async {
        let viewModel =  TournamentsDashboardViewModelImplementation(
            coordinator: coordinator,
            dependencies: dependencies,
            screen: .tournaments,
            viewDelegate: viewDelegate
        )
        viewModel.delegate = self
        await sections.append(.dashboard(viewModel))
    }
    
    // Makes the blitz viewModel and adds it to sections
    func prepareBlitzCellViewModel() async {
        let viewModel = TournamentsBlitzCellViewModelImplementation(dependencies: dependencies)
        viewModel.delegate = self
        await sections.append(.blitz(viewModel))
    }
    
    // Makes the TournamentsVersus viewModel
    func prepareTournamentsVersusSectionViewModel() async {
        var tournamentsVersusSectionViewModel: TournamentsVersusSectionViewModel = TournamentsVersusSectionViewModelImplementation(
            dependencies: self.dependencies,
            coordinator: coordinator
        )
        tournamentsVersusSectionViewModel.delegate = self
        await sections.append(.tournaments(tournamentsVersusSectionViewModel))
    }
}

// MARK: - Methods

extension TournamentsViewModelImplementation {
    
    // Set the delegate and load new data when we hit the TournamentsView
    func viewDidLoad() {
        Task { [weak self] in
            await self?.dependencies.sharedSession.delegate = self
            await self?.dependencies.session.delegate = self
            await self?.dependencies.session.prepareSession()
        }
    
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.gamesHistoryDidUpdate(_:)),
            name: .historyUpdate,
            object: nil
        )
    }
    
    @objc func gamesHistoryDidUpdate(_ notification: Notification) {
        Task { [weak self] in
            guard await self?.dependencies.sharedSession.isSignedUp == true,
                  let historyDict = notification.object as? SplitedByDateHistoryDict else {
                return
            }

            self?.historyDict = historyDict
            
            await self?.prepareHistorySectionViewModels()
        }
    }
    
    /// Adds the incoming history data into the datasource
    /// Makes sure not to change any of the static sections
    func prepareHistorySectionViewModels() async {
       // removeAllHistorySections()
        Task { @MainActor [weak self] in
            let splitedHistoryModels = self?.historyDict?.map { [weak self] in
                TournamentsHistorySectionViewModelImplementation(
                    title: $0.key,
                    models: $0.value,
                    coordinator: self?.coordinator,
                    dependencies: self?.dependencies ?? TriumphSDK.dependencies
                )
            }
            .sorted { $0.date > $1.date }
            var newSections: [TournamentsSection] = await self?.sections.prefix(upTo: 5) ?? []
            splitedHistoryModels?.forEach {
                newSections.append(.history($0))
            }
          
            self?.sections = Sections(sections: newSections)
            self?.dataSource = await self?.sections.sections ?? dataSource
            self?.viewDelegate?.tournamentsReload()
        }
    }

    // Get sections refers to the datasource not sections because datasource is the datasource for the collection view.
    // Sections is just a layer to handle multiple data incoming at the same time.
    func getSection(at index: Int) -> TournamentsSection? {
//        sections.indices.contains(index) ? sections[index] : nil
        dataSource.indices.contains(index) ? dataSource[index] : nil
    }

    func didFinish() {
        coordinator?.didFinish()
    }
    
    /*
     If the we get an error, the user should try again immediately.
     Decrypting the Apple Pay token can create an error in very rare cases.
     This is NOT due to the fact that we are now decrypting in our own system (this is how every payment processor needs to handle Apple Pay payments as well)
     Generally speaking, trying again will fix this issue (outside of Internet connectivity problems, etc.)
     */
    func prepareApplePayErrorMessage(with error: ApplePayError) -> String {
        viewDelegate?.hideLoadingProcess()
        switch error {
        case .checkoutError:
            return localizedString(Content.ApplePay.checkoutErrorMsg)
        case .requestError:
            return localizedString(Content.ApplePay.requestErrorMsg)
        case .applePayControllerError:
            return localizedString(Content.ApplePay.controllerErrorMsg)
        }
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        switch getSection(at: indexPath.section) {
        case .history(let viewModel):

            let historyViewModel = viewModel.items[indexPath.row]
            if historyViewModel.type == .deposit {
                depositDidPress()
            }
            
            if historyViewModel.type == .hotStreak {
                dependencies.swiftMessage.showHotStreakInfoMessage()
            }

            if historyViewModel.type == .accountCreationDeposit {
                if let historyModel = historyViewModel.getHistoryModel(ofType: DepositHistoryModel.self) {
                    dependencies.swiftMessage.showWelcomeRewardClaimedMessage(
                        unclaimedBalance: Int(historyModel.amount * 100)
                    )
                }
            }
            
            if historyViewModel.type == .mission {
                // show mission completed message
                if let historyModel = historyViewModel.getHistoryModel(ofType: DepositHistoryModel.self) {
                    dependencies.swiftMessage.showMissionCompletedMessage(
                        mission: depositToMissionModel(depositModel: historyModel)
                    )
                }
            }
            
            if historyViewModel.type == .referral {
                dependencies.swiftMessage.showReferralCompletedSwiftMessage()
            }
            
            if historyViewModel.type == .newGame {
                if let model = historyViewModel.model as? DepositHistoryModel {
                    guard let tokenAmount = model.tokenAmount else { return }
                    guard let game = model.game else { return }
                    dependencies.swiftMessage.showNewGameRewardMessage(gameId: game, reward: tokenAmount)
                }
            }
            
            guard let id = historyViewModel.id else {
                dependencies.logger.log("History view model ID - Nil", .warning)
                return
            }
            Task { [weak self] in
                let game = await self?.dependencies.session.allGamesHistory.first { $0.id == id }
                switch game?.gameType {
                case .blitz:
                    viewDelegate?.showLoadingProcess()
                    NotificationCenter.default.removeObserver(self)
                    Task { [weak self] in
                        do {
                            try await self?.dependencies.game.startObserveBlitzDataPoints()
                            await MainActor.run { [weak self] in
                                self?.coordinator?.blitz(state: .history(game: game))
                                self?.viewDelegate?.hideLoadingProcess()
                            }
                        } catch {
                            self?.dependencies.logger.log("Start Observe Blitz Data Points error", .error)
                            await MainActor.run { [weak self] in
                                self?.viewDelegate?.hideLoadingProcess()
                            }
                        }
                    }
                case .versus:
                    self?.coordinator?.gameOver(with: game)
                default: return
                }
            }
            return
        default: return
        }
    }
    
    func prepareApplePayErrorAlert(with error: ApplePayError) {
        dependencies.swiftMessage.showErrorMessage(
            title: "Error",
            message: prepareApplePayErrorMessage(with: error)
        )
    }
    
    func handleItemPlayPress() {
        viewDelegate?.showLoadingProcess()
        coordinator?.checkEligibility { [weak self] isEligible in
            guard let self = self else { return }
            
            if isEligible == true {
                self.handleItemPlayPressIfEligable()
                return
            }
            self.viewDelegate?.hideLoadingProcess()
            self.coordinator?.viewModelDelegate?.tournamentCoordinatorFinishLoading()
        }
    }
    
    // Check if a user isAuthenticated before letting them pay for a game
    func handleItemPlayPressIfEligable() {
        Task { [weak self] in
            
            guard await dependencies.networkChecker.isConnectionGood() else {
                return
            }
            
            if await self?.dependencies.sharedSession.isSignedUp == false {
                self?.coordinator?.startAuthentication()
            } else {
                self?.startPayForGame()
            }
        }
    }
    
    func prepareLocationErrorAlert() {
        viewDelegate?.hideLoadingProcess()
        dependencies.swiftMessage.showErrorMessage(
            title: "Error",
            message: "We couldn't check your location. Please try again later."
        )
    }
    
    @objc func showApplePay(_ notification: NSNotification) {
        if let amount = notification.userInfo?["amount"] as? Double {
            depositAmountWithAuth(amount: amount)
        }
    }
    
    func depositAmountWithAuth(amount: Double) {
        self.viewDelegate?.showLoadingProcess()
        self.authType = .deposit
        self.entryPriceToPurchase = amount
        Task { [weak self] in
            if await self?.dependencies.sharedSession.isSignedUp == false {
                self?.coordinator?.startAuthentication()
                return
            }
            self?.startApplePay()
        }
    }
    
    func supportButtonTap() {
        coordinator?.support()
    }
}

// MARK: - Collection View Flow Layout

extension TournamentsViewModelImplementation {
    func getSectionHeight(at index: Int) -> Int {
        switch getSection(at: index) {
        case .dashboard:
            return 72
        case .blitz, .tournaments, .missions, .welcome, .liveMessage, .otherGames:
            return 0
        default:
            return 40
        }
    }
    
    func getCellHeight(at index: Int) -> Int {
        switch getSection(at: index) {
        case .dashboard: return 168
        case .blitz: return 48
        case .tournaments: return 84
        case .missions: return 80
        case .welcome: return isWelcomeCellCollapsed ? 0 : 180
        case .liveMessage: return 52
        case .otherGames: return 160
        default: return 74
        }
    }
    
    func getMinimumLineSpacingForSection(at index: Int) -> Int {
        if case .history = getSection(at: index) { return -1 }
        if case .tournaments = getSection(at: index) { return 12 }
        return 20
    }
    
    func getNumberOfItems(at index: Int) -> Int {
        switch getSection(at: index) {
        case .dashboard: return 1
        case .blitz: return 1
        case .tournaments(let viewModel):
            return viewModel.items.count
        case .history(let viewModel):
            return viewModel.items.count
        case .missions:
            return 1
        case .welcome:
            return 1
        case .liveMessage:
            return 1
        case .otherGames:
            return 1
        default: return 0
        }
    }
}

// MARK: - Game

private extension TournamentsViewModelImplementation {
    // TODO: - startPayForGame should be refactored
    
    func startApplePay() {
        guard let entryPrice = self.entryPriceToPurchase else { return }
        dependencies.applePay.preparePaymentRequest(amount: entryPrice) { request in
            guard let request = request else {
                self.prepareApplePayErrorAlert(with: .requestError)
                
                return
            }
            self.coordinator?.presentApplePay(request: request)
        }
    }
    
    // Makes sure that a user has enough balance / tokens to start a game
    // this works for both async and blitz
    // If the user's balance is too low it prompts them to deposit
    // User can buy into game if:
    // balance + min(usertokens, maxtokensforconfig) < entryPrice
    func startPayForGame() {
        self.dependencies.logger.log()
        Task { [weak self] in
            let tokenBalance = await self?.dependencies.sharedSession.user?.tokenBalance ?? 0
            let tokensToSubtract = min(self?.tournamentToPurchase?.entryTokens ?? 0, tokenBalance)
            var entryPrice: Double?
            if let entryPriceAsync = self?.tournamentToPurchase?.entryPrice {
                entryPrice = entryPriceAsync - Double(Double(tokensToSubtract) / 100.0)
            } else if let entryPriceBlitz = self?.blitzToPurchase?.entryPrice {
                entryPrice = entryPriceBlitz
            } else {
                self?.dependencies.logger.log("game model is nil", .error)
                self?.viewDelegate?.hideLoadingProcess()
                return
            }
            if self?.balance ?? 0 < entryPrice ?? 0 {
                self?.authType = .buyIn
                self?.depositDidPress()
            } else {
                switch type {
                case .blitz:
                    self?.buyIntoBlitz()
                case .versus:
                    self?.buyIntoGame()
                }
                
            }
        }
    }
    
    // Buy into Async game
    func buyIntoGame() {
        dependencies.logger.log()
        guard let tournament = self.tournamentToPurchase else {
            dependencies.logger.log("entryPrice: \(tournamentToPurchase?.entryPrice == nil)", .error)
            viewDelegate?.hideLoadingProcess()
            return
        }

        Task.init(priority: .userInitiated, operation: {
            do {
                try await dependencies.game.buyIntoGame(tournament: tournament)
                await MainActor.run { [weak self] in
                    coordinator?.startPlaying(tournamentType: self?.type ?? .versus)
                }
            } catch let error {
                dependencies.logger.log(error, .error)
                await MainActor.run { [weak self] in
                    self?.viewDelegate?.hideLoadingProcess()
                    self?.coordinator?.viewModelDelegate?.messageDidPresent()
                }
            }
        })
    }
    
    // Buy into Blitz game
    func buyIntoBlitz() {
        guard let blitz = blitzToPurchase else {
            self.dependencies.logger.log("blitz is nil: \(blitzToPurchase == nil)", .error)
            return
        }
        coordinator?.viewModelDelegate?.startBlitzLoading()
        
        Task.init(priority: .userInitiated, operation: {
            do {
                try await dependencies.game.buyIntoGame(blitz: blitz)
                await MainActor.run { [weak self] in
                    self?.coordinator?.startPlaying(tournamentType: self?.type ?? .versus)
                    self?.viewDelegate?.hideLoadingProcess()
                    self?.dependencies.logger.log("", .success)
                }
            } catch let error {
                dependencies.logger.log(error, .error)
                await MainActor.run { [weak self] in
                    self?.viewDelegate?.hideLoadingProcess()
                    self?.coordinator?.viewModelDelegate?.messageDidPresent()
                }
            }
        })
    }
}

// MARK: - TournamentsDashboardViewModelDelegate

extension TournamentsViewModelImplementation: TournamentsDashboardViewModelDelegate {
    func dashboardAccountStartLoading() {
        viewDelegate?.showLoadingProcess()
    }
    
    func dashboardAccountFinishLoading() {
        viewDelegate?.hideLoadingProcess()
    }
    
    func depositDidPress() {
        viewDelegate?.showLoadingProcess()
        // FIXME: Check if Eligibility was checked from another place
        coordinator?.checkEligibility { [weak self] isEligible in
            guard let self = self else { return }
            if isEligible == true {
                if #available(iOS 15.0, *) {
                    self.coordinator?.showDepositSheet()
                } else {
                    let actionsAlertModel = self.prepareDepositAlertActions()
                    self.dependencies.alertFabric.showAlert(actionsAlertModel, completion: nil)
                }
            }
            self.viewDelegate?.hideLoadingProcess()
            self.coordinator?.viewModelDelegate?.tournamentCoordinatorFinishLoading()
        }
    }
    
    // FIXME: - Move it to the service if it's used from the different places
    func prepareDepositAlertActions() -> ActionAlertModel {
        var actions = [UIAlertAction]()

        for (amount, tokens) in [(500, 0), (1000, 100), (1500, 175), (2000, 500)] {
            actions.insert(
                UIAlertAction(
                    title: "\(amount.formatCurrency() + (tokens == 0 ? "" : ", \(tokens) tokens"))",
                    style: .default,
                    handler: { _ in
                        self.depositAmountWithAuth(amount: Double(amount / 100))
                    }
                ), at: actions.count)
        }

        return ActionAlertModel(
            title: "Deposit",
            message: "Please choose an amount to deposit",
            cancelButtonTitle: "Cancel",
            cancelHandler: { _ in },
            actions: actions
        )
    }
}

// MARK: - TournamentsItemViewModelDelegate

extension TournamentsViewModelImplementation: TournamentsVersusSectionViewModelDelegate {
    func tournamentVersusDepositAmountWithAuth(amount: Double) {
        depositAmountWithAuth(amount: amount)
    }
}

// MARK: - TournamentsCoordinatorDelegate

extension TournamentsViewModelImplementation: TournamentsCoordinatorDelegate {
    func playDidPress(tournamentType: TournamentType, tournament: TournamentModel?, blitz: BlitzModel?) {
        type = tournamentType
        tournamentToPurchase = tournament
        blitzToPurchase = blitz

        handleItemPlayPress()
    }

    func paymentAuthorizationViewControllerDidFinish() {
        viewDelegate?.hideLoadingProcess()
        Task { [weak self] in
            await self?.prepareHistorySectionViewModels()
        }
    }
    
    func didAuthorizePayment(with tokenData: Data, completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        guard let authType = self.authType, let amount = self.entryPriceToPurchase else {
            prepareApplePayErrorAlert(with: .checkoutError)
            return
        }
       
        dependencies.applePay.createApplePayTokenWithPayentData(paymentData: tokenData, amount: amount) { result in
            // TODO: - Handle all statuses
            // FIXME: - Refactring needed
            if result.status == .success {
                if authType == .buyIn {
                    
                    // FIXME:
                    // self.buyIntoGame(amount: amount)
                    
                } else {
                    self.viewDelegate?.hideLoadingProcess()
                }
            } else {
                self.prepareApplePayErrorAlert(with: .checkoutError)
            }
            Task { [weak self] in
                await self?.prepareHistorySectionViewModels()
                completion(result)
            }
        }
    }
    
    func tournamentsCoordinatorApplePayError(_ error: ApplePayError) {
        prepareApplePayErrorAlert(with: error)
    }
    
    func gameOverDidDisapear() {
        Task { [weak self] in
            await self?.prepareHistorySectionViewModels()
        }
    }
    
    func startBlitz() {
        tournamentsBlitzCellDidEnter()
    }
}

// MARK: - Missions Helper
extension TournamentsViewModelImplementation {
    private func getReward(from depositModel: DepositHistoryModel) -> Int {
        switch depositModel.rewardType {
        case nil, .money:
            return Int(depositModel.amount * 100)
        case .tree:
            return Int(depositModel.rawAmount)
        case .token:
            return depositModel.tokenAmount ?? 0
        }
    }
    
    // Used only to show SwiftMessage when misisons cell is tapped
    func depositToMissionModel(depositModel: DepositHistoryModel) -> MissionModel {
        return MissionModel(
            config: MissionConfig(
                id: depositModel.missionId,
                displayOrder: 0, // irrelevant
                emoji: depositModel.missionEmoji ?? "",
                name: depositModel.missionName ?? "",
                reward: getReward(from: depositModel),
                rewardTypeWrapped: depositModel.rewardTypeWrapped ?? "money"
            ),
            missionUser: MissionUser(
                id: depositModel.missionId,
                completedFor: [:], // irrelevant
                isCompleted: false, // irrelevant
                rewardReceived: [dependencies.appInfo.id: getReward(from: depositModel)],
                unlockedFor: [:] // irrelevant
            )
        )
    }
}

// MARK: - TournamentsBlitzCellViewModelDelegate

extension TournamentsViewModelImplementation: TournamentsBlitzCellViewModelDelegate {
    func tournamentsBlitzCellDidEnter() {
        self.authType = .getBlitzData
        Task { [weak self] in
            
            guard await dependencies.networkChecker.isConnectionGood() else {
                return
            }
            
            if await self?.dependencies.sharedSession.isSignedUp == false {
                self?.coordinator?.startAuthentication()
            } else {
                self?.viewDelegate?.showLoadingProcess()
                do {
                    try await self?.dependencies.game.startObserveBlitzDataPoints()
                    self?.dependencies.logger.log("Blitz observe", .success)
                    self?.coordinator?.blitz(state: .start)
                    self?.viewDelegate?.hideLoadingProcess()
                    
                } catch {
                    self?.dependencies.logger.log("Tournaments Blitz Cell Did Enter Error", .error)
                    self?.viewDelegate?.hideLoadingProcess()
                    
                }
            }
        }
    }
}

// MARK: - Localization

extension TournamentsViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}

// MARK: - SessionDelegate
// FIXME: - Refactor it - update only specific sections - on all collection view

extension TournamentsViewModelImplementation: SharedSessionDelegate {
    
    func sessionDataDidPrepare() {
        Task { @MainActor [weak self] in
            self?.viewDelegate?.tournamentsReload()
        }
    }
    func sessionLockdownDidUpdate() {}
    
    func userCanClaimUnclaimedBalance() {
        Task { @MainActor [weak self] in
            if await self?.dependencies.sharedSession.user?.unclaimedBalance != nil && !(self?.stopUserObserver ?? false) {
                self?.runFirstOpen()
            }
        }
    }

    func firstLoginSequenceShouldRun() {
        coordinator?.runFirstLoginSequence()
    }
}

extension TournamentsViewModelImplementation: SessionDelegate {
    
    func tournamentConfigsDidUpdate() {
        Task { @MainActor [weak self] in
            self?.viewDelegate?.tournamentsReload() 
        }
    }
    
    func hotstreakSequenceDidUpdate() {
        self.coordinator?.runConfettiAndHotStreak()
    }
    
    // Left in here, just in case missions need to update in real-time again
    func missionsDidUpdate() { }
    
    func newGameTokensDeposit(model: DepositHistoryModel) {
        guard let gameId = model.game,
              let tokenAmount = model.tokenAmount else { return }
        dependencies.swiftMessage.showNewGameRewardMessage(gameId: gameId, reward: tokenAmount)
        coordinator?.runConfettiWithAction {}
    }
}

// MARK: - NetworkCheckerDelegate

extension TournamentsViewModelImplementation: NetworkCheckerDelegate {
    func networkCheckerAlertDidFinish() {
        coordinator?.didFinish()
    }
}
