// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

extension SessionManager {
    func getLiveMessages() async throws {
        let gameId = dependencies.appInfo.id
        let request = LiveMessagesRequest(gameId: gameId)
        let messages = try await dependencies.network.getData(request: request)
        dependencies.localStorage.updateLiveMessages(messages)
        self.liveMessages = messages
    }
    
    func prepareLiveMessagesFromLocalStorage() {
        self.liveMessages = dependencies.localStorage.readLiveMessages()
    }
}
