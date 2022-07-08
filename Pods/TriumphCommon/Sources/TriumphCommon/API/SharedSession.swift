// Copyright © TriumphSDK. All rights reserved.

import Foundation

public protocol SharedSessionDelegate: AnyObject {
    func sessionDataDidPrepare()
    func sessionLockdownDidUpdate()
    
    func userCanClaimUnclaimedBalance()
    func firstLoginSequenceShouldRun()
}

extension SharedSessionDelegate {
    func userDidUpdate() {}
    func firstLoginSequenceShouldRun() {}
}

public protocol SharedSession: Actor {
    
    var delegate: SharedSessionDelegate? { get set }
    
    // MARK: - Session
    
    // var presets: Presets { get }
    var lockdown: LockdownResponse? { get }
    func updateLockdownFromLocalStorage()
    func prepareIntercom()
    
    /// Computed var in case to check `localStorage` if user is Authenticated or not
    var isSignedUp: Bool { get }
    var shouldShowLockdown: Bool { get }
    
    @discardableResult
    func getLockdownStatus(for app: ApplicationType) async -> LockdownResponse
    func observeLockdownStatus(for app: ApplicationType)
    func resetSession() async
    
    // MARK: - User
    
    /// The most actual current user object.
    /// Only from this place should be used info about user.
    var user: User? { get }
    
    var referrerFirstName: String? { get async }
    var currentUserId: String? { get }
    var userPublicInfo: UserPublicInfo? { get }
    var allUsersPublicInfo: [UserPublicInfo] { get }
    
    /// The method is used for Sign Up process. The method should be called only once.
    /// - Parameters:
    ///     - phoneNumber: User's *phone number string*
    ///     - referrerUsername: Reffers user name
    /// - Throws: `SessionError`
    /// - Attention: The method should use only Secure call
    func createUser(phoneNumber: String, referrerUsername: String?) async throws
    
    /// Get user object from Firestore only once
    /// - The method can be called in following places:
    ///     - `Coordinator.start()`
    ///     - `PhoneOTP`: right after successful signing in
    ///     - `SignUp`: right after successful siging up
    /// Call this method only once per session before observingUser()
    /// - Throws: `SessionError`
    /// - Returns: User object
    @discardableResult
    func getUser() async throws -> User

    @discardableResult
    func getUserPublicInfo() async throws -> UserPublicInfo
    func getUserPublicInfo(from uid: String) async throws -> UserPublicInfo
    
    /// Prepare standart user object without error
    func prepareUser() async
    
    /// Call this method only once per session after `getUser()`
    func observeUser()
    func observePublicUserInfo()
    func observeAllUsersPublicInfo()
    
    /// Update user object in Firestore
    /// - Update User object is needed only in two cases:
    ///     1. In Sign Up process when the user has been created
    ///     2. In UserProfile screen when the user wants update the profile info
    /// - Parameters:
    ///     - firstname: User's Firstname
    ///     - surname: User's surname
    ///     - username: username which can be created only once
    ///     - profilePhotoURL: a url which can obtain from `getProfilePhotoUrlOfCurrentUser()`
    /// - Attention: The method uses Secure call
    /// - Throws: `SessionError`
    func updateUser(publicInfo: UserPublicInfo) async throws
    
    func updateUserLocationEligability(_ isEligible: Bool) async throws
    
    /// Update user with profilePhoto data
    /// Eventially this method update user object with new profilePhotoURL
    /// - Attention: The method uses Secure call
    func updateUser(publicInfo: UserPublicInfo, profilePhoto: Data) async throws
    
    /// Checking username should be only in SignUp process in ProfileUser screen
    /// - Attention: The changing username is not possible when the user has created
    func checkUserNameIsAvailable(_ username: String) -> Bool
    
    /// Gets data from local storage in the case of a cold start
    /// It will help to show old data until new data is fetched to reduce flickering
    func prepareUserFromLocalStorage()
    func preparePublicUserInfoFromLocalStorage()
    func removeFCMToken() async throws
    
    // MARK: - Firebase Storage
    
    func uploadProfilePhoto(_ data: Data) async throws
    func getProfilePhotoUrlOfCurrentUser() async throws -> String?
    func removeProfilePhotoOfCurrentUser() async throws
    
    func deleteAccount() async throws
    
    // MARK: - Push Notifications
    func updateUserFcmToken(_ token: String?) async throws
    
    // MARK: - Host Configs
    var hostConfig: HostConfig? { get }
    @discardableResult
    func getHostConfig() async throws -> HostConfig
    func observeHostConfig()
    func getHostConfigFromLocalStorage()
}

public extension SharedSession {
    var shouldShowLockdown: Bool {
        get {
            lockdown?.isLockedDown ?? false || user?.banned ?? false
        }
    }

    var isSignedUp: Bool {
        guard currentUserId != nil else { return false }
        guard user != nil else { return false }
        return true
    }

    func getUserId() throws -> String {
        guard let uid = currentUserId else {
            throw SessionError.noUserId
        }
        return uid
    }
}

// MARK: - Implementation

actor SharedSessionManager: SharedSession {
    
    weak var delegate: SharedSessionDelegate?
    var dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Session
    
    // var presets: Presets = Presets()
    var lockdown: LockdownResponse?
    
    // MARK: - User

    var currentUserId: String? {
        dependencies.authentication.currentUserId
    }
    
    var referrerFirstName: String? {
        get async {
            guard let username = dependencies.localStorage.read(forKey: .referrerUsername) as? String else { return nil }
            do {
                let currUserPublicInfo = try await getUserPublicInfo(for: username)
                let firstNameSubstring = currUserPublicInfo
                    .name?
                    .split(separator: " ")
                    .first
                guard let firstNameSubstring = firstNameSubstring else { return nil }
                return String(firstNameSubstring)
            } catch {
                return nil
            }
        }
    }
    
    var user: User? {
        didSet(old) {
            if user?.balance != old?.balance
                || user?.withdrawalLimit != old?.withdrawalLimit
                || user?.withdrawableBalance != old?.withdrawableBalance {
                NotificationCenter.default.post(name: .balanceUpdated, object: user?.balance)
            }

            if user?.random1 != old?.random1 {
                NotificationCenter.default.post(name: .random1Updated, object: nil)
                
                if (user?.unclaimedBalance ?? 0) != 0 {
                    delegate?.userCanClaimUnclaimedBalance()
                }
            }
            
            if user?.shouldShowOnboarding == true {
                delegate?.firstLoginSequenceShouldRun()
            }

            if user?.banned != old?.banned {
                NotificationCenter.default.post(name: .lockdownUpdated, object: nil)
            }
            
            if user?.kycStatus != old?.kycStatus {
                NotificationCenter.default.post(name: .kycStatusUpdated, object: nil)
            }

            if user?.tokenBalance != old?.tokenBalance {
                NotificationCenter.default.post(name: .tokenBalanceUpdated, object: nil, userInfo: ["balance": user?.tokenBalance])
            }
            
            if user?.disableLocationCheck != old?.disableLocationCheck {
                NotificationCenter.default.post(name: .disableLocationCheckUpdate, object: nil)
            }
        }
    }
    
    var userPublicInfo: UserPublicInfo? {
        didSet {
            NotificationCenter.default.post(name: .profileUpdated, object: nil)
        }
    }

    var allUsersPublicInfo: [UserPublicInfo] = []
    
    // MARK: - App Config
    
    var hostConfig: HostConfig? {
        didSet(old) {
            if old?.weeklyWithdrawableLimitGlobal != hostConfig?.weeklyWithdrawableLimitGlobal
                || old?.minimumWithdraw != hostConfig?.minimumWithdraw {
                NotificationCenter.default.post(name: .hostConfigUpdated, object: nil)
            }
        }
    }
}
