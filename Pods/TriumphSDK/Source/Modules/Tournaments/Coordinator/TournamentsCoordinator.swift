// Copyright © TriumphSDK. All rights reserved.
import StoreKit
import UIKit
import PassKit
import TriumphCommon

// MARK: TournamentsCoordinatorDelegate

protocol TournamentsCoordinatorDelegate: AnyObject {
    
    /// Called when apple pay is finished
    /// - Parameter tokenData: token to send to BE
    /// - Parameter completion (result) Completion handler that gets passed the result of the transaction sucess or fail ect
    func didAuthorizePayment(with tokenData: Data, completion: @escaping (PKPaymentAuthorizationResult) -> Void)
    func tournamentsCoordinatorApplePayError(_ error: ApplePayError)
    func playDidPress(tournamentType: TournamentType, tournament: TournamentModel?, blitz: BlitzModel?)
    func paymentAuthorizationViewControllerDidFinish()
    func gameOverDidDisapear()
    func startBlitz()
    func depositDidPress()
}

// MARK: TournamentsCoordinatorViewModelDelegate

protocol TournamentsCoordinatorViewModelDelegate: AnyObject {
    /// Called when Apple Pay authorization has finished
    func paymentAuthorizationViewControllerDidFinish()
    
    /// Called when the tournament coordinator should hide a loading indicator
    func tournamentCoordinatorFinishLoading()
    
    /// Called when the user has bought in to a blitz game
    func tournamentDidStartPlayBlitz()
    
    /// Called when loading should be hidden because a task has failed
    func messageDidPresent()
    
    /// Called when loading indicator should be shown for blitz
    func startBlitzLoading()
}

extension TournamentsCoordinatorViewModelDelegate {
    func tournamentCoordinatorFinishLoading() {}
    func tournamentDidStartPlayBlitz() {}
    func messageDidPresent() {}
    func startBlitzLoading() {}
}

protocol TournamentsCoordinatorStartGameDelegate: AnyObject {
    /// Called when the countdown video has finished and gameplay is about to start
    func gameAboutToStart()
}

// MARK: Coordinator

protocol TournamentsCoordinator: Coordinator {

    var delegate: TournamentsCoordinatorDelegate? { get set }
    var viewModelDelegate: TournamentsCoordinatorViewModelDelegate? { get set }
    var startGameDelegate: TournamentsCoordinatorStartGameDelegate? { get set }
    
    ///  Show confetti and animate an update to hot streak
    func runConfettiAndHotStreak()
    
    /// Show confetti for when the user receives a reward
    func runConfettiForClaimReward()
    
    ///  Show confetti with a custom completion action
    ///  - Parameter action: A function that will run after the confetti has finished falling
    func runConfettiWithAction(action: @escaping () -> Void)
    
    /// Show confetti & SwiftMessage for when user has claimed initial reward
    func runFirstLoginSequence()
    
    ///  Present Apple Pay modal
    ///  - Parameter request: A PKPaymentRequestObject containing the associated cost
    func presentApplePay(request: PKPaymentRequest)
    func showApplePay(for amount: Double)
    
    /// Asks parent coordinator to start authentication sequence
    /// Used when user has been logged out and attempts to make a transaction
    func startAuthentication()
    
    /// Show MatchingViewController
    /// Used when user enters async1v1 tournament
    func startMatching()
    
    /// Show game over screen
    /// Used after user finishes async1v1
    /// - Parameter with: GameHistoryModel used to populate game over screen
    func gameOver(with model: GameHistoryModel?)
    
    /// Show play blitz screen
    /// - Parameter state: BlitzState used to decide whether the screen should be a display of a previous game or a buy in screen
    func blitz(state: BlitzState)
    
    /// Show CashOutViewController
    func cashout()
    
    /// Show SupportViewController
    func support()
    
    /// Show edit profile page
    func profile()
    
    /// Pop current ViewController
    func back()
    
    /// Dismiss SDK
    func didFinish()
    
    /// Calls checkEligibility method of LocationManager
    ///  - Parameter :  Closure that takes in a Bool  describing whether or not the user's current location is compatible with Triumph
    func checkEligibility(_ isEligible: @escaping (Bool) -> Void)
    
    /// Start a tournament or blitz game
    ///  - Parameter tournamentType: TournamentType that denotes whether to start a versus or blitz game
    func startPlaying(tournamentType: TournamentType)
    
    /// Called when the play button is pressed for either a versus or blitz game
    /// - Parameter tournamentType: Denotes whether play was pressed on a versus or blitz game
    /// - Parameter tournament: Optional TournamentModel to be included if tournamentType is versus
    /// - Parameter blitz: Optional BlitzModel to be included if tournamentType is blitz
    func playDidPress(tournamentType: TournamentType, tournament: TournamentModel?, blitz: BlitzModel?)
    
    /// Alerts users that we were unable to check their location
    func showLocationErrorMessage()
    
    /// Alerts users that they are about to be logged out
    /// - Parameter startLogout: Function to be called when the user agrees that they want to log out
    /// - Parameter finishedLogout: Function to be called when the entire log out process has finished
    func showLogoutAlert(startLogout: @escaping () -> Void, finishedLogout: @escaping (Bool) -> Void)
    
    /// Alerts users that the tournament they tried to play is no longer available
    func showTournamentNoLongerOfferedMessage()
    
    /// Called when the game over view has disappeared
    func gameOverDidDisapear()
    
    /// Shows the countdown (3...2...1) before every game
    func startCountdown()
    
    /// Called when a mission is tapped
    /// - Parameter action: Enum type that denotes which class of mission was tapped
    /// - Parameter model: Model of the mission that was tapped
    func respondTo(action: MissionAction, model: MissionModel?)
    
    /// Shows the deposit sheet
    func showDepositSheet()
    
    /// Shows the mission sheet
    func showMissionsSheet()
    
    /// Opens an app store URL; called from the mission sheet, specifically, OtherGamesCollectionView
    func openAppStoreURL(rawURL: String)
    
    func showTokenInfo()
}

// MARK: - Impl.

class TournamentsCoordinatorImplementation: NSObject, TournamentsCoordinator {
    
    weak var delegate: TournamentsCoordinatorDelegate?
    weak var viewModelDelegate: TournamentsCoordinatorViewModelDelegate?
    weak var startGameDelegate: TournamentsCoordinatorStartGameDelegate?
    weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    private(set) var navigationController: BaseNavigationController?
    private var dependencies: AllDependencies
    private var isShowingUnsupportedLocation: Bool = false

    init(navigationController: BaseNavigationController, dependencies: AllDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkLocationUnsupported),
            name: .locationUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showAsyncExplanation),
            name: .showAsyncExplanation,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .locationUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .showAsyncExplanation, object: nil)
        print("DEINIT \(self)")
    }

    /// Starts the Tournaments screen, initilizes TournamentsViewModel
    /// Checks for tutorial completeness
    @MainActor func start() {
        Task { @MainActor in
            let hasCompletedTutorialLocal = (dependencies.localStorage.read(forKey: .hasCompletedTutorial) as? Bool) ?? false
            let viewController = TournamentsViewController()
            viewController.viewModel = TournamentsViewModelImplementation(
                coordinator: self,
                dependencies: dependencies
            )
            // check location
            dependencies.location.checkEligibility { [weak self] _ in
                self?.checkLocationUnsupported()
            }
            dependencies.gamePlay.teardownNotificationListeners()
            if !hasCompletedTutorialLocal {
                let user = await dependencies.sharedSession.user
                if user?.hasSeenTutorial == false {
                    showTutorial(controller: viewController)
                    return
                } else {
                    dependencies.localStorage.add(value: true, forKey: .hasCompletedTutorial)
                }
            }
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    /// Starts the matching screen, after the user presses next they will segue into a game
    /// at this point the user already has their match or unmatched state, also if they backout now they forfit and get a score of zero
    @MainActor func startMatching() {
        Task { @MainActor in
            let viewModel = MatchingViewModelImplementation(
                coordinator: self,
                dependencies: dependencies
            )
            let viewController = MatchingViewController(viewModel: viewModel)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    /// Starts the Blitz screen
    /// Begins observing the blitz scores and shows user the score / payout graph
    @MainActor func blitz(state: BlitzState) {
        Task { @MainActor in
            let viewModel = BlitzViewModelImplementation(
                coordinator: self,
                dependencies: dependencies,
                state: state
            )

            let viewController = BlitzViewController(viewModel: viewModel)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    @MainActor func gameOver(with model: GameHistoryModel?) {
        Task { @MainActor in
            let viewModel = GameOverViewModelImplementation(
                coordinator: self,
                dependencies: dependencies,
                model: model
            )
            
            let viewController = GameOverViewController(viewModel: viewModel)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @MainActor func cashout() {
        Task { @MainActor in
            let viewModel = CashoutViewModelImplementation(
                coordinator: self,
                dependencies: dependencies
            )
            
            let viewController = CashoutViewController(viewModel: viewModel)
            navigationController?.pushViewController(viewController, animated: true)
            dependencies.analytics.logEvent(LoggingEvent(.cashOut))
        }
    }
    
    @MainActor func support() {
        Task { @MainActor in
            let viewModel = SupportViewModelImplementation(dependencies: dependencies)
            viewModel.coordinatorDelegate = self
            let viewController = SupportViewController(viewModel: viewModel)
            navigationController?.pushViewController(viewController, animated: true)
            dependencies.analytics.logEvent(LoggingEvent(.faq))
        }
    }
    
    func profile() {
        (parentCoordinator as? MainCoordinator)?.startUserProfile(screen: .update)
    }

    func didFinish() {
        (parentCoordinator as? MainCoordinator)?.didFinish()
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @MainActor func startPlaying(tournamentType: TournamentType) {
        Task { @MainActor in
            switch tournamentType {
            case .versus:
                startMatching()
            case .blitz:
                viewModelDelegate?.tournamentDidStartPlayBlitz()
            }
        }
    }
    
    func playDidPress(tournamentType: TournamentType, tournament: TournamentModel?, blitz: BlitzModel?) {
        Task { [weak self] in
            self?.dependencies.logger.log("Tournament Type: \(tournamentType), buyIn: \(tournament?.entryPrice ?? 0)", .warning)
            let isBlitzLocked = await self?.dependencies.sharedSession.lockdown?.blitzLockdown
            let isVersusLocked = await self?.dependencies.sharedSession.lockdown?.asyncLockdown

            if (isVersusLocked == true && tournamentType == .versus) ||
                (isBlitzLocked == true && tournamentType == .blitz) {
                self?.showUnavailableMessage(tournamentType: tournamentType)
                self?.viewModelDelegate?.tournamentCoordinatorFinishLoading()
                return
            }
            
            await MainActor.run { [weak self] in
                self?.delegate?.playDidPress(tournamentType: tournamentType, tournament: tournament, blitz: blitz)
            }
        }
    }
    
    func showUnavailableMessage(tournamentType: TournamentType) {
        var message: String
        switch tournamentType {
        case .versus:
            message = "1 v. 1"
        case .blitz:
            message = "Blitz"
        }
        let alertModel = AlertModel(
            title: "Unavailable",
            message: "\(message) is currently unavailable. Please try again later"
        )
        dependencies.alertFabric.showAlert(alertModel, completion: nil)
    }
    
    func checkEligibility(_ isEligible: @escaping (Bool) -> Void) {
        dependencies.location.checkEligibility { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch status {
                case .notEligable, .undefined:
                    isEligible(false)
                    self.viewModelDelegate?.tournamentCoordinatorFinishLoading()
                    self.dependencies.alertFabric.showNotEligableAlert(
                        for: self.dependencies.location.getStateName()
                    )
                    self.viewModelDelegate?.messageDidPresent()
                case .eligable:
                    isEligible(true)
                }
            }
        }
    }
    
    func showLocationErrorMessage() {
        viewModelDelegate?.messageDidPresent()
        dependencies.swiftMessage.showErrorMessage(
            title: dependencies.localization.commonLocalizedString("lbl_error_title"),
            message: dependencies.localization.commonLocalizedString("msg_err_location_check")
        )
    }
    
    func showTournamentNoLongerOfferedMessage() {
        let alert = AlertModel(
            title: dependencies.localization.localizedString("tournament_ended_title"),
            message: dependencies.localization.localizedString("tournament_ended_message"),
            okButtonTitle: "Okay",
            okHandler: { _ in }
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
    
    func gameOverDidDisapear() {
        delegate?.gameOverDidDisapear()
    }
    
    func startCountdown() {
        DispatchQueue.main.async {
            let viewController = CountdownViewController()
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: false)
        }
    }
    
    func respondTo(action: MissionAction, model: MissionModel? = nil) {
        if let id = model?.id {
            dependencies.analytics.logEvent(
                LoggingEvent(
                    .missionTapped,
                    parameters: ["missionID": id]
                )
            )
        }
        
        switch action {
        case .makeReferral:
            if let url = URL(string: "https://apps.apple.com/us/app/id\(TriumphSDK.appleId)") {
                (self.parentCoordinator as? MainCoordinator)?.presentReferralActivityController(url: url)
            }
        case .playBlitz:
            delegate?.startBlitz()
        case .playSilver:
            showEnterAsyncTournamentThroughMissionAlert {
                Task { [weak self] in
                    if let model = await self?.dependencies.session.presets.tournamentDefinitions
                        .filter({ $0.gameTitle.lowercased().contains("silver") }).first {
                        self?.playDidPress(tournamentType: .versus, tournament: model, blitz: nil)
                    }
                }
            }
        case .description:
            guard let model = model else { return }
            dependencies.swiftMessage.showMissionDescriptionMessage(mission: model)
        }
    }
    
    private func showEnterAsyncTournamentThroughMissionAlert(buyIn: @escaping () -> Void) {
        let alert = AlertModel(
            title: "Are you sure you want to play?",
            message: "You will be charged a buy-in",
            okButtonTitle: "Start",
            okHandler: { _ in
                buyIn()
            },
            cancelButtonTitle: "Cancel",
            cancelHandler: { _ in }
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
    
    @objc func showAsyncExplanation() {
        dependencies.swiftMessage.showAsyncGameDescriptionMessage()
    }
    
    @objc func checkLocationUnsupported() {
        if dependencies.location.isEligable ?? false {
            (parentCoordinator as? MainCoordinator)?.endUnsupportedLocation()
            isShowingUnsupportedLocation = false
        } else {
            if !isShowingUnsupportedLocation {
                (parentCoordinator as? MainCoordinator)?.startUnsupportedLocation()
                isShowingUnsupportedLocation = true
                guard let state = dependencies.location.getStateName() else { return }
                dependencies.analytics.logEvent(
                    LoggingEvent(
                        .locationDenial,
                        parameters: [
                            "state": "\(state)"
                        ]
                    )
                )
            }
        }
    }
    // MARK: - Logout
    
    func showLogoutAlert(startLogout: @escaping () -> Void, finishedLogout: @escaping (Bool) -> Void) {
        let alert = AlertModel(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            okButtonTitle: "Log Out",
            okHandler: { [weak self] _ in
                self?.logoutHandler(startLogout: startLogout, finishedLogout: finishedLogout)
            },
            cancelButtonTitle: "Cancel",
            cancelHandler: { _ in }
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
    
    func logoutHandler(startLogout: @escaping () -> Void, finishedLogout: @escaping (Bool) -> Void) {
        startLogout()
        Task { [weak self] in
            self?.dependencies.authentication.observeUserState(onLogOut: { [weak self] wasSuccess in
                guard let self = self else { return }
                if wasSuccess {
                    self.didFinish()
                    self.dependencies.analytics.logEvent(LoggingEvent(.logOut))
                } else {
                    self.showRetryLogoutAlert(startLogout: startLogout, finishedLogout: finishedLogout)
                }
                finishedLogout(wasSuccess)
            })
            await dependencies.authentication.signOut()
        }
    }
    
    func showRetryLogoutAlert(startLogout: @escaping () -> Void, finishedLogout: @escaping (Bool) -> Void) {
        let alert = AlertModel(
            title: "Log out failed",
            message: "Do you want to retry?",
            okButtonTitle: "Log Out",
            okHandler: { [weak self] _ in
                guard let self = self else { return }
                self.logoutHandler(startLogout: startLogout, finishedLogout: finishedLogout)
            },
            cancelButtonTitle: "Cancel",
            cancelHandler: { _ in }
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
    
    func showDepositSheet() {
        Task { [weak self] in
            let referrerFirstName = await self?.dependencies.sharedSession.referrerFirstName
            let depositDefinitions = await self?.dependencies.session.depositDefinitions
            await MainActor.run { [weak self] in
                let wasReferred = (self?.dependencies.localStorage.read(forKey: .referrerUsername) as? String) != nil
                let hasDepositedAfterReferral = (
                    self?.dependencies.localStorage.read(
                        forKey: .hasDepositedAfterReferral
                    ) as? Bool
                ) ?? false
                
                let viewController = DepositSheetViewController()
                if let self = self {
                    viewController.viewModel = DepositSheetViewModel(
                        // TODO: - Make change on the backend in order to uncomment this line
    //                    isFirstDepositAfterReferral: wasReferred && !hasDepositedAfterReferral,
                        isFirstDepositAfterReferral: false,
                        referrerFirstName: referrerFirstName,
                        depositDefinitions: depositDefinitions ?? [],
                        coordinator: self
                    )
                }

                viewController.modalPresentationStyle = .custom
                viewController.transitioningDelegate = self
                self?.navigationController?.present(viewController, animated: true)
            }
        }
    }
    
    @MainActor func showMissionsSheet() {
        Task {
            let viewController = MissionsViewController()
            let viewModel = MissionsViewModelImplementation(dependencies: dependencies, coordinator: self)
            viewController.viewModel = viewModel
            
            await MainActor.run { [weak self] in
                viewController.modalPresentationStyle = .custom
                viewController.transitioningDelegate = self
                self?.navigationController?.present(viewController, animated: true)
            }
        }
    }
    
    func openAppStoreURL(rawURL: String) {
        let vc = SKStoreProductViewController()
        vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: rawURL])
        navigationController?.present(vc, animated: true)
    }
    
    func showTokenInfo() {
        dependencies.swiftMessage.showTokenInfoSwiftMessage()
    }
    
    func showTutorial(controller baseController: TournamentsViewController) {
        let viewController = UIViewController()

        let pageController = TutorialPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageController.viewModel =  TutorialViewControllerViewModel(dependencies: dependencies, coordinator: self, controller: pageController)
        pageController.viewModel?.coordinator = self
        pageController.viewModel?.dependencies = dependencies

        pageController.view.frame = CGRect(
            x: 0,
            y: 0,
            width: viewController.view.frame.width,
            height: viewController.view.frame.height
        )

        viewController.addChild(pageController)
        viewController.view.addSubview(pageController.view)

        pageController.didMove(toParent: viewController)

        navigationController?.pushViewController(viewController, animated: true)
        if let count = navigationController?.viewControllers.count, navigationController?.viewControllers.isEmpty == false {
            navigationController?.viewControllers.insert(baseController, at: count - 1)
        }
    }
}

// MARK: - Confetti
// FIXME: - Refactor this using current Controllers

extension TournamentsCoordinatorImplementation {
    
    func runConfettiAndHotStreak() {
        Task { @MainActor [weak self] in
            if let view = self?.navigationController?.view  {
                await self?.dependencies.session.updateHotStreak()
                self?.dependencies.confetti.runConfettiFromView(view: view, completion: {
                    self?.dependencies.swiftMessage.showHotStreakWonMessage()
                }, time: 5.0)
            }
        }
    }
 
    func runFirstLoginSequence() {
        guard let view = navigationController?.view else { return }
        self.dependencies.swiftMessage.showFirstLoginMessage(completion: {
            Task { [weak self] in
                await self?.dependencies.session.updateHotStreak()
                self?.dependencies.confetti.runConfettiFromView(view: view, completion: {
                }, time: 3.0)
            }
        })
    }
    
    func runConfettiForClaimReward() {
        guard let view = navigationController?.view else { return }
        dependencies.confetti.runConfettiFromView(
            view: view,
            completion: {},
            time: 5
        )
    }
    
    @MainActor func runConfettiWithAction(action: @escaping () -> Void) {
        Task { @MainActor  [weak self] in
            if let view = self?.navigationController?.view  {
                self?.dependencies.confetti.runConfettiFromView(
                    view: view,
                    completion: {
                        action()
                    },
                    time: 5
                )
            }
        }
        
    }
}

extension TournamentsCoordinatorImplementation {
    func startAuthentication() {
        (parentCoordinator as? MainCoordinator)?.startSignUpProcess(from: .otp)
    }
    
    @MainActor func showApplePay(for amount: Double) {
        dependencies.applePay.preparePaymentRequest(amount: amount) { request in
            guard let request = request else { return }
            self.presentApplePay(request: request)
        }
    }
    
    @MainActor func presentApplePay(request: PKPaymentRequest) {
        Task { [weak self] in
            if let paymentViewController = PKPaymentAuthorizationViewController(paymentRequest: request) {
                paymentViewController.delegate = self
                navigationController?.present(paymentViewController, animated: true)
            } else {
                delegate?.tournamentsCoordinatorApplePayError(.applePayControllerError)
            }
        }
    }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

extension TournamentsCoordinatorImplementation: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // TODO: - Stop Progress Hud here
        self.viewModelDelegate?.paymentAuthorizationViewControllerDidFinish()
        self.delegate?.paymentAuthorizationViewControllerDidFinish()
        navigationController?.dismiss(animated: true, completion: {})
    }
    
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        delegate?.didAuthorizePayment(with: payment.token.paymentData, completion: { result in
            if result.status == .success {
                self.dependencies.localStorage.add(value: true, forKey: .hasDepositedAfterReferral)
            }
            completion(result)
        })
    }
}

// MARK: - CountdownViewControllerDelegate

extension TournamentsCoordinatorImplementation: CountdownViewControllerDelegate {
    func countdownDidStart() {}
    
    func countdownAboutToFinish() {
        startGameDelegate?.gameAboutToStart()
        dependencies.gamePlay.start()
    }
    
    func countdownDidFinish() {
        didFinish()
    }
}

extension TournamentsCoordinatorImplementation: SupportViewModelCoordinatorDelegate {
    func supportViewModelOpenProfile() {
        profile()
    }
    
    func supportViewModel(_ viewModel: SupportViewModel, startLogout: @escaping () -> Void, finishedLogout: @escaping (Bool) -> Void) {
        showLogoutAlert(startLogout: startLogout, finishedLogout: finishedLogout)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TournamentsCoordinatorImplementation: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        switch presented {
        case is DepositSheetViewController:
            controller.fractionOfHeight = 0.5
        case is SheetViewController:
            controller.fractionOfHeight = 0.6
        default:
            controller.fractionOfHeight = 0.5
        }
        return controller
    }
}
