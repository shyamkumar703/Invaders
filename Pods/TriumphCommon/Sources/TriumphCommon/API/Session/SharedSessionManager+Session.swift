// Copyright © TriumphSDK. All rights reserved.

import Foundation

extension SharedSessionManager {
    @discardableResult
    func getLockdownStatus(for app: ApplicationType) async -> LockdownResponse {
        do {
            let request = LockdownInfoRequest(app: app)
            guard let response = try await dependencies.network.getData(request: request) else {
                throw SessionError.noData
            }
            lockdown = response
            return response
        } catch {
            dependencies.logger.log("Failed to get lockdown status", .warning)
            return LockdownResponse()
        }
    }

    func observeLockdownStatus(for app: ApplicationType) {
        let request = LockdownInfoRequest(app: app)
        dependencies.network.listenDocument(request: request) { result in
            switch result {
            case .success(let output):
                self.lockdown = output
                self.dependencies.localStorage.updateLockdown(output)
                self.delegate?.sessionLockdownDidUpdate()
                NotificationCenter.default.post(name: .lockdownUpdated, object: nil)
            case .failure(let error):
                self.dependencies.logger.log(error.localizedDescription, .error)
            }
        }
    }
    
    func updateLockdownFromLocalStorage() {
        self.lockdown = dependencies.localStorage.readLockdown()
    }
    
    func prepareIntercom() {
        dependencies.intercom.configureWithUid(currentUserId ?? "")
    }
    
    func resetSession() async {
        await dependencies.network.clearAll()
        dependencies.localStorage.clearAll()
        user = nil
        userPublicInfo = nil
    }
}
