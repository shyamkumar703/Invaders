// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

extension SessionManager {
    func prepareTournamentConfigs() async throws {
        let request = TournamentConfigsRequest(id: dependencies.appInfo.id)
        let tournamentConfigs = try await dependencies.network.getData(request: request)
        dependencies.localStorage.updateTournamentConfigs(tournamentConfigs)
        presets.tournamentDefinitions = tournamentConfigs
        delegate?.tournamentConfigsDidUpdate()
    }
    
    func prepareTournamentConfigsFromLocalStorage() {
        presets.tournamentDefinitions = dependencies.localStorage.readTournamentConfigs()
        Task {
            await dependencies.sharedSession.updateLockdownFromLocalStorage()
        }
    }
    
    func observeTournamentConfigs() {
        let request = TournamentConfigsRequest(id: dependencies.appInfo.id)
        dependencies.network.listenCollection(request: request) { result in
            switch result {
            case .success(let output):
                self.presets.tournamentDefinitions = output
                self.delegate?.tournamentConfigsDidUpdate()
            case .failure(let error):
                self.dependencies.logger.log(error.message, .warning)
            }
        }
    }
}
