// Copyright © TriumphSDK. All rights reserved.

import Foundation

public protocol Localization {
    func localizedString(_ key: String, bundle: Bundle?) -> String
    func localizedString(_ key: String, bundle: Bundle?, arguments: [CVarArg]) -> String
}

extension Localization {
    func localizedString(_ key: String, bundle: Bundle? = nil) -> String {
        NSLocalizedString(key, bundle: bundle ?? TriumphCommon.bundle, value: "", comment: "")
    }
    
    func localizedString(_ key: String, bundle: Bundle? = nil, arguments: [CVarArg]) -> String {
        String(format: localizedString(key, bundle: bundle), arguments: arguments)
    }
}

// MARK: - LocalizationService Impl.

final class LocalizationService: Localization {
    
}
