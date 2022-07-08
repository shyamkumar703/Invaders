// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol GameOverResultItemViewDelegate: AnyObject {
    func gameOverResultItemUpdated(userpic: URL?)
}

protocol GameOverResultItemViewModel {
    var viewDelegate: GameOverResultItemViewDelegate? { get set }
    var score: Double { get }
    var isLooser: Bool { get }
    var barHeight: Float { get }
    var isWaitingOpponent: Bool { get }
    var scoreType: DecimalPoints { get }
    var username: String { get }
    var userpic: URL? { get }
    var isWaitingForOpponentToFinishPlaying: Bool { get }
    
    func respondToVideoTap()
}

// MARK: - Impl.

final class GameOverResultItemViewModelImplementation: GameOverResultItemViewModel {

    weak var viewDelegate: GameOverResultItemViewDelegate?
    private var result: PlayerModel
    private var winnerScore: Double
    private var dependencies: AllDependencies
    
    init(result: PlayerModel, winnerScore: Double, dependencies: AllDependencies) {
        self.result = result
        self.winnerScore = winnerScore
        self.dependencies = dependencies
        
        getUsername()
    }

    var score: Double {
        result.score ?? 0
    }
    
    var barHeight: Float {
        let resultScore = abs(self.result.score ?? 0) // FIXME: Unwrap before using
        let winnerScore = abs(self.winnerScore)
        if winnerScore == resultScore { return 1 }
        return winnerScore > resultScore ? Float(resultScore) / Float(winnerScore) : 1
    }
    
    var isLooser: Bool {
        return winnerScore > result.score ?? 0 // FIXME: Unwrap before using
    }
    
    var isWaitingOpponent: Bool {
        result.score == nil
    }
    
    var isWaitingForOpponentToFinishPlaying: Bool {
        result.score == nil && result.uid != "none"
    }

    var scoreType: DecimalPoints {
        dependencies.appInfo.scoreType
    }
    
    var userpic: URL? {
        guard let urlString = result.userpic else {
            // getUserpic()
            dependencies.logger.log("Userpic is nil", .warning)
            return nil
        }
        return URL(string: urlString)
    }
    
    var username: String = ""
    
    func respondToVideoTap() {
        dependencies.swiftMessage.showAsyncGameDescriptionMessage()
    }
    
    private func getUsername() {
        Task { [weak self] in
            let currUID = await self?.dependencies.session.currentUserId
            if self?.result.uid == currUID { self?.username = "You" }
            self?.username = self?.result.username ?? "Unknown"
        }
    }
}

// FIXME: - Use GameManager.gameModel where you can use Self from response to get all current user data
private extension GameOverResultItemViewModelImplementation {
    func getUserpic() {
        Task { [weak self] in
            let userPublicInfo = try await self?.dependencies.sharedSession.getUserPublicInfo()
            await MainActor.run { [weak self] in
                self?.viewDelegate?.gameOverResultItemUpdated(
                    userpic: URL(string: userPublicInfo?.profilePhotoURL ?? "")
                )
            }
        }
    }
}
