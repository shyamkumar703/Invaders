// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

extension Session {
    func claimUnclaimedBalance() async throws {
        let query = ClaimUnclaimedBalanceQuery(game: dependencies.appInfo.id)
        let request = ClaimUnclaimedBalanceRequest(query: query)
        try await dependencies.secure.call(request: request)
    }

    func updateHotStreak() {
        Task { [weak self] in
            do {
                let uid = try await dependencies.sharedSession.getUserId()
                let request = HotStreakRequest(id: uid, gameId: dependencies.appInfo.id)
                try await dependencies.network.update(request: request)
            } catch {
                await self?.dependencies.logger.log("Fail to update Hot Streak Confetti data", .warning)
            }
        }
    }
    
    func updateUserTutorialStatus() async throws {
        let uid = try await dependencies.sharedSession.getUserId()
        let request = UserTutorialRequest(uid: uid)
        try await dependencies.network.update(request: request)
    }
}
