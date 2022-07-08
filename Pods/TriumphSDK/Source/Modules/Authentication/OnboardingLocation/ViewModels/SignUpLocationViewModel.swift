// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

// MARK: - General Protocol

protocol SignUpLocationViewModel: BaseLocationViewModel {}

// MARK: - Coordinator Delegate

protocol SignUpLocationViewModelCoordinatorDelegate: Coordinator {
    func onboardingLocationViewModelContinueDidPress<ViewModel: SignUpLocationViewModel>(_ viewModel: ViewModel)
}

// MARK: - View Delegate

protocol SignUpLocationViewModelViewDelegate: BaseLocationViewModelViewDelegate {}

// MARK: - Implementation

final class SignUpLocationViewModelImplementation: SignUpLocationViewModel {

    weak var coordinatorDelegate: SignUpLocationViewModelCoordinatorDelegate?
    weak var viewDelegate: SignUpLocationViewModelViewDelegate?
    var dependencies: Dependencies
    var shouldShowActionButton: Bool = true
    private var isRequestedAuthorization = false
    
    var title: NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(
            string: localizedString("onboarding_location_title", arguments: [33])
        )
        attributedString.setColorFor(
            text: localizedString("onboarding_location_title_part_orange"),
            color: TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR,
            font: UIFont.boldSystemFont(ofSize: 23)
        )
        return attributedString
    }
    
    var descriptionText: String {
        localizedString("onboarding_location_title_and_counting")
    }

    var continueButtonTitle: String {
        commonLocalizedString("btn_continue_title")
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        dependencies.location.delegate = self
    }

    func continueButtonPressed() {
        if dependencies.location.isNotDetermined == true {
            dependencies.location.requestAuthorization()
            isRequestedAuthorization = true
        } else if dependencies.location.isValidToContinue == true {
            coordinatorDelegate?.onboardingLocationViewModelContinueDidPress(self)
        } else {
            dependencies.alertFabric.showLocationAlert()
        }
    }

    func didFinish() {
        coordinatorDelegate?.didFinish()
    }
}

// MARK: - LocationManagerDelegate

extension SignUpLocationViewModelImplementation: LocationManagerDelegate {
    func locationAuthStatusDidChange(_ isValidStatus: Bool) {
        if isRequestedAuthorization == true && isValidStatus == true {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.coordinatorDelegate?.onboardingLocationViewModelContinueDidPress(self)
            }
        }
    }
}
