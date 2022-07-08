// Copyright © TriumphSDK. All rights reserved.

import Foundation

public extension UserDefaults {
    func set(_ value: Any?, forKey defaultName: StorageKey) {
        set(value, forKey: defaultName.rawValue)
    }
    
    func object(forKey defaultName: StorageKey) -> Any? {
        object(forKey: defaultName.rawValue)
    }
}
