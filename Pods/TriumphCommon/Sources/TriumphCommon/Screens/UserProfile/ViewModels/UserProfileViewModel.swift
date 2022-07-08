// Copyright © TriumphSDK. All rights reserved.

import UIKit

protocol UserProfileViewModelViewDelegate: BaseViewModelViewDelegate {
    func userProfileShouldShowInfoInTextField(type: TextFieldContentType, messageType: TextFieldInfoMessageType)
    func userProfileShouldShowCorrectTextField(type: TextFieldContentType, text: String)
    func userProfileShouldGoToNextTextField(type: TextFieldContentType?)
    func userProfileShouldUpdateAvatarPicture(image: UIImage)
    func userProfileShouldUpdateAvatarPicture(url: URL?)
    func userProfileShouldDisableTextField(type: TextFieldContentType)
    func userProfileShouldDismissKeyboard()
}

protocol UserProfileViewModel {
    var viewDelegate: UserProfileViewModelViewDelegate? { get set }
    var avatarTitle: String { get }
    var continueButtonTitle: String { get }
    var textFieldsContent: [TextFieldContent] { get }
    var isAvatarPhotoUpdated: Bool { get }
    
    func viewDidLoad()
    @discardableResult
    func validate(_ textFieldType: TextFieldContentType, text: String) -> Bool
    func textFieldDidChange(textFieldType: TextFieldContentType, text: String)
    func avatarViewDidTap()
    func mainButtonPressed() async
}

// MARK: - Impl.

final class UserProfileViewModelImplementation: UserProfileViewModel {
    
    weak var viewDelegate: UserProfileViewModelViewDelegate?
    private weak var coordinator: UserProfileCoordinator?
    private var screen: UserProfile
    
    typealias Dependecies = HasLogger & HasLocalization & HasSharedSession & HasAlertFabric
    private var dependencies: Dependencies
    
    private var userPublicInfo: UserPublicInfo?
    
    init(
        coordinator: UserProfileCoordinator,
        dependencies: Dependencies,
        screen: UserProfile
    ) {
        self.coordinator = coordinator
        self.dependencies = dependencies
        self.screen = screen
        self.coordinator?.viewModelDelegate = self
        Task {
            await dependencies.sharedSession.observeAllUsersPublicInfo()
            self.userPublicInfo = await dependencies.sharedSession.userPublicInfo
        }
    }
    
    deinit {
        coordinator?.didFinish()
        print("DEINIT \(self)")
    }
    
    private lazy var isUsernameAvalible = true
    private var avatarPhotoData: Data? {
        didSet {
            mainButtonShouldBeEnabled()
            goToNextEmptyTextField()
        }
    }
    
    var continueButtonTitle: String {
        switch screen {
        case .create:
            return localizedString("btn_continue_title")
        case .update:
            return "Update"
        }
    }
    
    var avatarTitle: String {
        localizedString("signup_lbl_profile_photo_title")
    }

    private var textFiledsContentBefore: [String]?
    lazy var textFieldsContent: [TextFieldContent] = {
        TextFieldContentType.allCases
            .map { prepareTextFieldContent(of: $0) }
            .filter {
                 if screen == .update {
                     return $0.type != .referral
                 } else {
                     return true
                 }
             }
    }() {
        didSet {
            mainButtonShouldBeEnabled()
        }
    }
    
    var isAvatarPhotoUpdated: Bool {
        avatarPhotoData != nil
    }
    
    func prepareTextFieldContent(of type: TextFieldContentType) -> TextFieldContent {
        switch screen {
        case .create:
            return TextFieldContent(type: type, localization: dependencies.localization)
        case .update:
            let name = userPublicInfo?.name
            let givenName: String = name?.components(separatedBy: " ").first ?? ""
            let familyName: String = name?.components(separatedBy: " ").last ?? ""
            let username = userPublicInfo?.username
            var textFieldContent = TextFieldContent(type: type, localization: dependencies.localization)
            
            switch type {
            case .givenName:
                textFieldContent.text = givenName
                return textFieldContent
            case .familyName:
                textFieldContent.text = familyName
                return textFieldContent
            case .username:
                textFieldContent.text = username
                return textFieldContent
            case .referral:
                return textFieldContent
            }
        }
    }
}

extension UserProfileViewModelImplementation {
    func viewDidLoad() {
        if screen == .update {
            textFieldsContent.forEach {
                if $0.type == .username {
                    viewDelegate?.userProfileShouldShowCorrectTextField(type: $0.type, text: "@\($0.text ?? "")")
                } else {
                    viewDelegate?.userProfileShouldShowCorrectTextField(type: $0.type, text: $0.text ?? "")
                }
            }

            textFiledsContentBefore = textFieldsContent.map { $0.text ?? "" }
            
            viewDelegate?.userProfileShouldDisableTextField(type: .username)
            Task {
                guard let profilePhotoURL = await dependencies.sharedSession.userPublicInfo?.profilePhotoURL else { return }
                await MainActor.run {
                    viewDelegate?.userProfileShouldUpdateAvatarPicture(url: URL(string: profilePhotoURL))
                }
            }
        }
    }
    
    private func mainButtonShouldBeEnabled() {
        let isEnabled = textFieldsContent
             .filter { $0.type != .referral }
             .allSatisfy { $0.text?.isEmpty == false }
        switch screen {
        case .create:
            viewDelegate?.continueButtonIsEnabled(isEnabled && isAvatarPhotoUpdated == true)
        case .update:
            if isAvatarPhotoUpdated {
                viewDelegate?.continueButtonIsEnabled(isEnabled)
                return
            }
            let difference = getTextFieldsContentDifference()
            viewDelegate?.continueButtonIsEnabled(isEnabled && difference.isEmpty == false)
        }
    }
    
    private func getTextFieldsContentDifference() -> [String?] {
        guard let textFiledsContentBefore = self.textFiledsContentBefore else {
            return []
        }
        return textFieldsContent
            .compactMap { $0.text }
            .difference(from: textFiledsContentBefore)
    }
    
    private func prepareTextFieldData() async -> (userPublicInfo: UserPublicInfo, referrUsername: String) {
        let name = textFieldsContent
            .filter({ $0.type == .givenName || $0.type == .familyName })
            .map({ $0.text ?? "" })
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let username = textFieldsContent
            .filter({ $0.type == .username })
            .map({ $0.text ?? "" })
            .joined()
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let referrerUsername = textFieldsContent
            .filter({ $0.type == .referral })
            .map({ $0.text ?? "" })
            .joined()
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        var publicInfo: UserPublicInfo = await dependencies.sharedSession.userPublicInfo ?? UserPublicInfo()
        publicInfo.name = name
        publicInfo.username = username
        dependencies.localStorage.add(value: referrerUsername, forKey: .referrerUsername)
        return (publicInfo, referrerUsername)
    }
    
    private func prepareGeneralErrorMessageForTextField(type: TextFieldContentType) -> String {
        switch type {
        case .givenName:
            return "Enter your first name"
        case .familyName:
            return "Enter your last name"
        default: return ""
        }
    }
    
    func goToNextEmptyTextField() {
        let isSomeTextFieldEmpty = textFieldsContent
            .filter { $0.type != .referral }
            .allSatisfy { $0.text?.isEmpty == false }
        
        if isSomeTextFieldEmpty {
            viewDelegate?.userProfileShouldDismissKeyboard()
            return
        }
        
        for field in textFieldsContent {
            if field.text == nil || field.text?.isEmpty == true {
                viewDelegate?.userProfileShouldGoToNextTextField(type: field.type)
                break
            }
        }
    }
    
    func goToNextTextFieldType(from textFieldType: TextFieldContentType) {
        viewDelegate?.userProfileShouldShowInfoInTextField(type: textFieldType, messageType: .empty)
        switch textFieldType {
        case .givenName:
            viewDelegate?.userProfileShouldGoToNextTextField(type: .familyName)
        case .familyName:
            viewDelegate?.userProfileShouldGoToNextTextField(type: .username)
        case .username:
            viewDelegate?.userProfileShouldGoToNextTextField(type: nil)
        default: return
        }
    }
    
    @discardableResult
    func validate(_ textFieldType: TextFieldContentType, text: String) -> Bool {
        switch textFieldType {
        case .givenName:
            return validateGivenName(text)
        case .familyName:
            return validateFamilyName(text)
        case .username:
            if validateUsername(text) {
                goToNextTextFieldType(from: .username)
                return true
            } else {
                return false
            }
        case .referral:
            return validateReferral(text)
        }
    }
    
    func avatarViewDidTap() {
        coordinator?.showAvatarAlert()
    }
    
    func mainButtonPressed() async {
        if textFieldsContent.contains(
            where: { !validate($0.type, text: $0.text ?? "") }
        ) == true { return }

        let textFieldData = await prepareTextFieldData()

        switch screen {
        case .create(let phoneNumber):
            guard let avatarPhotoData = self.avatarPhotoData else {
                dependencies.swiftMessage.showStatusLineErrorMessage(
                    "Tap the circle to select a profile photo."
                )
                return
            }

            viewDelegate?.showLoadingProcess()

            Task { [weak self] in
                do {
                    await dependencies.performance.startTrace(.createUser)
                    try await dependencies.sharedSession.createUser(
                        phoneNumber: phoneNumber,
                        referrerUsername: textFieldData.referrUsername
                    )
                    try await dependencies.sharedSession.getUser()
                    try await dependencies.sharedSession.updateUser(
                        publicInfo: textFieldData.userPublicInfo,
                        profilePhoto: avatarPhotoData
                    )
                    try await dependencies.sharedSession.getUserPublicInfo()
                    await dependencies.performance.stopTrace(.createUser)
                    await MainActor.run { [weak self] in
                        viewDelegate?.hideLoadingProcess()
                        coordinator?.profileDidSignUp()
                    }
                } catch let error as SessionError {
                    dependencies.logger.log(error.message, .error)
                    await MainActor.run { [weak self] in
                        self?.showError(error.message)
                    }
                } catch {
                    dependencies.logger.log(error.localizedDescription, .error)
                    await MainActor.run { [weak self] in
                        self?.showError()
                    }
                }
            }
        case .update:
            viewDelegate?.showLoadingProcess()

            Task { [weak self] in
                do {
                    if getTextFieldsContentDifference().isEmpty == false {
                        try await dependencies.sharedSession.updateUser(publicInfo: textFieldData.userPublicInfo)
                        dependencies.logger.log("User object updated", .success)
                    }

                    if let avatarPhotoData = self?.avatarPhotoData {
                        try await dependencies.sharedSession.updateUser(
                            publicInfo: textFieldData.userPublicInfo,
                            profilePhoto: avatarPhotoData
                        )
                        dependencies.logger.log("User photo avatar updated", .success)
                    }
                    
                    await MainActor.run { [weak self] in
                        viewDelegate?.hideLoadingProcess()
                        coordinator?.profileDidUpdated()
                        NotificationCenter.default.post(name: .profileUpdated, object: nil)
                    }
                } catch let error as SessionError {
                    dependencies.logger.log(error.message, .error)
                    await MainActor.run { [weak self] in
                        self?.showError(error.message)
                    }
                } catch {
                    dependencies.logger.log(error.localizedDescription, .error)
                    await MainActor.run { [weak self] in
                        self?.showError()
                    }
                }
            }
            
        }
    }
    
    func showError(_ message: String? = nil) {
        if let message = message {
            dependencies.swiftMessage.showErrorMessage(
                title: "Error",
                message: message
            )
        } else {
            dependencies.swiftMessage.showUnknownErrorMessage()
        }
        
        viewDelegate?.hideLoadingProcess()
    }
}

// MARK: - Field Did Change

extension UserProfileViewModelImplementation {
    func updateText(_ text: String?, for textFieldType: TextFieldContentType) {
        guard let textFieldContent = textFieldsContent.filter({ $0.type == textFieldType }).first,
              let index = textFieldsContent.firstIndex(of: textFieldContent) else {
            return
        }
        
        self.textFieldsContent[index].text = text
    }
    
    func textFieldDidChange(textFieldType: TextFieldContentType, text: String) {
        switch textFieldType {
        case .givenName:
            viewDelegate?.userProfileShouldShowInfoInTextField(
                type: .givenName,
                messageType: .info(nil)
            )
            updateText(text, for: .givenName)
        case .familyName:
            viewDelegate?.userProfileShouldShowInfoInTextField(
                type: .familyName,
                messageType: .info(nil)
            )
            updateText(text, for: .familyName)
        case .username:
            usernameTextFieldDidChange(text: text)
        case .referral:
            updateText(text, for: .referral)
        }
    }
}

private extension UserProfileViewModelImplementation {

    func usernameTextFieldDidChange(text: String) {

        if text.isEmpty == false {
            if text.first?.isNumber == true {
                viewDelegate?.userProfileShouldShowCorrectTextField(type: .username, text: "")
                viewDelegate?.userProfileShouldShowInfoInTextField(
                    type: .username,
                    messageType: .error("Username cannot start with a number")
                )
                updateText(nil, for: .username)
                return
            }
            
            if text.first != "@" {
                viewDelegate?.userProfileShouldShowCorrectTextField(
                    type: .username,
                    text: "@" + text
                )
            }
            
            if text == "@" {
                viewDelegate?.userProfileShouldShowCorrectTextField(type: .username, text: "")
                viewDelegate?.userProfileShouldShowInfoInTextField(type: .username, messageType: .empty)
                updateText(nil, for: .username)
                return
            }
        }
        
        if text.last == " " {
            viewDelegate?.userProfileShouldShowCorrectTextField(
                type: .username,
                text: String(text.prefix(text.count - 1))
            )
            viewDelegate?.userProfileShouldShowInfoInTextField(
                type: .username,
                messageType: .info(nil)
            )
        }

        validateUsername(text)
    }
}

// MARK: - Validation

private extension UserProfileViewModelImplementation {
    @discardableResult
    func validateGivenName(_ text: String) -> Bool {
        validateNames(.givenName, text: text)
    }
    
    @discardableResult
    func validateFamilyName(_ text: String) -> Bool {
        validateNames(.familyName, text: text)
    }
    
    @discardableResult
    func validateUsername(_ text: String) -> Bool {
        if screen == .update { return true }
        let username = text.first == "@" ? text.dropFirst().lowercased() : text
        
        if username.isEmpty {
            viewDelegate?.userProfileShouldShowInfoInTextField(
                type: .username,
                messageType: .error("Enter a username")
            )
            return false
        }
        
        let allowableChars = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'-_0123456789"
        )
        
        if String(username).rangeOfCharacter(from: allowableChars.inverted) != nil {
            viewDelegate?.userProfileShouldShowInfoInTextField(
                type: .username,
                messageType: .error("No special characters")
            )
            return false
        }
        
        if username.first?.isNumber == true {
            self.viewDelegate?.userProfileShouldShowInfoInTextField(
                type: .username,
                messageType: .error("Username cannot start with a number")
            )
            return false
        }
        
        updateText(username, for: .username)
        checkIsAvalible(username)
        return isUsernameAvalible
    }
    
    @discardableResult
    func validateReferral(_ text: String) -> Bool {
        viewDelegate?.userProfileShouldGoToNextTextField(type: nil)
        return true
    }
    
    func checkIsAvalible(_ username: String) {
        dependencies.authentication.checkIsAvalible(username) { isAvailable in
            let messageType: TextFieldInfoMessageType = isAvailable
            ? .success("\(username) is available")
            : .error("\(username) is taken")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.textFieldsContent.first(where: { $0.type == .username})?.text == nil {
                    return
                }
                self.viewDelegate?.userProfileShouldShowInfoInTextField(
                    type: .username,
                    messageType: messageType
                )
            }
        }
    }
}

private extension UserProfileViewModelImplementation {
    func validateNames(_ textFieldType: TextFieldContentType, text: String) -> Bool {
        let count = text
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .count
        
        viewDelegate?.userProfileShouldShowCorrectTextField(
            type: textFieldType,
            text: text.trimmingCharacters(in: .whitespaces)
        )
        updateText(text.trimmingCharacters(in: .whitespaces), for: textFieldType)
        
        if text.isEmpty || count != 1 {
            let message = prepareGeneralErrorMessageForTextField(type: textFieldType)
            viewDelegate?.userProfileShouldShowInfoInTextField(
                type: textFieldType,
                messageType: .error(message)
            )
            return false
        }
        
        let allowableChars = CharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'-"
        )
        
        if text.rangeOfCharacter(from: allowableChars.inverted) != nil {
            viewDelegate?.userProfileShouldShowInfoInTextField(
                type: textFieldType,
                messageType: .error("No special characters")
            )
            return false
        }
        
        goToNextTextFieldType(from: textFieldType)
        return true
    }
}

extension UserProfileViewModelImplementation: UserProfileCoordinatorViewModelDelegate {
    func userProfileDidCropToImage(_ image: UIImage) {
        viewDelegate?.userProfileShouldUpdateAvatarPicture(image: image)
        avatarPhotoData = image.jpegData(compressionQuality: Constants.AVATAR_PHOTO_COMPRESSION_FACTOR)
    }
}

// MARK: - Localization

extension UserProfileViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
