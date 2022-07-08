// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

extension Session {
    func prepareSessionData() async {
        do {
            try await dependencies.sharedSession.getUser()
            try await getNewMissions()
            try await prepareTournamentConfigs()
            try await getLiveMessages()
            try await getBlitzDefinitions()
            try await dependencies.session.getOtherGames(forceUpdate: true)
            await prepareGameStates()
            await dependencies.sharedSession.getLockdownStatus(for: .game(dependencies.appInfo.id))
            try await dependencies.sharedSession.getUserPublicInfo()
            try await dependencies.sharedSession.getHostConfig()
            try await getDepositDefinitions()
        } catch let error as SessionError {
            dependencies.logger.log(error.message, .error)
        } catch {
            dependencies.logger.log(error.localizedDescription, .error)
        }
    }
    
    func prepareSessionLocalStorageData() async {
        prepareTournamentConfigsFromLocalStorage()
        prepareMissionsFromLocalStorage()
        prepareLiveMessagesFromLocalStorage()
        prepareOtherGamesFromLocalStorage()
//        gameStates?.hotStreak = dependencies.localStorage.read(forKey: .hotStreak) as? Int
        await dependencies.sharedSession.prepareUserFromLocalStorage()
        await dependencies.sharedSession.preparePublicUserInfoFromLocalStorage()
        await dependencies.sharedSession.getHostConfigFromLocalStorage()
    }
    
    func prepareSession() {
        currentDataState = .coreData

        Task { [weak self] in
            await prepareSessionLocalStorageData()
            await self?.prepareSessionData()
            currentDataState = .db
            await self?.dependencies.sharedSession.delegate?.sessionDataDidPrepare()
            await self?.dependencies.intercom.configureWithUid(currentUserId ?? "")
        }

        Task { [weak self] in
            await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
                taskGroup.addTask { [weak self] in
                    let paths = await self?.dependencies.network.listenerKeys ?? []
                    let appId = await self?.dependencies.appInfo.id ?? ""
                    let uid = await self?.currentUserId ?? ""
                    
                    if paths.contains("games/\(appId)/tournaments")
                        && paths.contains("games/\(appId)/blitzTournamentsV2")
                        && paths.contains("appUsers/\(uid)/balanceTransactions") {
                        await self?.prepareHistorySplitedModels()
                    } else {
                        await self?.observeHistory()
                    }
                    
                }
                taskGroup.addTask { [weak self] in
                    await self?.observeMissionsAndConfigs()
                    await self?.observeTournamentConfigs()
                    await self?.dependencies.sharedSession.observeUser()
                    await self?.dependencies.sharedSession.observePublicUserInfo()
                    await self?.dependencies.sharedSession.observeHostConfig()
                    await self?.ovserveGameStates()
                    await self?.dependencies.sharedSession.observeLockdownStatus(for: .game(await self?.dependencies.appInfo.id ?? ""))
                }
            })

        }
    }
    
    func prepareGameStates() async {
        let gameStates = try? await getGameStates()
        if gameStates == nil {
            self.gameStates = GameStates(
                createdAt: Int(Date().timeIntervalSince1970*1000),
                hotStreak: 0,
                hotStreakConfetti: false,
                skillRank: [:],
                percentile: 0
            )
        }
    }
    
    func observeMissionsAndConfigs() {
        observeMissions(configs: missionConfigs)
        observeConfigs()
    }
}
