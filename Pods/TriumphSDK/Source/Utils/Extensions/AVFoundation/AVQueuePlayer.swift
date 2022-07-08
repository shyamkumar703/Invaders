//
//  AVQueuePlayer.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 2/14/22.
//

import Foundation
import AVFoundation

extension AVQueuePlayer {
    
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
    
    // Responding methods
    @objc func didEnterBackground() {
        pause()
    }
    
    @objc func willEnterForeground() {
        play()
    }
}
