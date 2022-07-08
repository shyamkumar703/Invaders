//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation
import TriumphCommon

extension Localization {
    
    // MARK: - Local Strings
    
    func localizedString(_ key: String) -> String {
        localizedString(key, bundle: TriumphSDK.bundle)
    }

    func localizedString(_ key: String, arguments: [CVarArg]) -> String {
        localizedString(key, bundle: TriumphSDK.bundle, arguments: arguments)
    }
    
    // MARK: - Common Strings

    func commonLocalizedString(_ key: String) -> String {
        localizedString(key, bundle: TriumphCommon.bundle)
    }

    func commonLocalizedString(_ key: String, arguments: [CVarArg]) -> String {
        localizedString(key, bundle: TriumphCommon.bundle, arguments: arguments)
    }
}
