// Copyright © TriumphSDK. All rights reserved.

import UIKit
import FirebaseAuth

public enum OTPStatus: String, Codable {
    case success
    case failed
}

public enum PhoneOTPError: Error {
    case failedSend
    case invalidPhoneNumber
    case invalidCode
    case codeLength
    case codeAttempts
}

public protocol AuthenticationDelegate: AnyObject {
    func authenticationDidAuthenticate()
}

public protocol Authentication {
    var delegate: AuthenticationDelegate? { get set }
    var currentUserId: String? { get }

    func verify(phoneNumber: String) async throws
    func verify(otp verificationCode: String) async throws
    func getIDToken() async throws -> String?
    func checkIsAvalible(_ username: String, completion: @escaping (Bool) -> Void)
    func observeUserState(onLogOut: @escaping (Bool) -> Void)
    func signOut() async
    func showDeleteAccountAlert(completion: @escaping (Bool) -> Void)
}

public enum AuthenticationError: Error {
    case noUserId
}

// MARK: - Authentication Service Impl.

class AuthenticationService: NSObject, Authentication {
 
    weak var delegate: AuthenticationDelegate?
    private var task: Task<(), Never>?
    private var stateChangeHandle: AuthStateDidChangeListenerHandle?
    
    private var dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func verify(phoneNumber: String) async throws {
        await dependencies.performance.startTrace(.verifyPhoneNumber)
        Auth.auth().settings?.isAppVerificationDisabledForTesting = await UIApplication.isAppVerificationDisabledForTesting
        let id = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
        dependencies.logger.log("phone number verification id: \(id)", .success)
        dependencies.localStorage.add(value: id, forKey: .phoneVerificationID)
        await dependencies.performance.stopTrace(.verifyPhoneNumber)
    }

    func verify(otp verificationCode: String) async throws {
        guard let verificationId = self.dependencies.localStorage.read(forKey: .phoneVerificationID) as? String else {
            self.dependencies.logger.log("Verification Id Error", .error)
            throw PhoneOTPError.invalidCode
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationId,
            verificationCode: verificationCode
        )
        
        await dependencies.performance.startTrace(.verifyOTP)
        let result = try await Auth.auth().signIn(with: credential)
        try await Auth.auth().updateCurrentUser(result.user)
        dependencies.localStorage.remove(forKey: .phoneVerificationID)
        dependencies.localStorage.add(value: true, forKey: .isAuthenticated)
        dependencies.logger.log("Code virified", .success)
        await dependencies.performance.stopTrace(.verifyOTP)
    }

    func signOut() async {
        do {
            try Auth.auth().signOut()
            await dependencies.sharedSession.resetSession()
        } catch {
            dependencies.logger.log("Logout failed", .error)
        }
    }

    func checkIsAvalible(_ username: String, completion: @escaping (Bool) -> Void) {
        task?.cancel()
        task = Task {
            let isAvailbale = await dependencies.sharedSession.checkUserNameIsAvailable(username)
            await MainActor.run {
                completion(isAvailbale)
            }
        }
    }
    
    func observeUserState(onLogOut: @escaping (Bool) -> Void) {
        stateChangeHandle = Auth.auth().addStateDidChangeListener { auth, user in
            do {
                if user == nil {
                    onLogOut(true)
                    auth.removeStateDidChangeListener(self.stateChangeHandle!)
                } else {
                    try auth.signOut()
                }
            } catch {
                onLogOut(false)
            }
        }
    }
    
    func getIDToken() async throws -> String? {
        try await Auth.auth()
            .currentUser?
            .getIDTokenResult(forcingRefresh: false)
            .token
    }
}

// MARK: - User Deletion

extension AuthenticationService {
    func showDeleteAccountAlert(completion: @escaping (Bool) -> Void) {
        let alert = AlertModel(
            title: "Delete account",
            message: "This action cannot be undone",
            okButtonTitle: "Delete",
            okButtonStyle: .destructive,
            okHandler: { [weak self] _ in
                self?.showDeleteAccountConfirmAlert(completion: completion)
            },
            cancelButtonTitle: "Cancel",
            cancelHandler: { _ in }
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
    
    func showDeleteAccountConfirmAlert(completion: @escaping (Bool) -> Void) {
        let alertModel = AlertModel(
            title: "Are you sure?",
            message: "\n You cannot create new accounts with this number \n \n All balance and tokens across all games are forfeited \n \n Account is deleted across all Triumph games and apps \n \n Type 'I understand' to confirm",
            okButtonTitle: "Submit",
            okButtonStyle: .default,
            okHandler: { _ in },
            cancelButtonTitle: "Cancel",
            cancelButtonStyle: .cancel,
            cancelHandler: { _ in }
        )
        
        let textFieldAlertModel = TextFieldAlertModel(alertModel: alertModel)
        dependencies.alertFabric.showAlert(textFieldAlertModel) { [weak self] result in
            if result?.lowercased() == "I understand".lowercased() {
                Task { [weak self] in
                    do {
                        try await self?.dependencies.sharedSession.deleteAccount()
                        completion(true)
                        await self?.dependencies.authentication.signOut()
                    } catch {
                        await MainActor.run { [weak self] in
                            self?.dependencies.swiftMessage.showUnknownErrorMessage()
                        }
                        completion(false)
                    }
                }
            } else {
                self?.showDeleteAccountFailed(completion: completion)
            }
        }
    }
    
    func showDeleteAccountFailed(completion: @escaping (Bool) -> Void) {
        let alert = AlertModel(
            title: "Failed",
            message: "'I understand' typed incorrectly",
            okButtonTitle: "Dismiss",
            okHandler: { _ in }
        )
        dependencies.alertFabric.showAlert(alert, completion: nil)
    }
}
