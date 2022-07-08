// Copyright © TriumphSDK. All rights reserved.

import Foundation

// MARK: - Coordinator Delegate

public protocol AgeViewModelCoordinatorDelegate: Coordinator {
    
    /// Runs after user passed age and location screens 
    func ageViewModelDidOnboarded<ViewModel: AgeViewModel>(_ viewModel: ViewModel)
}

// MARK: - View Delegate

public protocol AgeViewModelViewDelegate: BaseViewModelViewDelegate {}

// MARK: - View Model

public protocol AgeViewModel: StepViewModel {
    var coordinatorDelegate: AgeViewModelCoordinatorDelegate? { get set }
    var viewDelegate: AgeViewModelViewDelegate? { get set }
    var appleNotSponsorDisclaimer: NSMutableAttributedString { get }
    var title: String { get }
    var subTitle: String { get }
    var continueButtonTitle: String { get }
    var defaultDate: Date? { get }
    
    func datePickerDidChange(_ value: Date)
    func viewWillAppear()
}

// MARK: - Implementation

public final class AgeViewModelImplementation: AgeViewModel {
    
    public weak var coordinatorDelegate: AgeViewModelCoordinatorDelegate?
    public weak var viewDelegate: AgeViewModelViewDelegate?
    
    public var dependencies: Dependencies
    
    private var years: Int? {
        didSet {
            viewDelegate?.continueButtonIsEnabled(true)
        }
    }
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public var appleNotSponsorDisclaimer: NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(
            string: localizedString("terms_of_use")
        )
        attributedString.setLinkFor(
            text: "Terms and Conditions",
            link: "https://fanatical-raisin-d1c.notion.site/Terms-Conditions-7ea2223818404758b8c61d6250f4d9cb"
        )
        attributedString.setLinkFor(
            text: "Privacy Policy",
            link: "https://fanatical-raisin-d1c.notion.site/Privacy-Policy-a1133ebafae1469bbfd3bae2f68e917a"
        )
        return attributedString
    }
    
    private var birthday: Date? {
        dependencies.localStorage.read(forKey: .birthday) as? Date
    }
    
    public var defaultDate: Date? {
        birthday ?? Calendar.current.date(byAdding: .year, value: 0, to: Date())
    }
    
    private var isAdult: Bool {
        guard let years = self.years else { return false }
        return years >= 18
    }
    
    public var title: String {
        localizedString("age_title")
    }
    
    public var subTitle: String {
        localizedString("age_subtitle")
    }
    
    public var continueButtonTitle: String {
        localizedString("btn_confirm_title")
    }
    
    public func viewWillAppear() {
        guard let birthday = self.birthday else {
            viewDelegate?.continueButtonIsEnabled(false)
            return
        }
        datePickerDidChange(birthday)
    }
    
    public func datePickerDidChange(_ value: Date) {
        let today = Date()
        let age = Calendar.current.dateComponents([.year], from: value, to: today)
        let years = age.year ?? 0
        self.years = years
        dependencies.localStorage.add(value: value, forKey: .birthday)
    }
    
    public func showTermsAlert() {
        let alert = AlertModel(
            title: localizedString("age_terms_alert_title"),
            message: localizedString("age_terms_alert_msg"),
            okButtonTitle: localizedString("btn_agree_title"),
            okHandler: { _ in
                let confirmationAlert = AlertModel(
                    title: self.localizedString("age_confirmation_alert_title"),
                    message: self.localizedString("age_confirmation_alert_msg"),
                    okButtonTitle: self.localizedString("btn_agree_title"),
                    okHandler: {
                        _ in
                        self.dependencies.localStorage.add(value: true, forKey: .terms)
                        self.continueButtonPressed()
                    }, cancelButtonTitle: self.localizedString("btn_cancel_title"), cancelHandler: { _ in })
                self.dependencies.alertFabric.showAlert(confirmationAlert, completion: nil)
            },
            cancelButtonTitle: localizedString("btn_cancel_title"),
            cancelHandler: { _ in }
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
    
    public func continueButtonPressed() {
        if isAdult == false {
            showLess18Alert()
        } else if dependencies.localStorage.read(forKey: .terms) as? Bool != true {
            showTermsAlert()
        } else {
            coordinatorDelegate?.ageViewModelDidOnboarded(self)
        }
    }
}

// MARK: - Alerts

private extension AgeViewModelImplementation {
    func showLess18Alert() {
        let alertTitle = dependencies.localization.localizedString(
            "age_less18_alert_title", arguments: [years ?? 0]
        )
        let alert = AlertModel(
            title: alertTitle,
            message: localizedString("age_less18_alert_msg"),
            okButtonTitle: localizedString("btn_ok_title"),
            okHandler: { _ in
                self.coordinatorDelegate?.didFinish()
            }
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
}
