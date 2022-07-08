// Copyright © TriumphSDK. All rights reserved.

import Foundation

public protocol LocalStorage {
    var storage: UserDefaults { get }
}

// MARK: - Base Methods

public extension LocalStorage {
    func read(forKey: StorageKey) -> Any? {
        storage.object(forKey: forKey.rawValue)
    }
    
    func add(value: Any, forKey: StorageKey) {
        storage.set(value, forKey: forKey.rawValue)
        storage.synchronize()
    }
    
    func remove(forKey: StorageKey) {
        storage.removeObject(forKey: forKey.rawValue)
        storage.synchronize()
    }
    
    func clearAll() {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        storage.removePersistentDomain(forName: domain)
        storage.synchronize()
    }
}

// MARK: - User Data

public extension LocalStorage {
    func readUser() -> User? {
        guard let userDict = storage.object(forKey: .user)
                as? [String: Any] else { return nil }
        return userDict.toCodable(of: User.self)
    }

    func updateUser(_ user: User) {
        guard let dict = user.dictionary else { return }
        storage.set(dict, forKey: .user)
        storage.synchronize()
    }
}

// MARK: - User Public Info

public extension LocalStorage {
    func readUserPublicInfo() -> UserPublicInfo? {
        guard let userDict = storage.object(forKey: .userPublicInfo)
                as? [String: Any] else { return nil }
        return userDict.toCodable(of: UserPublicInfo.self)
    }

    func updateUserPublicInfo(_ userPublicInfo: UserPublicInfo) {
        guard let dict = userPublicInfo.dictionary else { return }
        storage.set(dict, forKey: .userPublicInfo)
        storage.synchronize()
    }
}

// MARK: - Lockdown

public extension LocalStorage {
    func readLockdown() -> LockdownResponse? {
        guard let dict = storage.object(forKey: .lockdown)
                as? [String: Any] else { return nil }
        return dict.toCodable(of: LockdownResponse.self)
    }
    
    func updateLockdown(_ lockdown: LockdownResponse) {
        guard let dict = lockdown.dictionary else { return }
        storage.set(dict, forKey: .lockdown)
        storage.synchronize()
    }
}



// MARK: - Last minimum supported version number

public extension LocalStorage {
    func readLastMinimumSupportedVersionNumber() -> Int? {
        storage.integer(forKey: StorageKey.lastMinimumSupportedVersionNumber.rawValue)
    }

    func updateLastMinimumSupportedVersionNumber(_ number: Int) {
        storage.set(number, forKey: .lastMinimumSupportedVersionNumber)
    }
}


// MARK: - App Config

public extension LocalStorage {
    func updateHostConfig(_ config: HostConfig) {
        guard let dict = config.dictionary else { return }
        storage.set(dict, forKey: .hostConfig)
        storage.synchronize()
    }
    
    func readHostConfig() -> HostConfig? {
        guard let userDict = storage.object(forKey: .hostConfig)
                as? [String: Any] else { return nil }
        return userDict.toCodable(of: HostConfig.self)
    }
}

// MARK: - Implementation

public class LocalStorageService: LocalStorage {
    
    public var storage: UserDefaults = UserDefaults.standard
    
    public var dependencies: HasLogger
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

