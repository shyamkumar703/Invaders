// Copyright © TriumphSDK. All rights reserved.

import Foundation

extension SharedSessionManager {

    @discardableResult
    func getHostConfig() async throws -> HostConfig {
        let request = HostConfigRequest()
        guard let response = try await dependencies.network.getData(request: request) else {
            throw SessionError.noData
        }
        dependencies.localStorage.updateHostConfig(response)
        hostConfig = response
        return response
    }
    
    func observeHostConfig() {
        let request = HostConfigRequest()
        dependencies.network.listenDocument(request: request) { result in
            switch result {
            case .success(let output):
                self.dependencies.localStorage.updateHostConfig(output)
                self.hostConfig = output
            case .failure(let error):
                self.dependencies.logger.log(error.localizedDescription, .error)
            }
        }
    }
    
    func getHostConfigFromLocalStorage() {
        hostConfig = dependencies.localStorage.readHostConfig()
    }
}
