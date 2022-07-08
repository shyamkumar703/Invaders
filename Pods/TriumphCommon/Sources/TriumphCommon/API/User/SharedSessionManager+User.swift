// Copyright © TriumphSDK. All rights reserved.

import DeviceCheck
import Foundation

extension SharedSessionManager {

    func getUserPublicInfo(for username: String) async throws -> UserPublicInfo {
        let request = AllUsersPublicInfoRequest()
        let allUsers = try await dependencies.network.getData(request: request)
        guard let relevantUser = allUsers.filter({ $0.username == username }).first else { throw SessionError.noData }
        return relevantUser
    }
    
    func getUserPublicInfo(from uid: String) async throws -> UserPublicInfo {
        let request = UserPublicInfoRequest(uid: uid)
        guard let response = try await dependencies.network.getData(request: request) else {
            throw SessionError.noData
        }
        return response
    }
    
    @discardableResult
    func getUserPublicInfo() async throws -> UserPublicInfo {
        let uid = try getUserId()
        let response = try await getUserPublicInfo(from: uid)
        dependencies.localStorage.updateUserPublicInfo(response)
        userPublicInfo = response
        return response
    }
    
    func observeAllUsersPublicInfo() {
        let request = AllUsersPublicInfoRequest()
        dependencies.network.listenCollection(request: request) { result in
            switch result {
            case .success(let output):
                self.allUsersPublicInfo = output
            case .failure(let error):
                self.dependencies.logger.log(error.message, .warning)
            }
        }
    }
    
    @discardableResult
    func getUser() async throws -> User {
        let uid = try getUserId()
        let request = UserRequest(uid: uid)
        guard let user = try await dependencies.network.getData(request: request) else {
            throw SessionError.noData
        }
        self.dependencies.localStorage.updateUser(user)
        self.user = user
        return user
    }

    func prepareUser() async {
        do {
            try await getUser()
            try await getUserPublicInfo()
            dependencies.logger.log("User prepared", .success)
        } catch let error as SessionError {
            dependencies.logger.log(error.message, .error)
        } catch {
            dependencies.logger.log(error.localizedDescription, .error)
        }
    }

    func observeUser() {
        guard let uid = currentUserId else {
            dependencies.logger.log("User ID is nil", .error)
            return
        }
        
        let request = UserRequest(uid: uid)
        dependencies.network.listenDocument(request: request) { result in
            switch result {
            case .success(let output):
                self.dependencies.localStorage.updateUser(output)
                self.user = output
                self.dependencies.logger.log("User object updated")
            case .failure(let error):
                self.dependencies.logger.log(error.localizedDescription, .warning)
            }
        }
    }
    
    func observePublicUserInfo() {
        guard let uid = currentUserId else {
            dependencies.logger.log("Current User UID is nil", .error)
            return
        }
        let request = UserPublicInfoRequest(uid: uid)
        dependencies.network.listenDocument(request: request) { result in
            switch result {
            case .success(let output):
                self.dependencies.localStorage.updateUserPublicInfo(output)
                self.userPublicInfo = output
                self.dependencies.logger.log("User Public Info updated")
            case .failure(let error):
                self.dependencies.logger.log(error.localizedDescription, .warning)
            }
        }
    }

    func createUser(phoneNumber: String, referrerUsername: String? = nil) async throws {
        let deviceCheckToken = (try? await DCDevice.current.generateToken())?.base64EncodedString()
        let request = AuthenticationNewUserRequest(
            phoneNumber: phoneNumber,
            appId: dependencies.appInfo.id,
            referrerUsername: referrerUsername,
            deviceCheckToken: deviceCheckToken
        )
        dependencies.logger.log("Create User query: \(request.query?.dictionary ?? [:])")
        try await dependencies.network.call(request: request)
    }

    func updateUser(publicInfo: UserPublicInfo) async throws {
        guard let name = publicInfo.name,
              let username = publicInfo.username,
              let profilePhotoURL = publicInfo.profilePhotoURL else {
            throw SessionError.invalidRequest
        }
        let request = UpdateUserPublicInfoRequest(
            query: UpdateUserQuery(
                name: name,
                profilePhotoURL: profilePhotoURL,
                username: username
            )
        )
        try await dependencies.network.call(request: request)
        dependencies.logger.log("User updated", .success)
    }
    
    func updateUser(publicInfo: UserPublicInfo, profilePhoto: Data) async throws {
        await dependencies.performance.startUpdateUserProfileDataTrace(with: profilePhoto.count)
        try await uploadProfilePhoto(profilePhoto)
        let urlString = try await getProfilePhotoUrlOfCurrentUser()
        var userPablicInfo = publicInfo
        userPablicInfo.profilePhotoURL = urlString
        try await updateUser(publicInfo: userPablicInfo)
        await dependencies.performance.stopUpdateUserProfileDataTrace()
    }

    public func checkUserNameIsAvailable(_ username: String) -> Bool {
        allUsersPublicInfo.contains(where: { $0.username == username }) == false
    }

    func updateUserLocationEligability(_ isEligible: Bool) async throws {
        let uid = try getUserId()
        let request = UpdateUserLocationEligibilityRequest(uid: uid, isInSupportedLocation: isEligible)
        try await dependencies.network.update(request: request)
    }

    func prepareUserFromLocalStorage() {
        user = dependencies.localStorage.readUser()
    }
    
    func preparePublicUserInfoFromLocalStorage() {
        userPublicInfo = dependencies.localStorage.readUserPublicInfo()
    }
    
    func removeFCMToken() async throws {
        let uid = try getUserId()
        let request = RemoveFCMTokenRequest(uid: uid, gameId: dependencies.appInfo.id)
        try await dependencies.network.update(request: request)
    }
    
    func deleteAccount() async throws {
        let request = DeleteAccountRequest()
        try await dependencies.network.call(request: request)
    }
}
