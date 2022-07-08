// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

extension SessionManager {
    func getOtherGames(forceUpdate: Bool = false) async throws {
        guard forceUpdate else { return }
        let request = OtherGamesRequest()
        var interimOtherGames = try await dependencies.network.call(request: request)?.games ?? []

        // REST endpoint is being called twice (in prepareSessionData), using this to guard against wiping
        // the results of the previous successful request
        guard !interimOtherGames.isEmpty else { return }
        interimOtherGames.insert(
            OtherGame(
                gameId: "",
                image: "referral",
                appStoreURL: "",
                isCompleted: false,
                urlScheme: nil,
                imageType: .local
            ),
            at: 0
        )

        dependencies.localStorage.updateOtherGames(interimOtherGames)
        otherGames = interimOtherGames
        
        NotificationCenter.default.post(name: .didRetrieveOtherGames, object: nil)
    }
    
    func prepareOtherGamesFromLocalStorage() {
        let placeholders = [OtherGame](repeatElement(OtherGame(
            gameId: "",
            image: "",
            appStoreURL: "",
            isCompleted: false,
            urlScheme: nil,
            imageType: .link
        ), count: 3))
        
        let otherGamesFromLocalStorage = dependencies.localStorage.readOtherGames()
        
        if otherGamesFromLocalStorage.isEmpty {
            otherGames = placeholders
        } else {
            otherGames = otherGamesFromLocalStorage
        }
        
        NotificationCenter.default.post(name: .didRetrieveOtherGames, object: nil)
    }
}
