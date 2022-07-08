//
//  LocalStorage.swift
//  TriumphSDK
//
//  Created by Maksim Kalik on 6/1/22.
//

import Foundation
import TriumphCommon

// MARK: - Missions

extension LocalStorage {
    func updateMissionsConfig(_ config: [MissionConfig]) {
        let dict: [[String: Any]] = config.compactMap { $0.dictionary }
        storage.set(dict, forKey: .missionConfig)
        storage.synchronize()
    }

    func updateMissionsUser(_ config: [MissionUser]) {
        let dict: [[String: Any]] = config.compactMap { $0.dictionary }
        storage.set(dict, forKey: .missionUser)
        storage.synchronize()
    }

    func readMissionConfigs() -> [MissionConfig] {
        guard let dict = storage.object(forKey: .missionConfig)
                as? [[String: Any]] else { return [] }
        return dict.compactMap { $0.toCodable(of: MissionConfig.self) }
    }

    func readMissionUser() -> [MissionUser] {
        guard let dict = storage.object(forKey: .missionUser)
                as? [[String: Any]] else { return [] }
        return dict.compactMap { $0.toCodable(of: MissionUser.self) }
    }
}

// MARK: - TournamentModel Data

extension LocalStorage {
    func updateTournamentConfigs(_ config: [TournamentModel]) {
        let dict: [[String: Any]] = config.compactMap { $0.dictionary }
        storage.set(dict, forKey: .tournamentConfiguration)
        storage.synchronize()
    }

    func readTournamentConfigs() -> [TournamentModel] {
        guard let dict = storage.object(forKey: .tournamentConfiguration)
                as? [[String: Any]] else { return [] }
        return dict.compactMap { $0.toCodable(of: TournamentModel.self) }
    }
}

// MARK: - Other Games

extension LocalStorage {
    func updateOtherGames(_ games: [OtherGame]) {
        let dict: [[String: Any]] = games.compactMap { $0.dictionary }
        storage.set(dict, forKey: .otherGames)
        storage.synchronize()
    }

    func readOtherGames() -> [OtherGame] {
        guard let dict = storage.object(forKey: .otherGames)
                as? [[String: Any]] else { return [] }
        return dict.compactMap { $0.toCodable(of: OtherGame.self) }
    }
}

// MARK: - Blitz Seeding

extension LocalStorage {
    func getBlitzSeedCycleValue() -> BlitzSeedCycleData? {
        guard let dict = storage.object(forKey: .blitzSeedCycle)
                as? [String: Any] else { return nil }
        return dict.toCodable(of: BlitzSeedCycleData.self)
    }

    func updateBlitzSeedCycleValue(_ blitzSeedData: BlitzSeedCycleData) {
        guard let dict = blitzSeedData.dictionary else { return }
        storage.set(dict, forKey: .blitzSeedCycle)
        storage.synchronize()
    }
}

// MARK: - LiveMessage Data

extension LocalStorage {
    func updateLiveMessages(_ messages: [LiveMessage]) {
        let dict: [[String: Any]] = messages.compactMap { $0.dictionary }
        storage.set(dict, forKey: .liveMessage)
        storage.synchronize()
    }

    func readLiveMessages() -> [LiveMessage] {
        guard let dict = storage.object(forKey: .liveMessage)
                as? [[String: Any]] else { return [] }
        return dict.compactMap { $0.toCodable(of: LiveMessage.self) }
    }
}
