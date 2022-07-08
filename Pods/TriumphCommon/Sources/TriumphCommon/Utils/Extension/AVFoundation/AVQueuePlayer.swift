// Copyright © TriumphSDK. All rights reserved.

import UIKit
import AVFoundation

public extension AVQueuePlayer {
    func addVideoObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc func didEnterBackground() {
        pause()
    }
    
    @objc func willEnterForeground() {
        play()
    }
}
