// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol GameOverWinViewModelViewDelegate: AnyObject {
    func gameOverWinViewShouldUpdate()
    func titleLabelUpdated(newTitle: String)
}

protocol GameOverWinViewModel {
    var viewDelegate: GameOverWinViewModelViewDelegate? { get set }
    var animationDuration: AnimationDuration? { get }
    var amount: Float { get }
    var amountTitle: String { get }
    var title: String { get }
    var isWaitingOpponent: Bool { get }
    
    func beginEllipsisUpdate()
}

// MARK: - Impl.

final class GameOverWinViewModelImplementation: GameOverWinViewModel {
    
    weak var viewDelegate: GameOverWinViewModelViewDelegate? {
        didSet {
            setupModel()
        }
    }
    private var dependencies: AllDependencies
    private let notificationCenter = NotificationCenter.default
    private var historyAmount: Double?
    private var status: GameHistoryModel.ResultStatus?
    private var waitingLabelTimer: Timer?

    var isWaitingOpponent: Bool
    
    private var numberOfDots: Int = 0
    
    init(dependencies: AllDependencies,
         amount: Double? = nil,
         status: GameHistoryModel.ResultStatus? = nil,
         isWaitingOpponent: Bool = true
    ) {
        self.dependencies = dependencies
        self.historyAmount = amount
        self.status = status
        self.isWaitingOpponent = isWaitingOpponent

        if isWaitingOpponent || status ?? dependencies.game.gameOverResultStatus == nil {
            beginEllipsisUpdate()
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self, name: .gameOver, object: nil)
        waitingLabelTimer?.invalidate()
    }

    var animationDuration: AnimationDuration?
    
    var amount: Float {
        Float(historyAmount ?? Double(dependencies.game.tournament?.prize ?? 0) / 100.0)
    }
    
    var amountTitle: String {
        "$\(Int(amount))"
    }
    
    var title: String {
        if isWaitingOpponent == true {
            return "Waiting"
        }
        switch status ?? dependencies.game.gameOverResultStatus {
        case .won: return "You won"
        case .lost: return "Opponent won"
        case .draw: return "Draw"
        default: return "Waiting"
        }
    }
    
    func beginEllipsisUpdate() {
        waitingLabelTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [self] _ in
            if title != "Waiting" {
                viewDelegate?.titleLabelUpdated(newTitle: title)
                self.waitingLabelTimer?.invalidate()
                return
            }
            switch numberOfDots {
            case 0, 1, 2:
                viewDelegate?.titleLabelUpdated(newTitle: "Waiting\(String(repeating: ".", count: numberOfDots + 1))")
                numberOfDots += 1
            default:
                viewDelegate?.titleLabelUpdated(newTitle: "Waiting")
                numberOfDots = 0
            }
        }
    }
}

private extension GameOverWinViewModelImplementation {
    @objc func gameOver(_ notification: Notification) {
        if dependencies.game.gameHistoryModel?.state == .waiting {
            dependencies.logger.log("game over state is waiting")
            return
        }
        isWaitingOpponent = false
        viewDelegate?.gameOverWinViewShouldUpdate()
    }

    func setupModel() {
        guard historyAmount != nil else {
            notificationCenter.addObserver(
                self,
                selector: #selector(gameOver),
                name: .gameOver,
                object: nil
            )
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewDelegate?.gameOverWinViewShouldUpdate()
        }
    }
}

// MARK: - Localization

extension GameOverWinViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
