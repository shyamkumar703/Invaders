// Copyright © TriumphSDK. All rights reserved.

import UIKit
import FirebaseAuth

public enum PhoneOTPState: Int {
    case phoneNumber
    case code
}

public protocol PhoneOTPViewModelCoordinatroDelegate: Coordinator {
    func phoneOTPViewModel<ViewModel: PhoneOTPViewModel>(_ viewModel: ViewModel, signUpWith phoneNumber: String)
    func phoneOTPViewModelDidAuthenticated()
}

// MARK: - Delegate

public protocol PhoneOTPViewModelViewDelegate: BaseViewModelViewDelegate {
    func phoneOTPerror(_ error: PhoneOTPError)
    func phoneOTPstateDidChange(_ state: PhoneOTPState)
    func phoneOTPcodeLengthLimitExceeded(_ value: String)
    func phoneOTPformDidReset()
    func respondToUnknownError()
}

// MARK: - PhoneOTPViewModel

public protocol PhoneOTPViewModel: BaseViewModel {
    var viewDelegate: PhoneOTPViewModelViewDelegate? { get set }
    var phoneTitle: String { get }
    var phoneNumberPlaceholder: String { get }
    var continueButtonTitle: String { get }
    var codePlaceholder: String { get }
    var codeTitle: String { get }
    var changeNumberButtonTitle: String { get }
    
    func continueButtonPressed()
    func flagDidPress()
    func phoneNumberDidChange(_ value: String, _ isValidNumber: Bool)
    func codeDidChange(with value: String)
    func changeNumberButtonPressed()
    func setLimit(_ value: String, range: NSRange, replacementString string: String) -> Bool
    func showUnkownErrorMessage()
}

public extension PhoneOTPViewModel {
    func viewDidLoad() {
        viewDelegate?.continueButtonIsEnabled(false)
    }
}

// MARK: - Implementation

public final class PhoneOTPViewModelImplementation: PhoneOTPViewModel {

    @PhoneNumber private var phoneNumber: String
    private lazy var code: String = ""
    private var attempts: Int = 0
    private let codeLengthLimit: Int = 6
    private let codeAttemptsLimit: Int = 5
    private var state: PhoneOTPState = .phoneNumber {
        didSet {
            isContinueButtonEnable = false
            viewDelegate?.phoneOTPstateDidChange(state)
        }
    }
    private var isContinueButtonEnable: Bool = false {
        didSet {
            viewDelegate?.continueButtonIsEnabled(isContinueButtonEnable)
        }
    }

    public weak var coordinatorDelegate: PhoneOTPViewModelCoordinatroDelegate?
    public weak var viewDelegate: PhoneOTPViewModelViewDelegate?
    public var dependencies: Dependencies
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public func viewWillAppear() {
        if state != .phoneNumber {
            self.state = .phoneNumber
            self.viewDelegate?.phoneOTPformDidReset()
        }
    }

    public var phoneTitle: String {
        localizedString("phoneotp_phone_title")
    }
    
    public var phoneNumberPlaceholder: String {
        localizedString("phoneotp_phone_number_placeholder")
    }
    
    public var codeTitle: String {
        localizedString("phoneotp_code_title")
    }
    
    public var changeNumberButtonTitle: String {
        localizedString("phoneotp_change_number_button_title")
    }
    
    public var codePlaceholder: String {
        localizedString("phoneotp_code_placeholder")
    }
    
    public var continueButtonTitle: String {
        switch state {
        case .phoneNumber:
            return localizedString("phoneotp_send_code_title")
        case .code:
            switch attempts {
            case 1: return localizedString("btn_try_again_title")
            case 2: return localizedString(
                "phoneotp_charm_rd_times", arguments: [attempts + 1]
            )
            case 3...codeAttemptsLimit: return localizedString(
                "phoneotp_charm_th_times", arguments: [attempts + 1]
            )
            default: return localizedString("btn_confirm_title")
            }
        }
    }

    public func continueButtonPressed() {
        switch state {
        case .phoneNumber: continueWithPhoneNumber()
        case .code: continueWithCode()
        }
    }
    
    private func continueWithPhoneNumber() {
        if isContinueButtonEnable == true {
            sendCodeToPhoneNumber()
        } else {
            invalidPhoneNumberError()
        }
    }
    
    private func invalidPhoneNumberError() {
        viewDelegate?.phoneOTPerror(.invalidPhoneNumber)
        dependencies.swiftMessage.showStatusLineErrorMessage(
            localizedString("phoneotp_phone_number_err_msg")
        )
    }
    
    private func continueWithCode() {
        if isContinueButtonEnable == true {
            checkCode()
        } else {
            viewDelegate?.phoneOTPerror(.invalidCode)
            dependencies.swiftMessage.showStatusLineErrorMessage(
                localizedString("phoneotp_wrong_code_msg")
            )
        }
    }
    
    public func flagDidPress() {
        let alert = AlertModel(title: "", message: localizedString("phoneotp_us_number_only_msg"))
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
    
    public func phoneNumberDidChange(_ value: String, _ isValidNumber: Bool) {
        self.phoneNumber = value
        self.isContinueButtonEnable = isValidNumber
    }
    
    public func codeDidChange(with value: String) {
        var value = value
        self.isContinueButtonEnable = value.count >= codeLengthLimit
        if value.count == codeLengthLimit + 1 {
            viewDelegate?.phoneOTPerror(.codeLength)
            value.remove(at: value.index(before: value.endIndex))
            viewDelegate?.phoneOTPcodeLengthLimitExceeded(value)
        }
        self.code = value
    }
    
    public func changeNumberButtonPressed() {
        state = .phoneNumber
    }
    
    public func setLimit(_ value: String, range: NSRange, replacementString string: String) -> Bool {
        guard let stringRange = Range(range, in: value) else { return false }
        let updatedText = value.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= codeLengthLimit + 2
    }
    
    public func reset() {
        self.code = ""
        self.isContinueButtonEnable = false

        if attempts >= codeAttemptsLimit {
            attempts = 0
            self.viewDelegate?.phoneOTPformDidReset()
            self.state = .phoneNumber
        } else {
            attempts += 1
            state = .code
        }
    }
    
    public func showUnkownErrorMessage() {
        dependencies.swiftMessage.showStatusLineErrorMessage(localizedString("msg_err_unknown"))
    }
}

private extension PhoneOTPViewModelImplementation {

    func sendCodeToPhoneNumber() {
        self.state = .code
        self.startVerifying()
    }
    
    func startVerifying() {
        Task { [weak self] in
            do {
                try await self?.dependencies.authentication.verify(phoneNumber: self?.phoneNumber ?? "000000000")
            } catch let error {
                await MainActor.run { [weak self] in
                    self?.dependencies.logger.log(error.localizedDescription, .error)
                    self?.invalidPhoneNumberError()
                }
            }
        }
    }
    
    func prepareForSignUp() async {
        await MainActor.run { [weak self] in
            self?.viewDelegate?.hideLoadingProcess()
            guard let self = self else { return }
            self.coordinatorDelegate?.phoneOTPViewModel(self, signUpWith: phoneNumber)
        }
    }
    
    func signIn() async {
        do {
            await dependencies.performance.startTrace(.signIn)
            try await dependencies.sharedSession.getUser()
            try await dependencies.sharedSession.getUserPublicInfo()
            guard await dependencies.sharedSession.user != nil else {
                await prepareForSignUp()
                return
            }

            await MainActor.run { [weak self] in
                self?.viewDelegate?.hideLoadingProcess()
                self?.coordinatorDelegate?.phoneOTPViewModelDidAuthenticated()
            }
            dependencies.logger.log("Login", .success)
            await dependencies.performance.stopTrace(.signIn)
        } catch let error as SessionError {
            switch error {
            case .noData:
                dependencies.logger.log("User doesn't have stored data. Launching profile creation...", .warning)
                await prepareForSignUp()
            default:
                dependencies.logger.log(error.message, .error)
            }
        } catch {
            dependencies.logger.log(error.localizedDescription, .error)
        }
    }
    
    func checkCode() {
        self.viewDelegate?.showLoadingProcess()
        
        Task { [weak self] in
            do {
                try await self?.dependencies.authentication.verify(otp: self?.code ?? "000000")
                await self?.signIn()
            } catch let error as NSError {
                await MainActor.run { [weak self] in
                    switch AuthErrorCode(_nsError: error).code {
                    case .tooManyRequests:
                        self?.dependencies.swiftMessage.showStatusLineErrorMessage(
                            localizedString("Try again in 5 minutes")
                        )
                    case .invalidVerificationCode:
                        self?.dependencies.swiftMessage.showStatusLineErrorMessage(
                            localizedString("phoneotp_wrong_code_title")
                        )
                    default:
                        self?.dependencies.swiftMessage.showStatusLineErrorMessage(
                            localizedString("Something went wrong. Try again.")
                        )
                    }
                    self?.viewDelegate?.hideLoadingProcess()
                    self?.viewDelegate?.phoneOTPerror(.invalidCode)
                    self?.dependencies.logger.log(error.localizedDescription, .error)

                    self?.reset()
                }
            }
        }
    }
}
