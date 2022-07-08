// Copyright © TriumphSDK. All rights reserved.
// Documented April 11, 2022 by Shyam Kumar

import UIKit

/*
 This extension allows us to retrieve the custom Info.plist values we set with schemes. The three schemes we have switch between our environments, allowing us to test client code against any backend environment. We make this happen by editing the Info.plist when schemes are switched, and using those values as the single source of truth throughout the application.
 
 Our current custom Info.plist keys are
    isAppVerificationDisabledForTesting: If we are in the debug environment, this value will return true, to allow us to use our test phone numbers
    baseURL: Each backend environment has a different URL, and we use this variable in the Secure class to make REST calls
    storageURL: Each environment has a different storage bucket URL, and this variable is used to store and retrieve profile pictures
 */

public extension UIApplication {
    static var isAppVerificationDisabledForTesting: Bool {
        retrievePlistValue(key: .appVerification, fallback: false)
    }
    
    static var baseURL: String {
        retrievePlistValue(key: .baseURL, fallback: URLConfiguration.url)
    }
    
    static var storageURL: String {
        retrievePlistValue(key: .storageURL, fallback: StorageConfiguration.url)
    }
    
    static var environment: Environment {
        Environment(rawValue: retrievePlistValue(key: .environment, fallback: "debug")) ?? .debug
    }
    
    static var minimumSupportedVersionNumber: Int {
        retrievePlistValue(key: .minimumSupportedVersionNumber, fallback: 6)
    }
    /// Retrieves a plist value for a given key, and returns the fallback if the value does not exist
    private static func retrievePlistValue<T: Codable>(key: CustomKeys, fallback: T) -> T {
        return (Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? T) ?? fallback
    }
    
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

public enum CustomKeys: String {
    case appVerification = "IsAppVerificationDisabledForTesting"
    case baseURL = "BaseURL"
    case storageURL = "StorageURL"
    case environment = "Environment"
    case minimumSupportedVersionNumber = "MinimumSupportedVersionNumber"
}

public enum Environment: String {
    case debug
    case develop
    case production
}
