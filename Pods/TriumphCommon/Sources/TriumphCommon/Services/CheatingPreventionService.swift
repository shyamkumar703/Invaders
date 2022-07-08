//
//  CheatingPreventionService.swift
//  TriumphSDK
//
//  Created by Jared Geller on 2/15/22.
//

import UIKit

public protocol CheatingPrevention {
    func passedCheatingDetection() -> Bool
}

// Where all cheating prevention checks should be done
public class CheatingPreventionService: CheatingPrevention {
    
    private var timer: Timer?
    private let notificationCenter = NotificationCenter.default
    
    public init() {
        
    }
    
    private var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    // Checks common signs of jailbroken device
    public func isJailbroken() -> Bool {
        hasCydiaInstalled() || isContainsSuspiciousApps() || isSuspiciousSystemPathsExists() || canEditSystemFiles()
    }
    
    // https://medium.com/@alessandrofrancucci/checking-vpn-connection-on-ios-swift-9748d733e49d
    public func isUsingVPN() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
            let allKeys = keys.allKeys as? [String] else { return false }

        // Checking for tunneling protocols in the keys
        for key in allKeys {
            for protocolId in ["tap", "tun", "ppp", "ipsec", "utun"]
                where key.starts(with: protocolId) {
                return true
            }
        }
        return false
    }
    
    // Returns whether the user passed all cheating detection
    public func passedCheatingDetection() -> Bool {
        if isSimulator {
            return true
        }
        return !(isJailbroken() || isUsingVPN())
    }
    
    public func start() {
        let isPassed = passedCheatingDetection()
        notificationCenter.post(name: .passedCheatingDetection, object: isPassed)
        
        guard self.timer == nil else { return }
        self.timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(passCheatingDetection),
            userInfo: nil,
            repeats: true
        )
        guard let timer = self.timer else { return }
        RunLoop.main.add(timer, forMode: .common)
        
        notificationCenter.addObserver(
            self, selector: #selector(passCheatingDetection),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    public func stop() {
        notificationCenter.removeObserver(self, name: .passedCheatingDetection, object: nil)
        notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        timer?.invalidate()
        timer = nil
    }
    
    @objc func passCheatingDetection() {
        let isPassed = passedCheatingDetection()
        notificationCenter.post(name: .passedCheatingDetection, object: isPassed)
    }
}

// MARK: Jailbreak helper methods
// https://developerinsider.co/best-way-to-check-if-your-ios-app-is-running-on-a-jailbroken-phone/
private extension CheatingPreventionService {
    // Must set url scheme in LSQUERY in info.plist
    func hasCydiaInstalled() -> Bool {
//        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
        return false
    }
    
    // Check if suspicious apps (Cydia, FakeCarrier, Icy etc.) is installed
    func isContainsSuspiciousApps() -> Bool {
        for path in suspiciousAppsPathToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    // Check if system contains suspicious files
    func isSuspiciousSystemPathsExists() -> Bool {
        for path in suspiciousSystemPathsToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    // Check if app can edit system files
    func canEditSystemFiles() -> Bool {
        let jailBreakText = "Developer Insider"
        do {
            try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    //suspicious apps path to check
    var suspiciousAppsPathToCheck: [String] {
        return ["/Applications/Cydia.app",
                "/Applications/blackra1n.app",
                "/Applications/FakeCarrier.app",
                "/Applications/Icy.app",
                "/Applications/IntelliScreen.app",
                "/Applications/MxTube.app",
                "/Applications/RockApp.app",
                "/Applications/SBSettings.app",
                "/Applications/WinterBoard.app"
        ]
    }
    
    // suspicious system paths to check
    var suspiciousSystemPathsToCheck: [String] {
        return ["/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                "/private/var/lib/apt",
                "/private/var/lib/apt/",
                "/private/var/lib/cydia",
                "/private/var/mobile/Library/SBSettings/Themes",
                "/private/var/stash",
                "/private/var/tmp/cydia.log",
                "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                "/usr/bin/sshd",
                "/usr/libexec/sftp-server",
                "/usr/sbin/sshd",
                "/etc/apt",
                "/bin/bash",
                "/Library/MobileSubstrate/MobileSubstrate.dylib"
        ]
    }
}
