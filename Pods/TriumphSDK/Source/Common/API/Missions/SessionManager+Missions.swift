// Copyright © TriumphSDK. All rights reserved.
// Documented April 11, 2022 by Shyam Kumar

import Foundation
import TriumphCommon

/**
 
 Missions are a way to drive users towards specific actions to redeem a credit to their Triumph account.
 
 # There are several points of interest here:
        
        - The `rewardType` field of the MissionModel object can be either "money," "tree," or "token." In the case that the `rewardType` is money,
    successful completion of the mission will credit the user the amount listed in the reward field of MissionModel
    (note that all currency fields are in cents). A reward type of tree makes an API call that plants a tree somewhere in the world.
    The user does not receive a credit to their account in this case. A reward type of token rewards the user in tokens.
    
    - As of now, there is only one mission we mark as complete on the CLIENT (visitFaq). Every other mission is marked as comoplete
    on the backend via document observers, and observers on the client (see observeMissions and observeConfigs) display mission
    fulfillment to the user through a SwiftMessage. If possible, missions should be marked as complete on the backend through observers.
    
    - If you want to test the fulfillment of a mission, navigate to the relevant User-Mission on the backend:
    `appUsers/{uid}/missions/{missionId}`. Next, if the completedFor dictionary contains an entry for the gameId of the game
    you are testing on, delete that entry. Make sure the `isCompleted` field is set to false. Confirm that the `unlockedFor` dictionary
    contains an entry for your gameId. If it does not, you can simply add an entry with your gameId, and a random integer.
 
 # Mission fulfillment on the UI percolates through the following path:
        
        1. The mission is marked as complete on the database
 
    2. The `listenCollection` block inside `observeMissions()` is called, and the updated missions and `missionConfigs` are read from the database
    
    3. We check for a completed mission via `checkForCompletedMission`. If a mission has been completed, we post a notification that
    is received by the `missionCompleted()` function in MainCoordinator. This function will display the appropriate SwiftMessage and
    show the confetti (and tree video if applicable)
    
    4. The missions property of `SessionManager` is updated, triggering the didSet block and calling the `missionsDidUpdate`
    function in `TournamentsViewModel`, updating the available missions in the mission cell.
 
 */

extension SessionManager {
    
    @discardableResult
    func getMissionConfigs() async throws -> [MissionConfig] {
        let request = MissionConfigsRequest()
        let response = try await dependencies.network.getData(request: request)
        dependencies.localStorage.updateMissionsConfig(response)
        self.missionConfigs = response
        return response
    }
    
    func getMissionsUser() async throws -> [MissionUser] {
        let uid = try await dependencies.sharedSession.getUserId()
        let request = MissionsUserRequest(userId: uid)
        
        let response = try await dependencies.network.getData(request: request)
        dependencies.localStorage.updateMissionsUser(response)
        return response
    }
    
    @discardableResult
    func getNewMissions() async throws -> [MissionModel] {
        let configs = try await getMissionConfigs()
        let missionsUser = try await getMissionsUser()
        
        let missions = prepareNewMissions(
            configs: configs,
            missionsUser: missionsUser
        )
        self.missions = missions
        checkForCompletedMissions(missions)
        return missions
    }
    
    func prepareMissionsFromLocalStorage() {
        let userMissions = dependencies.localStorage.readMissionUser()
        let configs = dependencies.localStorage.readMissionConfigs()
        self.missions = self.prepareNewMissions(
            configs: configs,
            missionsUser: userMissions
        )
    }

    func observeMissions(configs: [MissionConfig]) {
        guard let uid = currentUserId else {
            dependencies.logger.log("User ID is Nil", .error)
            return
        }
        let request = MissionsUserRequest(userId: uid)
        dependencies.network.listenCollection(request: request) { result in
            switch result {
            case .success(let output):
                let newMissions = self.prepareNewMissions(
                    configs: configs,
                    missionsUser: output
                )
                self.checkForCompletedMissions(newMissions)
                self.missions = newMissions
            case .failure(let error):
                self.dependencies.logger.log(error.message, .warning)
            }
        }
    }
    
    func observeConfigs() {
        let request = MissionConfigsRequest()
        dependencies.network.listenCollection(request: request) { result in
            switch result {
            case .success(let output):
                self.missionConfigs = output
                self.observeMissions(configs: output)
            case .failure(let error):
                self.dependencies.logger.log(error.message, .warning)
            }
        }
    }
    
    func markMissionAsComplete(missionId: String) async throws {
        let request = CompleteMissionRequest(
            query: CompleteMissionQuery(
                game: dependencies.appInfo.id,
                missionName: missionId
            )
        )
        try await dependencies.network.call(request: request)
    }
}

private extension SessionManager {
    func checkForCompletedMissions(_ missions: [MissionModel]) {
        for old in self.missions {
            if let new = missions.filter({ $0.id == old.id }).first {
                if new.isCompleted && !old.isCompleted {
                    NotificationCenter.default.post(name: .missionFinished, object: new)
                }
            }
        }
    }

    func prepareNewMissions(configs: [MissionConfig], missionsUser: [MissionUser]) -> [MissionModel] {
        dependencies.localStorage.updateMissionsUser(missionsUser)
        dependencies.localStorage.updateMissionsConfig(configs)
        return configs.compactMap({ config in
            if let missionUser = missionsUser.filter({ $0.id == config.id }).first {
                return MissionModel(config: config, missionUser: missionUser)
            }
            return nil
        })
    }
}
