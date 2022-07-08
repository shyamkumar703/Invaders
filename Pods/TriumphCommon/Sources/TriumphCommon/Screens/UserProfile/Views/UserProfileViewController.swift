// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TweeTextField

final class UserProfileViewController: StepViewController {
    
    private lazy var tappableAvatarView: AvatarView = {
        let view = AvatarView(size: 120)
        view.isUserInteractionEnabled = true
        view.userpicImage = UIImage(named: "sky-default-avatar")
        view.titleLabel.font = .systemFont(ofSize: 17)
        view.titleLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return view
    }()
    
    private lazy var textFieldsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.distribution  = .fillEqually
        return stackView
    }()
    
    var viewModel: UserProfileViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }

    override func viewDidLoad() {
        view.backgroundColor = .black
        setupViews()
        setupContinueButton()
        setupTextFieldsStackView()
        setupConstrains()
        
        super.viewDidLoad()
        viewModel?.viewDidLoad()
        isBottomContentFollowKeyboard = false
        hideKeyboardWhenTappedAround()
    }
}

// MARK: - Setup

extension UserProfileViewController {
    func setupViews() {
        tappableAvatarView.title = viewModel?.avatarTitle
        tappableAvatarView.onPress { [weak self] in
            guard let self = self else { return }
            self.viewModel?.avatarViewDidTap()
        }
        view.addSubview(tappableAvatarView)
        tappableAvatarView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupTextFieldsStackView() {
        view.addSubview(textFieldsStackView)
        textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        viewModel?.textFieldsContent.forEach {
            let textField = TweeTextField($0)
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            textField.delegate = self
            
            if $0.type == .username || $0.type == .referral {
                textField.spellCheckingType = .no
            }

            textFieldsStackView.addArrangedSubview(textField)
        }
        
        guard let textFields = textFieldsStackView.arrangedSubviews as? [TweeTextField] else { return }
        addInputAccessoryForTextFields(textFields: textFields, dismissable: true, previousNextable: true)
    }
    
    func setupContinueButton() {
        continueButtonIsEnabled(false)
        continueButton.setTitle(viewModel?.continueButtonTitle, for: .normal)
        continueButton.onPress { [weak self] in
            guard let self = self else { return }
            Task {
                await self.viewModel?.mainButtonPressed()
            }
        }
    }
    
    func showErrorMessageInTextField(_ textField: TweeTextField, message: String?) {
        textField.layer.shakeAnimation(sender: textField)
        textField.infoLabel.text = message
        textField.infoTextColor = .red
        textField.infoFontSize = 14.0
    }
    
    @objc func textFieldDidChange(_ textField: TweeTextField) {
        viewModel?.textFieldDidChange(
            textFieldType: textField.contentType,
            text: textField.text ?? ""
        )
    }
    
    func getTextField(of type: TextFieldContentType) -> TweeTextField? {
        return textFieldsStackView.arrangedSubviews.first(
            where: { ($0 as? TweeTextField)?.contentType == type }
        ) as? TweeTextField
    }
    
    private func disableUIWhileLoading(isEnable: Bool) {
        textFieldsStackView.isUserInteractionEnabled = isEnable
    }
}

extension UserProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textField = textField as? TweeTextField else { return false }
        return viewModel?.validate(textField.contentType, text: textField.text ?? "") ?? false
    }
}

// MARK: - Constrains

extension UserProfileViewController {
    func setupConstrains() {
        bottomButtonConstraint = -26
        
        NSLayoutConstraint.activate([
            tappableAvatarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tappableAvatarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            tappableAvatarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            tappableAvatarView.heightAnchor.constraint(equalToConstant: 156),
            tappableAvatarView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: navigationController?.isModalInPresentation == true ? 20 : 10
            )
        ])
        
        NSLayoutConstraint.activate([
            textFieldsStackView.topAnchor.constraint(equalTo: tappableAvatarView.bottomAnchor, constant: 20),
            textFieldsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            textFieldsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
}

// MARK: - SignUpViewModelViewDelegate

extension UserProfileViewController: UserProfileViewModelViewDelegate {
    func continueButtonIsEnabled(_ isEnabled: Bool) {
        continueButton.isEnabledState = isEnabled
        // continueButton.isUserInteractionEnabled = isEnabled
    }
    
    func userProfileShouldShowInfoInTextField(type: TextFieldContentType, messageType: TextFieldInfoMessageType) {
        guard let textField = getTextField(of: type) else { return }
        switch messageType {
        case .error(let message):
            showErrorMessageInTextField(textField, message: message)
        case .success(let message):
            textField.infoTextColor = .greenish
            textField.infoLabel.text = message
        case .info(let message):
            textField.infoTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            guard let message = message else { return }
            textField.infoLabel.text = message
        case .empty:
            textField.infoLabel.text = nil
        }
    }
    
    func userProfileShouldShowCorrectTextField(type: TextFieldContentType, text: String) {
        guard let textField = getTextField(of: type) else { return }
        textField.text = text
    }
    
    func userProfileShouldGoToNextTextField(type: TextFieldContentType?) {
        guard let textFieldType = type else {
            dismissKeyboard()
            return
        }

        guard let textField = getTextField(of: textFieldType) else { return }
        
        if textField.isEnabled {
            textField.becomeFirstResponder()
        } else {
            dismissKeyboard()
        }
    }
    
    func userProfileShouldUpdateAvatarPicture(image: UIImage) {
        tappableAvatarView.userpicImage = image
    }
    
    func userProfileShouldUpdateAvatarPicture(url: URL?) {
        tappableAvatarView.userpicUrl = url
    }
    
    func userProfileShouldDisableTextField(type: TextFieldContentType) {
        guard let textField = getTextField(of: type) else { return }
        textField.isEnabled = false
        textField.alpha = 0.5
    }
    
    func userProfileShouldDismissKeyboard() {
        if isKeyboardShowing {
            dismissKeyboard()
        }
    }
    
    func showLoadingProcess() {
        disableUIWhileLoading(isEnable: true)
        self.startActivityIndicator()
    }
    
    func hideLoadingProcess() {
        disableUIWhileLoading(isEnable: false)
        self.stopActivityIndicator()
    }
}
