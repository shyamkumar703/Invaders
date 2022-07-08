// Copyright © TriumphSDK. All rights reserved.

import Foundation

protocol GamePlay {
    func finishGameInBackground()
    func updateScore(score: Double)
    func resumeGame()
    func start()
    func teardownNotificationListeners()
}

class GamePlayService: NSObject, GamePlay {
    
    let notificationCenter = NotificationCenter.default
    private var dependencies: AllDependencies
    private var timer: Timer?
    private var totalTime = 15
    private var backgroundTaskID: UIBackgroundTaskIdentifier?
    private var score: Double = 0
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
        super.init()
    }

    func resumeGame() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func updateScore(score: Double) {
        self.score = score
    }
    
    @MainActor
    @objc
    fileprivate func updateTimer() {
        if totalTime != 0 {
            print(totalTime)
            totalTime -= 1
            dependencies.triumphDelegate?.triumphRequestsDidPause(timeLeft: totalTime)
        } else {
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
                self.timeIsUp()
            }
        }
    }
    
    func start() {
        notificationCenter.addObserver(
            self,
            selector: #selector(resignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    public func teardownNotificationListeners() {
        notificationCenter.removeObserver(self)
    }
    
    @MainActor
    @objc
    fileprivate func didEnterBackground() {
        finishGameInBackground()
        dependencies.triumphDelegate?.triumphRequestsResetGame()
        teardownNotificationListeners()
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    func finishGameInBackground() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            // Request the task assertion and save the ID.
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Endbackgroundtask") {
                // End the task if time expires.
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }
            
            // Send the data synchronously.
            self.dependencies.game.finishGame(score: self.score)
            
            // End the task assertion.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }
    
    @MainActor
    @objc
    fileprivate func resignActive() {
        if timer == nil {
            self.totalTime = 15
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            dependencies.triumphDelegate?.triumphRequestsDidPause(timeLeft: totalTime)
        }
    }
    
    @MainActor
    fileprivate func timeIsUp() {
        dependencies.triumphDelegate?.triumphRequestsDidGameOver()
        teardownNotificationListeners()
    }
}
