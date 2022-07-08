//
//  MatchingConditionViewModel.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 6/8/22.
//

import Foundation
import UIKit

protocol MatchingConditionViewDelegate: AnyObject {
    func statusUpdated()
}

enum MatchingCondition: CaseIterable {
    case battery
    case signal
    case motivation
    case secure
}

class MatchingConditionViewModel {
    var condition: MatchingCondition
    var dependencies: AllDependencies
    weak var viewDelegate: MatchingConditionViewDelegate?
    
    var status: MatchConditionStatus? {
        didSet(oldStatus) {
            if oldStatus != status {
                viewDelegate?.statusUpdated()
            }
            if timer == nil && condition == .signal {
                Task { @MainActor in
                    self.timer = Timer.scheduledTimer(
                        timeInterval: 10,
                        target: self,
                        selector: #selector(pollForNetworkConnectivity),
                        userInfo: nil,
                        repeats: true
                    )
                }
            }
        }
    }
    
    var displayImage: UIImage? {
        getCurrentDisplayImage()
    }
    
    var title: String {
        switch condition {
        case .battery:
            if let status = status {
                switch status {
                case .critical:
                    return "Battery\ncritical"
                case .fair:
                    return "Battery\nlow"
                case .good:
                    return "Battery\ncharged"
                case .charging:
                    return "Battery\ncharging"
                }
            } else {
                return "Battery\ncharged"
            }
        case .signal:
            if let status = status {
                switch status {
                case .good:
                    return "Signal\nconnected"
                case .fair:
                    return "Signal\nfair"
                case .critical:
                    return "Signal\ndetached"
                default:
                    return ""
                }
            } else {
                return "Signal\nweak"
            }
        case .motivation:
            return "Chakras\naligned"
        case .secure:
            return "Secure\nmatch"
        }
    }
    
    var statusImage: (UIImage?, UIColor) {
        let smallConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        
        if let status = status {
            switch status {
            case .good, .charging:
                return (UIImage(systemName: "checkmark.circle.fill")?.withConfiguration(smallConfig), .green)
            case .fair:
                return (UIImage(systemName: "exclamationmark.circle.fill")?.withConfiguration(smallConfig), .orange)
            case .critical:
                return (UIImage(systemName: "exclamationmark.circle.fill")?.withConfiguration(smallConfig), .lostRed)
            }
        } else {
            return (nil, .clear)
        }
    }
    
    var timer: Timer?
    
    init(condition: MatchingCondition, dependencies: AllDependencies) {
        self.condition = condition
        self.dependencies = dependencies
        
        switch condition {
        case .battery:
            self.status = dependencies.battery.getCurrentBatteryStatus().0
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(batteryLevelChanged),
                name: UIDevice.batteryLevelDidChangeNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(batteryLevelChanged),
                name: UIDevice.batteryStateDidChangeNotification,
                object: nil
            )
        case .signal:
            self.status = dependencies.networkStrength.status
            Task { [weak self] in
                self?.status = await dependencies.networkStrength.checkPing()
                viewDelegate?.statusUpdated()
            }
        default:
            self.status = .good
        }
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    
    func getCurrentDisplayImage() -> UIImage? {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        switch condition {
        case .battery:
            if status == .charging {
                return UIImage(systemName: "battery.100.bolt")?.withConfiguration(largeConfig)
            }
            switch dependencies.battery.getCurrentBatteryStatus().1 {
            case 0..<25:
                return UIImage(systemName: "battery.25")?.withConfiguration(largeConfig)
            case 25..<50:
                return UIImage(systemName: "battery.50")?.withConfiguration(largeConfig)
            case 50..<75:
                return UIImage(systemName: "battery.75")?.withConfiguration(largeConfig)
            default:
                return UIImage(systemName: "battery.100")?.withConfiguration(largeConfig)
            }
        case .signal:
            if let status = status {
                switch status {
                case .good, .fair: return UIImage(systemName: "wifi")?.withConfiguration(largeConfig)
                case .critical: return UIImage(systemName: "wifi.exclamationmark")?.withConfiguration(largeConfig)
                default: return nil
                }
            } else {
                return nil
            }
        case .motivation:
            return UIImage(systemName: "face.smiling")?.withConfiguration(largeConfig)
        case .secure:
            return UIImage(systemName: "shield.righthalf.filled")?.withConfiguration(largeConfig)
        }
    }
    
    @objc func pollForNetworkConnectivity() {
        Task { [weak self] in
            self?.status = await dependencies.networkStrength.checkPing()
        }
    }
    
    @objc func batteryLevelChanged() {
        self.status = dependencies.battery.getCurrentBatteryStatus().0
        viewDelegate?.statusUpdated()
    }
}
