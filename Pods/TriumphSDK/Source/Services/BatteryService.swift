//
//  BatteryService.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 6/8/22.
//

import Foundation
import UIKit

enum MatchConditionStatus: Int {
    case charging = 3
    case good = 2
    case fair = 1
    case critical = 0
}

protocol Battery {
    func getCurrentBatteryStatus() -> (MatchConditionStatus, Float)
}

final class BatteryService: NSObject, Battery {
    
    override init() {
        super.init()
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    func getCurrentBatteryStatus() -> (MatchConditionStatus, Float) {
        if UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full { return (.charging, 100) }
        let batteryLevel = UIDevice.current.batteryLevel
        switch batteryLevel {
        case 0..<0.10: return (.critical, batteryLevel)
        case 0.10..<0.25: return (.fair, batteryLevel)
        default: return (.good, batteryLevel)
        }
    }
}
