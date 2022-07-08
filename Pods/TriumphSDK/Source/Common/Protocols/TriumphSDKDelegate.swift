// Copyright © TriumphSDK. All rights reserved.

import Foundation

@objc
@MainActor
public protocol TriumphSDKDelegate: AnyObject {
    
    /// User this delegate to control when practice should start.
    func triumphPracticeDidStart()
    
    /// Use this delegate to control when your game should start.
    /// Be sure to use the rng object for all elements of randomness
    func triumphGameDidStart(rngGenerator: TriumphRNG)
    
    /// Use this delegate to check when Triumph SDK ViewController will appear on the screen
    func triumphViewControllerWillPresent()
    
    /// Use this delegate to check when Triumph SDK ViewController appears on the screen
    func triumphViewControllerDidPresented()
    
    /// Use this delegate to check when Triumph SDK ViewController disappears from the screen
    func triumphViewControllerDidDismissed()
    
    /// Use this delegate to check when Triumph SDK ViewController will disappear from the screen
    func triumphViewControllerWillDismiss()
    
    /// Use This Delegate when the SDK needs the game to pause
    func triumphRequestsDidPause(timeLeft: Int)
    
    /// Use this delegate function to tell the game to reset because a game over is being forced
    func triumphRequestsDidGameOver()
    
    func triumphRequestsResetGame()
}

//public extension TriumphSDKDelegate {
//    func triumphViewControllerDidPresented() {}
//    func triumphViewControllerDidDismissed() {}
//    func triumphViewControllerWillDismiss() {}
//    func triumphViewControllerWillPresent() {}
//}
