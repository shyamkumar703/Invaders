// Copyright © TriumphSDK. All rights reserved.

import UIKit
import CoreHaptics

let topPadding: CGFloat = 80

public final class PhoneOTPViewController<ViewModel: PhoneOTPViewModel>: StepViewController, UITextFieldDelegate {

    public var state: PhoneOTPState = .phoneNumber
    
    public var viewModel: ViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }
    
    private var phoneTitleLabel: UILabel = {
        let label = UILabel(
            frame: CGRect(x: 30, y: topPadding + 20, width: UIScreen.main.bounds.size.width - 40, height: 50)
        )
        return label
    }()
    
    private var phoneNumberTextField: OTPPhoneNumberTextField = {
        var textField = OTPPhoneNumberTextField(
            frame: CGRect(x: 30, y: topPadding + 70, width: UIScreen.main.bounds.size.width - 40, height: 50)
        )
        textField.textContentType = .telephoneNumber
        textField.withFlag = true
        textField.withPrefix = true
        textField.withDefaultPickerUI = false
        return textField
    }()
    
    private lazy var codeTitleLabel: UILabel = {
        let label = UILabel(
            frame: CGRect(x: 30, y: topPadding + 130, width: UIScreen.main.bounds.size.width - 40, height: 50)
        )
        label.alpha = 0
        return label
    }()
    
    private lazy var codeTextField: UITextField = {
        let textField = UITextField(
            frame: CGRect(x: 30, y: topPadding + 180, width: UIScreen.main.bounds.size.width - 40, height: 50)
        )
        textField.alpha = 0
        return textField
    }()
    
    private lazy var changeNumberButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(
            x: UIScreen.main.bounds.size.width - 10 - 150,
            y: topPadding + 183,
            width: 150,
            height: 50
        )
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(.lightSilver, for: .normal)
        button.alpha = 0
        
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCommon()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
        setupContinueButtonColors()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.phoneNumberTextField.becomeFirstResponder()
        }
    }
    
    @objc func didPressFlagButton() {
        viewModel?.flagDidPress()
    }
    
    @objc func phoneNumberTextFieldDidChange() {
        viewModel?.phoneNumberDidChange(
            phoneNumberTextField.nationalNumber,
            phoneNumberTextField.isValidNumber
        )
    }
    
    @objc func codeTextFieldDidChange(_ sender: UITextField) {
        guard let value = sender.text else { return }
        viewModel?.codeDidChange(with: value)
    }
    
    @objc func didPressChangeNumberButton() {
        phoneNumberTextField.isUserInteractionEnabled = true
        clearFields()
        viewModel?.changeNumberButtonPressed()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel?.setLimit(textField.text ?? "", range: range, replacementString: string) ?? false
    }
}

// MARK: - Setup Common

private extension PhoneOTPViewController {
    
    func setupCommon() {
        viewModel?.viewDidLoad()
        setupContinueButton()
        setupPhoneTitleLabel()
        setupPhoneNumberTextField()
        setupCodeTitleLabel()
        setupCodeTextField()
        setupChangePhoneNumberButton()
    }
    
    func setupTitleLabel<T: UILabel>(_ label: inout T) {
        label.numberOfLines = .zero
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        label.textColor = .lightSilver
    }
    
    func setupTextField<T: UITextField>(_ textField: inout T, placeholder: String) {
        textField.font = UIFont.systemFont(ofSize: 27, weight: .regular)
        textField.textColor = .lightSilver
        textField.keyboardAppearance = .dark
        textField.keyboardType = .phonePad
        // TODO: Color Shoud be configurable
        textField.tintColor = .orandish
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.grayish]
        )
    }
    
    func clearFields() {
        phoneNumberTextField.text = nil
        codeTextField.text = nil
    }
}

// MARK: - Setup Phone number block

private extension PhoneOTPViewController {
    func setupPhoneTitleLabel() {
        setupTitleLabel(&phoneTitleLabel)
        phoneTitleLabel.text = viewModel?.phoneTitle
        view.addSubview(phoneTitleLabel)
    }
    
    func setupPhoneNumberTextField() {
        setupTextField(&phoneNumberTextField, placeholder: viewModel?.phoneNumberPlaceholder ?? "")
        phoneNumberTextField.flagButton.addTarget(self, action: #selector(didPressFlagButton), for: .touchUpInside)
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChange), for: .editingChanged)
        view.addSubview(phoneNumberTextField)
    }
    
    func setupPhoneNumberBlock(_ state: PhoneOTPState) {
        UIView.animate(withDuration: 1) { [self] in
            phoneTitleLabel.layer.opacity = state == .phoneNumber ? 1 : 0.3
            phoneNumberTextField.layer.opacity = state == .phoneNumber ? 1 : 0.3
        }
                
        if state == .phoneNumber {
            phoneNumberTextField.becomeFirstResponder()
        }

        phoneNumberTextField.isUserInteractionEnabled = state == .phoneNumber
    }
}

// MARK: - Setup Code block

private extension PhoneOTPViewController {
    func setupCodeTitleLabel() {
        setupTitleLabel(&codeTitleLabel)
        codeTitleLabel.text = viewModel?.codeTitle
        view.addSubview(codeTitleLabel)
    }
    
    func setupCodeTextField() {
        codeTextField.delegate = self
        setupTextField(&codeTextField, placeholder: viewModel?.codePlaceholder ?? "")
        codeTextField.addTarget(self, action: #selector(codeTextFieldDidChange), for: .editingChanged)
        view.addSubview(codeTextField)
    }
    
    func setupChangePhoneNumberButton() {
        changeNumberButton.setTitle(viewModel?.changeNumberButtonTitle, for: .normal)
        changeNumberButton.addTarget(self, action: #selector(didPressChangeNumberButton), for: .touchUpInside)
        view.addSubview(changeNumberButton)
    }
    
    func setupCodeBlock(_ state: PhoneOTPState) {
        UIView.animate(withDuration: 1) { [self] in
            switch state {
            case .phoneNumber:
                codeTitleLabel.alpha = 0
                setupCodeTextFieldVisability(false)
                setupChangeNumberButtonVisability(false)
            case .code:
                codeTitleLabel.alpha = 1
                setupCodeTextFieldVisability(true)
                setupChangeNumberButtonVisability(true)
                codeTextField.becomeFirstResponder()
            }
        }
    }
    
    func setupCodeTextFieldVisability(_ isVisible: Bool) {
        codeTextField.isUserInteractionEnabled = isVisible
        codeTextField.alpha = isVisible ? 1 : 0
    }
    
    func setupChangeNumberButtonVisability(_ isVisible: Bool) {
        changeNumberButton.isUserInteractionEnabled = isVisible
        changeNumberButton.isEnabled = isVisible
        changeNumberButton.alpha = isVisible ? 1 : 0
    }
}

// MARK: - Setup Continue Button Block

private extension PhoneOTPViewController {
    func setupContinueButton() {
        setupContinueButton(.phoneNumber)
        continueButton.onPress { [weak self] in
            guard let self = self else { return }
            self.isKeyboardingForceKeep = true
            self.viewModel?.continueButtonPressed()
        }
    }
    
    func setupContinueButtonColors() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.continueButton.color = .orandish
            self.continueButton.colorOnPress = .orandish.withAlphaComponent(0.8)
            self.continueButton.isGlowingEnabled = true
        }
    }
    
    func setupContinueButton(_ state: PhoneOTPState) {
        continueButton.setTitle(viewModel?.continueButtonTitle, for: .normal)
    }
}

// MARK: - PhoneOTPViewModelDelegate

extension PhoneOTPViewController: PhoneOTPViewModelViewDelegate {
    public func continueButtonIsEnabled(_ isEnabled: Bool) {
        continueButton.isEnabledState = isEnabled
        continueButton.isUserInteractionEnabled = isEnabled
    }

    public func phoneOTPerror(_ error: PhoneOTPError) {
        switch error {
        case .failedSend, .codeAttempts:
            return
        case .invalidPhoneNumber:
            phoneNumberTextField.layer.shakeAnimation(sender: phoneNumberTextField)
            withFeedbackGenerator()
        case .invalidCode, .codeLength:
            codeTextField.layer.shakeAnimation(sender: codeTextField)
            withFeedbackGenerator()
        }
    }
        
    public func phoneOTPstateDidChange(_ state: PhoneOTPState) {

        self.state = state
        
        setupContinueButton(state)
        setupPhoneNumberBlock(state)
        setupCodeBlock(state)
        
    }
    
    public func phoneOTPcodeLengthLimitExceeded(_ value: String) {
        codeTextField.text = value
    }

    public func phoneOTPformDidReset() {
        clearFields()
    }
    
    public func respondToUnknownError() {
        // clear fields and remove code field
        self.phoneNumberTextField.isUserInteractionEnabled = true
        
        didPressChangeNumberButton()
        viewModel?.changeNumberButtonPressed()
        viewModel?.showUnkownErrorMessage()
        
    }

    private func disableUIWhileLoading(isEnable: Bool) {
        self.isKeyboardingForceKeep = true
        continueButton.isEnabledState = isEnable
        changeNumberButton.isEnabled = isEnable
        phoneNumberTextField.isUserInteractionEnabled = isEnable
        codeTextField.isUserInteractionEnabled = isEnable
    }
    
    private func withFeedbackGenerator() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    public func showLoadingProcess() {
        disableUIWhileLoading(isEnable: true)
        self.startActivityIndicator()
    }
    
    public func hideLoadingProcess() {
        disableUIWhileLoading(isEnable: false)
        self.stopActivityIndicator()
    }
}

