// Copyright © TriumphSDK. All rights reserved.
// Documentation April 11 2022 Henry Boswell
import UIKit
import AVFoundation
import TriumphCommon
import StoreKit

/// Screens that the user can get to through the main coordinator
enum TournamentScreen {
    case gameOver(Double)
    case matching
    case tournaments
    case blitz(Double)
    case notificationGameOver(GameHistoryModel)
}

// MARK: - Coordinator
/**
  The main entrance point for our app. Coordinates between different pages. Read up on MVVM + coordinator pattern
  https://medium.com/nerd-for-tech/mvvm-coordinators-ios-architecture-tutorial-fb27eaa36470
  */

protocol MainCoordinator: Coordinator {
    
    /// Delegate to communicate between the triumph SDK and the integrated game
    var triumphDelegate: TriumphSDKDelegate? { get set }
    
    /// Start Authentication Coordinator
    func startSignUpProcess(from step: SignUpStep)
    
    /// Start Tournament Coordinator
    /// - Parameter screen: The tournament screen that should be entered at
    func startTournaments(with screen: TournamentScreen?)
    
    /// Start Tournament Coordinator directly to game over screen - for score
    /// - Parameter score: the score that the game finished at
    func startWithScore(score: Double)

    /// Goes directly to game over sceen. Starts new coordinator.
    ///  - Parameter model: model for the game over screen to show
    func start(with model: GameHistoryModel) async
    
    /// Start Tournament Coordinator directly to game over sceen - for notification
    /// If coordinator already exists
    /// - Parameter model: model for the game over screen to show
    func pushGameOver(with model: GameHistoryModel)
    
    /// Closes triumph SDK
    func didFinish()
    
    /// Removes a child coordinator from the stack
    func didFinish(_ child: Coordinator?)
    
    /// Shows acitvity controller for referal
    ///  - Parameter url: url for referal
    func presentReferralActivityController(url: URL)
    
    /// Presents the swift message & confetti for when a referral has been made
    func showReferralCompletedMessage()
    
    /// Shows user profile screen for creating/updating account.
    func startUserProfile(screen: UserProfile)
    
    /// Opens app store modal URL
    ///  - Parameter rawURL: the app store ID; this is a special way to identify each app. We use a special
    ///  apple view controller to display the app on the store nicely.
    func openAppStoreURL(rawURL: String)
    
    // The below are called when a user is banned, on an unsupported version, or when a user
    // does not allow location services/is in an invalid location
    /// Pushes the unsupported location VC on the stack.
    /// This should be the top view controller no matter what is underneath,
    /// as we need to block users from using the app in an unsupported location
    func startUnsupportedLocation()
    
    /// Removes the unsupported location VC from our stack
    func endUnsupportedLocation()
    
    /// Shows lockdown screen
    func startLockdown()
    
    // Hides lockdown screen
    func endLockdown()
    
}

// MARK: - Implementation

final class MainCoordinatorImplementation: MainCoordinator {

    weak var parentCoordinator: Coordinator?
    // Sets delegate into dependencies
    weak var triumphDelegate: TriumphSDKDelegate? {
        didSet {
            dependencies.triumphDelegate = triumphDelegate
        }
    }
    
    weak var parentViewController: UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
    }

    var lockdownViewController: LockdownViewController?
    
    private var gameInfo: AppInfoModel
    private var dependencies: AllDependencies

    private(set) var navigationController: BaseNavigationController? = {
        let navigationController = BaseNavigationController()
        navigationController.isModalInPresentation = true
        return navigationController
    }()
    private(set) lazy var childCoordinators: [Coordinator] = []
    private var alert: UIAlertController?
    
    private var activityController: UIActivityViewController?
    
    // These three notifications are observed here because they need access on this level ex, the lockdown view controller needs to be pushed from here
    init(gameInfo: AppInfoModel, dependencies: AllDependencies) {
        self.gameInfo = gameInfo
        self.dependencies = dependencies
        self.dependencies.location.coordinatorDelegate = self
        self.dependencies.alertFabric.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(missionCompleted(_:)),
            name: .missionFinished,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(serverUnavailable),
            name: .showServerUnavailableAlert,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(lockdownDidUpdate),
            name: .lockdownUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .missionFinished, object: nil)
        NotificationCenter.default.removeObserver(self, name: .showServerUnavailableAlert, object: nil)
        NotificationCenter.default.removeObserver(self, name: .lockdownUpdated, object: nil)
        
        print("DEINIT \(self)")
    }

    func start() {
        setupNavigationController()
        Task { [weak self] in
            await self?.startCoordinators()
            self?.startController()
            self?.dependencies.analytics.logEvent(LoggingEvent(.sdkOpened))
        }

        // FIXME: this is only for the test purpose
        // startController()
        // startLockdown()
        // startUserProfile(with: "")
    }

    func start(with model: GameHistoryModel) async {
        triumphDelegate = TriumphSDK.delegate
        await dependencies.session.prepareSessionData()
        if await self.navigationController?.isBeingPresented == true { return }
        
        let isLockedDown = await dependencies.sharedSession.lockdown?.isLockedDown
        let user = await dependencies.sharedSession.user
        if isLockedDown ?? false || user?.banned ?? false {
            await MainActor.run { [weak self] in self?.startLockdown() }
            return
        }
        await MainActor.run { [weak self] in
            self?.setupNavigationController()
            self?.endLockdown()
            self?.endUnsupportedLocation()
            self?.startTournaments(with: .notificationGameOver(model))
            self?.startController()
        }
    }
    
    @MainActor func startWithScore(score: Double) {
        Task { @MainActor [weak self] in
            self?.setupNavigationController()
            switch self?.dependencies.game.tournamentType {
                case .blitz: self?.startTournaments(with: .blitz(score))
                default: self?.startTournaments(with: .gameOver(score))
            }
            self?.startController()
            
        }
    }
    
    func setupNavigationController() {
//        navigationController = BaseNavigationController()
        navigationController?.isModalInPresentation = true
        navigationController?.coordinatorDelegate = self
    }
    
    // swiftlint:disable line_length
    /*
    NavigationController.isBeingPresented is not sufficent it only checks is the navigationcontroller is currently in the process of being presented
    Link to relevant crash:
     https://console.firebase.google.com/u/0/project/triumph-prod/crashlytics/app/ios:com.triumphsdkprod/issues/1543530256c455cc7dfbf75cd8965a87?time=last-seven-days&sessionEventKey=9ebcd9a7807e44abb3897df80b75dadc_1679952730776387192
     */
    private func startController() {

        Task {@MainActor [weak self] in
            if let navigationController = navigationController, navigationController.isBeingPresented == false {
                if self?.parentViewController?.presentedViewController as? BaseNavigationController == nil {
                    self?.triumphDelegate?.triumphViewControllerWillPresent()
                    self?.parentViewController?.present(navigationController, animated: true)
                    self?.triumphDelegate?.triumphViewControllerDidPresented()
                }
            }
        }
    }
    
    /// This function decides what the appropriate entry point will be depending on the user's auth state and if the server is "locked down"
    private func startCoordinators() async {
       
        await dependencies.session.prepareSessionLocalStorageData()

        if let user = await dependencies.sharedSession.user {
            let isSignedUp = await self.dependencies.sharedSession.isSignedUp
            await MainActor.run { [weak self] in
                if isSignedUp {
                    self?.startTournaments()
                    Task { [weak self] in
                        if await self?.dependencies.sharedSession.lockdown?.isLockedDown ?? false || user.banned ?? false {
                            self?.startLockdown()
                            await self?.dependencies.session.prepareSession()
                            return
                        }
                    }
                } else {
                    // FIXME: What if the the contition above is false. It could be appear a black screen
                    self?.dependencies.localStorage.clearAll()
                    self?.startSignUpProcess()
                }
            }
        } else {
            await MainActor.run {[weak self] in self?.startSignUpProcess() }
        }
        
        Task { [weak self] in
            await self?.dependencies.session.prepareSessionData()
        }
    }
    
    private func startCoordinator<C: Coordinator>(_ coordinator: C) {
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }
    
    func startSignUpProcess(from step: SignUpStep = .intro) {
        guard let navigationController = navigationController else { return }
        let coordinator = AuthenticationCoordinatorImplementation(
            navigationController: navigationController,
            dependencies: dependencies
        )
        coordinator.start(from: step)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }

    func startUserProfile(screen: UserProfile) {
        guard let navigationController = navigationController else { return }
        let coordinator = UserProfileCoordinatorImplementation(
            navigationController: navigationController,
            dependencies: dependencies,
            screen: screen
        )
        coordinator.delegate = self
        startCoordinator(coordinator)
        dependencies.analytics.logEvent(LoggingEvent(.accountCreationFinished))
    }
    
    // Decided not to use coordinators here b/c we are passing no data and will only go to/from screen here.
    @MainActor func startLockdown() {
        if self.navigationController?.topViewController as? TournamentsViewController != nil {
            
            let appUrlString = "https://apps.apple.com/us/app/id\(TriumphSDK.appleId)"
            let viewModel = LockdownViewModelImplementation(dependencies: dependencies, appUrlString: appUrlString)
            viewModel.coordinatorDelegate = self
            
            if let lockdownViewController = self.lockdownViewController {
                lockdownViewController.viewModel = viewModel
                if self.navigationController?.topViewController as? LockdownViewController == nil {
                    navigationController?.pushViewController(lockdownViewController, animated: false)
                }
            } else {
                self.lockdownViewController = LockdownViewController()
                guard let lockdownViewController = self.lockdownViewController else { return }
                lockdownViewController.viewModel = viewModel
                navigationController?.pushViewController(lockdownViewController, animated: false)
            }
        }
    }
    
    @MainActor func endLockdown() {
        if self.navigationController?.topViewController as? LockdownViewController != nil {
            navigationController?.popViewController(animated: false)
            self.lockdownViewController = nil
        }
        
    }
    
    func startUnsupportedLocation() {
        Task { [weak self] in
            if await self?.dependencies.sharedSession.user != nil {
                await MainActor.run { [weak self] in
                    if self?.navigationController?.topViewController as? LocationViewController<SignUpLocationViewModelImplementation> != nil {
                        return
                    }
                    let viewController = LocationViewController<LocationBlockerViewModel>()
                    viewController.viewModel = LocationBlockerViewModel(
                        dependencies: self?.dependencies ?? TriumphSDK.dependencies
                    )
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    func endUnsupportedLocation() {
        Task { [weak self] in
            if await self?.dependencies.sharedSession.user != nil {
                await MainActor.run { [weak self] in
                    if self?.navigationController?.topViewController as? LocationViewController<LocationBlockerViewModel> != nil {
                        self?.navigationController?.popViewController(animated: false)
                    }
                }
            }
        }
    }
    
    func openAppStoreURL(rawURL: String) {
        let vc = SKStoreProductViewController()
        vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: rawURL])
        Task { @MainActor in
            navigationController?.present(vc, animated: true)
        }
    }

    /// When a game is over and the SDK is reopened this function is run
    /// This function routes into the sdk after a game is finished
    /// - Parameter screen: Which screen should be the destination
    @MainActor func startTournaments(with screen: TournamentScreen? = .tournaments) {
        guard let navigationController = navigationController else { return }
        let coordinator = TournamentsCoordinatorImplementation(
            navigationController: navigationController,
            dependencies: dependencies
        )
        coordinator.parentCoordinator = self
        startCoordinator(coordinator)

        switch screen {
        case .matching:
            coordinator.startPlaying(tournamentType: .versus)
        case .gameOver(let score):
            // TODO: - where should we execute game over dependencies.game.finishGame(score: score)
            dependencies.logger.log("Versus finished with score: \(score)")
            dependencies.game.finishGame(score: score)
            coordinator.gameOver(with: nil)
        case .blitz(let score):
            dependencies.logger.log("Blitz finished with score: \(score)")
            dependencies.game.finishGame(score: score)
            coordinator.blitz(state: .finish)
        case .notificationGameOver(let model):
            coordinator.gameOver(with: model)
        default: return
        }
    }
    
    func pushGameOver(with model: GameHistoryModel) {
        if let tournamentsCoordinator = childCoordinators.compactMap({ $0 as? TournamentsCoordinator }).first {
            tournamentsCoordinator.gameOver(with: model)
        }
    }
    
    /// Dismiss
    @MainActor func didFinish() {
        TriumphSDK.delegate?.triumphViewControllerWillDismiss()
        parentViewController?.dismiss(animated: true) {
            TriumphSDK.delegate?.triumphViewControllerDidDismissed()
            self.dependencies.analytics.logEvent(LoggingEvent(.sdkClosed))
        }
    }
    
    /// Done with coordinator
    func didFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
            break
        }
    }
    
    @objc
    func lockdownDidUpdate() {
        Task { [weak self] in
            let isAppLockedDown = await self?.dependencies.sharedSession.lockdown?.isLockedDown ?? false
            let isUserBanned = await self?.dependencies.sharedSession.user?.banned ?? false
            if isAppLockedDown || isUserBanned {
                await MainActor.run { [weak self] in self?.startLockdown() }
            } else {
                await MainActor.run { [weak self] in self?.endLockdown() }
            }
        }
    }
    
    func showReferralCompletedMessage() {
        guard let _ = navigationController?.view else { return }
        Task { @MainActor [weak self] in
            self?.runConfettiForClaimReward()
            self?.dependencies.swiftMessage.showReferralCompletedSwiftMessage()
        }
    }
}

// MARK: AlertFabricDelegate

extension MainCoordinatorImplementation: AlertFabricDelegate {
    func showAlert(_ alertModel: AlertModel, completion: (() -> Void)?) {
        performOnMain {
            self.navigationController?.showAlert(alertModel)
        }
    }
    
    func showAlert(_ actionAlertModel: ActionAlertModel, completion: (() -> Void)?) {
        performOnMain {
            self.navigationController?.showAlert(actionAlertModel)
        }
    }
    
    func showAlert(_ alertModel: TextFieldAlertModel, completion: ((String?) -> Void)?) {
        performOnMain {
            self.navigationController?.showAlert(alertModel, completion: completion)
        }
    }

    func dismissAlert(completion: (() -> Void)?) {
        self.navigationController?.dismissAlert()
    }
}

// MARK: - Activity Controller
extension MainCoordinatorImplementation {
  
    func presentReferralActivityController(url: URL) {
        Task { [weak self] in
            var items: [Any] = []
            if let username = await self?.dependencies.sharedSession.userPublicInfo?.username{
                if let name = await self?.dependencies.sharedSession.userPublicInfo?.name {
                    items = [url, "\(name) invited you to Triumph. Use the referral code \"\(username)\" when you sign up to receive a bonus!\n\n"]
                } else {
                    items = [url, "Someone invited you to Triumph. Use the referral code \"\(username)\" when you sign up to receive a bonus!\n\n"]
                }
            } else {
                items = [url, "You were invited to Triumph. Use this link to receive a sign up bonus!\n\n"]
            }
            activityController = await UIActivityViewController(activityItems: items, applicationActivities: nil)
            if let activityController = activityController {
                Task { @MainActor [weak self] in
                    self?.navigationController?.present(
                        activityController,
                        animated: true,
                        completion: nil
                    )
                }
            }
        }
    }
}

// MARK: - LocationManagerCoordinatorDelegate

extension MainCoordinatorImplementation: LocationManagerCoordinatorDelegate {
    func locationAuthStatusDidChange(_ isValidStatus: Bool) {
        switch navigationController?.viewControllers.last {
        case _ as SingUpIntroViewController<SignUpIntroViewModelImplementation>,
             _ as LocationViewController<SignUpLocationViewModelImplementation>:
             return
        default:
            if isValidStatus {
                endUnsupportedLocation()
            }
            if !isValidStatus || !dependencies.cheatingPreventionService.passedCheatingDetection() {
                startUnsupportedLocation()
            }
        }
    }
    
    func storeLocationIsAllowedStatus(_ isValidStatus: Bool) {
        dependencies.localStorage.add(value: isValidStatus, forKey: .isEligibleLocation)
    }
    
    func getLocationIsAllowedStatus() -> Bool? {
        return dependencies.localStorage.read(forKey: .isEligibleLocation) as? Bool
    }
}

// MARK: - BaseNavigationControllerDelegate

extension MainCoordinatorImplementation: BaseNavigationControllerCoordinatorDelegate {
    @MainActor func baseNavigationControllerDidDismiss() {
        navigationController?.setViewControllers([], animated: false)
        navigationController = nil
        childCoordinators.removeAll()
        TriumphSDK.delegate?.triumphViewControllerDidDismissed()
        TriumphSDK.triumphViewControllerDidClose()
    }
    
    func baseNavigationControllerTopBarButtonDidPress(senderType: BaseTopBarButtonType) {
        switch senderType {
        case .close:
            performCloseNavigationController()
        case .back:
            performBack()
        default: return
        }
    }
    
    private func performBack() {
        navigationController?.popViewController(animated: true)
    }
    
    /// If we hit quit on the matching view controller, we submit a score of 0
    private func performCloseNavigationController() {
        if navigationController?.viewControllers.last as? MatchingViewController<MatchingViewModelImplementation> != nil {
            dependencies.swiftMessage.showQuitGameWarning { [weak self] in
                Task.init(priority: .userInitiated, operation: { [weak self] in
                    await self?.didFinish()
                })
                self?.dependencies.game.finishGame(score: 0)
            }
            return
        }
        Task.init(priority: .userInitiated, operation: { [weak self] in
            await self?.didFinish()
        })
    }
}

// MARK: - Localization

extension MainCoordinatorImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}

// MARK: - Mission completed

extension MainCoordinatorImplementation {
    @MainActor func showTreeVideo() {
        navigationController?.topViewController?.present(TreeVideoViewController(), animated: true, completion: nil)
    }
    
    @objc func missionCompleted(_ notification: Notification) {
        guard let model = notification.object as? MissionModel else { return }
        Task { @MainActor [weak self] in
            self?.dependencies.swiftMessage.showMissionCompletedMessage(mission: model)
            if model.rewardType == .tree {
                self?.showTreeVideo()
            } else {
                self?.runConfettiForClaimReward()
            }
            self?.dependencies.analytics.logEvent(
                LoggingEvent(
                    .missionCompleted,
                    parameters: ["missionID": model.id]
                )
            )
        }
    }
    
    func runConfettiForClaimReward(completion: @escaping () -> Void = {}) {
        Task { @MainActor [weak self] in
            if let view = self?.navigationController?.view {
                dependencies.confetti.runConfettiFromView(
                    view: view,
                    completion: {
                        completion()
                    },
                    time: 5
                )
            }
        }
       
    }
}

// MARK: - Server Unavailable
extension MainCoordinatorImplementation {
    @objc func serverUnavailable() {
        let alertModel = AlertModel(
            title: localizedString(Content.Error.serverUnavailable),
            message: localizedString(Content.Error.serverUnavailableDetails)
        )
        showAlert(alertModel, completion: nil)
    }
}

// MARK: - UserProfileCoordinatorDelegate
extension MainCoordinatorImplementation: UserProfileCoordinatorDelegate {
    func userProfileCoordinator(profileDidSignUp coordinator: UserProfileCoordinator) {
        Task { [weak self] in
            guard let self = self else { return }
            await self.dependencies.session.prepareSession()
            await MainActor.run {
                self.startTournaments(with: nil)
            }
        }
    }
    
    func userProfileCoordinator(profileDidFinish coordinator: UserProfileCoordinator) {
        didFinish(coordinator)
    }
}

// MARK: - LockdownViewModelCoordinatorDelegate
extension MainCoordinatorImplementation: LockdownViewModelCoordinatorDelegate {
    func lockdownViewModel(_ viewModel: LockdownViewModel, openAppStoreUrl url: URL) {
        UIApplication.shared.open(url)
    }
}
