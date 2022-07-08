// Copyright © TriumphSDK. All rights reserved.

import UIKit
import PassKit
import TriumphCommon

enum SignUpStep {
    case intro
    case location
    case otp
    case birthday
}

protocol AuthenticationCoordinatorDelegate: Coordinator {
    func authenticationCoordinator(didAuthenticated coordinator: AuthenticationCoordinator)
    func authenticationCoordinator(_ coordinator: AuthenticationCoordinator, userProfile: UserProfile)
}

protocol AuthenticationCoordinatorSignUpDelegate: AnyObject {
    func authenticationCoordinatorDidCropToImage(_ image: UIImage)
}

protocol AuthenticationCoordinator: Coordinator {
    var signUpDelegate: AuthenticationCoordinatorSignUpDelegate? { get set }
    /// Starts user profile creation screen
    func userProfile(_ userProfile: UserProfile)
    func didFinish()
    /// Called once user is authenticated
    func didAuthenticated()
}

// MARK: - Impl.

final class AuthenticationCoordinatorImplementation: NSObject, AuthenticationCoordinator {
    
    private lazy var imagePickerController = UIImagePickerController()
    var childCoordinators: [Coordinator] = []
    
    weak var delegate: AuthenticationCoordinatorDelegate?
    weak var signUpDelegate: AuthenticationCoordinatorSignUpDelegate?

    var parentCoordinator: Coordinator?
    private(set) var navigationController: BaseNavigationController?
    private var dependencies: AllDependencies
    private var phoneNumber: String?
    
    init(navigationController: BaseNavigationController, dependencies: AllDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    deinit {
        print("DEINIT \(self)")
    }

    func start() {
        start(from: .intro)
        dependencies.analytics.logEvent(LoggingEvent(.accountCreationStarted))
    }
    
    func start(from step: SignUpStep) {
        switch step {
        case .intro:
            startIntro()
        case .location:
            startLocaion()
        case .otp:
            startOTP()
        case .birthday:
            startBirthday()
        }
    }
    
    func startIntro() {
        let viewController = SingUpIntroViewController<SignUpIntroViewModelImplementation>()
        let viewModel = SignUpIntroViewModelImplementation(dependencies: dependencies)
        Task { @MainActor [weak self] in
            viewModel.coordinatorDelegate = self
            viewController.viewModel = viewModel
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func startOTP() {
        let viewController = PhoneOTPViewController<PhoneOTPViewModelImplementation>()
        let viewModel = PhoneOTPViewModelImplementation(dependencies: dependencies)
        Task { @MainActor [weak self] in
            viewModel.coordinatorDelegate = self
            viewController.viewModel = viewModel
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    /// Presents the location checker page
    func startLocaion() {
        let viewController = LocationViewController<SignUpLocationViewModelImplementation>()
        let viewModel = SignUpLocationViewModelImplementation(dependencies: dependencies)
        Task { @MainActor [weak self] in
            viewModel.coordinatorDelegate = self
            viewController.viewModel = viewModel
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    /// Presents age checker page
    func startBirthday() {
        let viewController = AgeViewController<AgeViewModelImplementation>()
        let viewModel = AgeViewModelImplementation(dependencies: dependencies)
        Task { @MainActor [weak self] in
            viewModel.coordinatorDelegate = self
            viewController.viewModel = viewModel
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func userProfile(_ userProfile: UserProfile) {
        (parentCoordinator as? MainCoordinator)?.startUserProfile(screen: userProfile)
    }
    
    func didFinish() {
        parentCoordinator?.didFinish()
    }
    
    func didAuthenticated() {
        Task { [weak self] in
            await self?.dependencies.session.prepareSession()
            (self?.parentCoordinator as? MainCoordinator)?.startTournaments(with: nil)
        }
    }
}

// MARK: - OnboardingIntroViewModelCoordinatorDelegate

extension AuthenticationCoordinatorImplementation: SignUpIntroViewModelCoordinatorDelegate {
    @MainActor func onboardingIntroViewModelContinueDidPress<ViewModel: SignUpIntroViewModel>(_ viewModel: ViewModel) {
        startLocaion()
    }
}

// MARK: - OnboardingIntroViewModelCoordinatorDelegate

extension AuthenticationCoordinatorImplementation: SignUpLocationViewModelCoordinatorDelegate {
    @MainActor func onboardingLocationViewModelContinueDidPress<ViewModel: SignUpLocationViewModel>(_ viewModel: ViewModel) {
        startOTP()
    }
}

// MARK: - PhoneOTPViewModelCoordinatroDelegate

extension AuthenticationCoordinatorImplementation: PhoneOTPViewModelCoordinatroDelegate {
    func phoneOTPViewModel<ViewModel: PhoneOTPViewModel>(_ viewModel: ViewModel, signUpWith phoneNumber: String) {
        self.phoneNumber = phoneNumber
        startBirthday()
    }
    
    func phoneOTPViewModelDidAuthenticated() {
        didAuthenticated()
    }
}

// MARK: - OnboardingAgeViewModelCoordinatorDelegate

extension AuthenticationCoordinatorImplementation: AgeViewModelCoordinatorDelegate {
    func ageViewModelDidOnboarded<ViewModel: AgeViewModel>(_ viewModel: ViewModel) {
        guard let phoneNumber = self.phoneNumber else { return }
        userProfile(.create(phoneNumber))
    }
}
