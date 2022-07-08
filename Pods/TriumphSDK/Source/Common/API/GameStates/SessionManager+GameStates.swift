// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

extension SessionManager {

    @discardableResult
    func getGameStates() async throws -> GameStates? {
        let uid = try await dependencies.sharedSession.getUserId()
        let request = GameStatesRequest(userId: uid, gameId: dependencies.appInfo.id)
        
        let response = try await dependencies.network.getData(request: request)
        self.gameStates = response
        return response
    }
    
    func updateGameStates() async throws {
        let uid = try await dependencies.sharedSession.getUserId()
        let request = GameStatesUpdateRequest(
            userId: uid,
            gameId: dependencies.appInfo.id
        )
        try await dependencies.network.setData(request: request)
    }
    
    func ovserveGameStates() {
        guard let uid = currentUserId else {
            dependencies.logger.log("User ID is Nil", .error)
            return
        }
        let request = GameStatesRequest(userId: uid, gameId: dependencies.appInfo.id)
        dependencies.network.listenDocument(request: request) { result in
            switch result {
            case .success(let output):
                self.gameStates = output
            case .failure(let error):
                self.dependencies.logger.log(error.message, .warning)
            }
        }
    }
}
