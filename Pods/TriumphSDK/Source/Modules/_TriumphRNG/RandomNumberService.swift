//
//  RandomNumberService.swift
//  TriumphSDK
//
//  Created by Jared Geller on 10/27/21.
//

import Foundation
import GameplayKit

protocol RandomNumber {
    var seed: UInt64? { get }
    func getNextBool() -> Bool
}

// We can add more methods here in the future when we need other types of randomness!
@objc
public class TriumphRNG: NSObject, RandomNumber {
    
    var seed: UInt64?
    private var rng: GKMersenneTwisterRandomSource?
    
    public init(seed: UInt64) {
        self.seed = seed
        self.rng = GKMersenneTwisterRandomSource.init(seed: seed)
    }

    private func reset() {
        guard let seed = seed else { return }
        self.rng =  GKMersenneTwisterRandomSource.init(seed: seed)
    }
    
    @objc
    public func getSeed() -> UInt64 {
        if let seed = seed {
            return seed
        } else{
            return 0
        }
    }

    public func getNextBool() -> Bool {
        guard let rng = rng else { return Bool.random() }
        return rng.nextBool()
    }
    
    public func getNextInt(minimumInclusive min: Int?, maximumInclusive max: Int?) -> Int {
        guard let rng = rng else { return 0 }
        
        if let max = max, let min = min {
            return rng.nextInt(upperBound: max - min) + min
        }
        
        if let max = max, min == nil {
            return rng.nextInt(upperBound: max)
        }
        
        if let min = min, max == nil {
            return rng.nextInt() + min
        }
        
        return rng.nextInt()
    }
    
    public func getNextFloat(minimumInclusive min: Float?, maximumInclusive max: Float?) -> Float {
        guard let rng = rng else { return 0.0 }
        
        if let max = max, let min = min {
            return rng.nextUniform() * (max - min) + min
        }
        
        if let max = max, min == nil {
            return rng.nextUniform() * max
        }
        
        if let min = min, max == nil {
            return rng.nextUniform() + min
        }
        
        return rng.nextUniform()
    }
}

// We can add more methods here in the future when we need other types of randomness!

public class TriumphGameInterface: NSObject {
    
    public var gameTitle = GameManager.gameTitle
    

    public var blitzMode = GameManager.blitzMode
    public var amount = GameManager.amount
    
    @objc // @objc cannot take optional this is user for unity
    public static func isBlitzMode() -> Bool{
        if let blitz = GameManager.blitzMode {
            return blitz
        }
        return false
    }
   
    @objc
    public static func getBlitzPayoutForScoreInt(totalScore: Int) -> String {
        return GameManager.getBlitzPayoutForScore(totalScore: Double(totalScore))
    }
    
    @objc
    public static func getBlitzPayoutForScore(totalScore: Double) -> String {
        return GameManager.getBlitzPayoutForScore(totalScore: totalScore)
    }
    
 
}
