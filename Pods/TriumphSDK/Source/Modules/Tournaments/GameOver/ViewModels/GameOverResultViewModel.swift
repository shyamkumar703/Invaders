// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol GameOverResultViewModelViewDelegate: AnyObject {
    func gameOverWithResult(result: [GameOverResultItemViewModel?])
}

protocol GameOverResultViewModel {
    var viewDelegate: GameOverResultViewModelViewDelegate? { get set }
    var animationDuration: AnimationDuration? { get }
    var opponentStillPlayingTitle: String { get }
    var isAllowPrerformVibration: Bool { get }
    var gameHistoryModel: GameHistoryModel? { get }
}

// MARK: - Implementation

final class GameOverResultViewModelImplementation: GameOverResultViewModel {
    
    weak var viewDelegate: GameOverResultViewModelViewDelegate? {
        didSet {
            setupModel()
        }
    }
    
    private var dependencies: AllDependencies
    private let notificationCenter = NotificationCenter.default
    var gameHistoryModel: GameHistoryModel?
    private var isNotificated = false
    
    init(dependencies: AllDependencies, model: GameHistoryModel? = nil) {
        self.dependencies = dependencies
        self.gameHistoryModel = model
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .gameOver, object: nil)
    }
    
    var animationDuration: AnimationDuration?
    
    var opponentStillPlayingTitle: String {
        localizedString(Content.GameOver.opponentPlayingTitle)
    }
    
    var isAllowPrerformVibration: Bool = true
}

private extension GameOverResultViewModelImplementation {
    func setIsAllowPrerformVibration(with gameHistoryModel: GameHistoryModel?) {
        isAllowPrerformVibration = !(gameHistoryModel?.isZeroDraw ?? false) &&
        !(gameHistoryModel?.state == .waiting && gameHistoryModel?.player?.score == 0)
    }
    
    func setupModel() {
        Task { [weak self] in
            do {
                // FIXME: This is temporary solution of this edge case. This need to be done in gameHistoryModel
                if self?.gameHistoryModel?.player?.finalScore == nil {
                    self?.gameHistoryModel?.player?.finalScore = PlayerFinalScore(
                        createdAt: Date().timeIntervalSince1970,
                        value: 0
                    )
                }
                
                let playerPublicInfo = try await self?.dependencies.sharedSession.getUserPublicInfo()
                self?.gameHistoryModel?.player?.username = playerPublicInfo?.username
                self?.gameHistoryModel?.player?.userpic = playerPublicInfo?.profilePhotoURL
                
                if let opponentUid = self?.gameHistoryModel?.opponent?.uid {
                    let opponentPublicInfo = try await self?.dependencies.sharedSession.getUserPublicInfo(from: opponentUid)
                    self?.gameHistoryModel?.opponent?.username = opponentPublicInfo?.username
                    self?.gameHistoryModel?.opponent?.userpic = opponentPublicInfo?.profilePhotoURL
                }
                
                guard let gameHistoryModel = self?.gameHistoryModel else {
                    self?.notificationCenter.addObserver(self, selector: #selector(gameOver), name: .gameOver, object: nil)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self, self.isNotificated == false,
                              let gameHistory = self.dependencies.game.gameHistoryModel
                        else {
                            self?.dependencies.logger.log("isNotification: \(self?.isNotificated == false), gameHistory: nil", .error)
                            return
                        }
                        self.gameDidFinish(with: gameHistory)
                    }
                    return
                }
                
                await MainActor.run { [weak self] in
                    self?.gameDidFinish(with: self?.gameHistoryModel)
                }
            } catch let error as SessionError {
                dependencies.logger.log("Preparing history result we encountered with error: \(error)", .warning)
            } catch {
                dependencies.logger.log(error, .error)
            }
        }
    }
    
    @objc func gameOver(_ notification: Notification) {
        self.isNotificated = true
        guard let gameHistoryModel = notification.object as? GameHistoryModel else {
            dependencies.logger.log("gameHistoryModel is Nil", .warning)
            return
        }
        self.gameHistoryModel = gameHistoryModel
        gameDidFinish(with: gameHistoryModel)
    }
    
    func gameDidFinish(with gameOverModel: GameHistoryModel?) {
        setIsAllowPrerformVibration(with: gameOverModel)
        let result = gameOverModel?.result.map { model -> GameOverResultItemViewModel? in
            guard let model = model else {
                dependencies.logger.log("model is Nil", .warning)
                return nil
            }
            return GameOverResultItemViewModelImplementation(
                result: model, // TODO: - refactor it with optional result here
                winnerScore: gameOverModel?.winnerScore ?? dependencies.game.score,
                dependencies: dependencies
            )
        }
        
        guard let result = result else { return }
        viewDelegate?.gameOverWithResult(result: result)
        Task { [weak self] in
            let isRegistered = await dependencies.pushNotifications.isRegistered
            if result.contains(where: { $0 == nil }) && !isRegistered {
                do {
                    try await self?.dependencies.pushNotifications.registerForPushNotifications()
                } catch {
                    self?.dependencies.logger.log(error.localizedDescription, .error)
                }
                
            } else {
                
                if let tokens = await self?.dependencies.sharedSession.user?.fcmTokens,
                   tokens[self?.dependencies.appInfo.id ?? ""] == nil {
                    do {
                        try await self?.dependencies.pushNotifications.registerForPushNotifications()
                    } catch {
                        self?.dependencies.logger.log(error.localizedDescription, .error)
                    }
                }
            }
        }
    }
}

// MARK: - Localization

extension GameOverResultViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
