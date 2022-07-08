// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

protocol SignUpIntroViewModelCoordinatorDelegate: Coordinator {
    func onboardingIntroViewModelContinueDidPress<ViewModel: SignUpIntroViewModel>(_ viewModel: ViewModel)
}

protocol SignUpIntroViewModel: StepViewModel {
    var title: NSMutableAttributedString { get }
    var items: [(icon: String, title: String)] { get }
    var continueButtonTitle: String { get }
}

// MARK: - Implementation

final class SignUpIntroViewModelImplementation: SignUpIntroViewModel {

    weak var coordinatorDelegate: SignUpIntroViewModelCoordinatorDelegate?
    var dependencies: AllDependencies
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
    }

    var title: NSMutableAttributedString {
        let gameTitle = localizedString(dependencies.appInfo.title ?? dependencies.appInfo.id)
        let attributedString = NSMutableAttributedString(
            string: localizedString(
                "onboarding_intro_title",
                arguments: [gameTitle]
            )
        )
        attributedString.setColorFor(
            text: localizedString("onboarding_intro_title_part_orange"),
            color: TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR,
            font: UIFont.boldSystemFont(ofSize: 23)
        )
        attributedString.setColorFor(
            text: localizedString("onboarding_intro_title_part_green"),
            color: .green,
            font: UIFont.boldSystemFont(ofSize: 23)
        )
        return attributedString
    }
    
    var items: [(icon: String, title: String)] {
        [
            ("person.3.fill",          "onboarding_intro_list_item_01"),
            ("atom",                   "onboarding_intro_list_item_02"),
            ("building.columns.fill",  "onboarding_intro_list_item_03"),
            ("gamecontroller.fill",    "onboarding_intro_list_item_04")
        ]
            .map { ($0.0, localizedString($0.1)) }
    }
    
    var continueButtonTitle: String {
        commonLocalizedString("btn_continue_title")
    }

    func continueButtonPressed() {
        coordinatorDelegate?.onboardingIntroViewModelContinueDidPress(self)
    }
}
