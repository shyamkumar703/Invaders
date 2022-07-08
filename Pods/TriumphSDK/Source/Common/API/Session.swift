// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

public enum CurrentDataState {
    case db
    case coreData
}

protocol Session: Actor {
    var delegate: SessionDelegate? { get set }
    var dependencies: AppDependencies { get }
    
    // MARK: - Session
    var currentDataState: CurrentDataState? { get set }
    var presets: Presets { get }

    // MARK: - Game States
    var gameStates: GameStates? { get set }
    @discardableResult
    
    /// This function gets GameStates - hotstreak for example
    func getGameStates() async throws -> GameStates?
    func updateGameStates() async throws
    func ovserveGameStates()

    // MARK: - Missions
    var missions: [MissionModel] { get set }
    var missionConfigs: [MissionConfig] { get set }
    @discardableResult
    func getMissionConfigs() async throws -> [MissionConfig]
    func getMissionsUser() async throws -> [MissionUser]
    
    /// Read mission and mission configs from Firestore
    /// Coalesce both objects into MissionModel
    @discardableResult
    func getNewMissions() async throws -> [MissionModel]
    func prepareMissionsFromLocalStorage()
    func observeMissions(configs: [MissionConfig])
    func observeConfigs()
    
    /// Returns the magnitude of a vector in three dimensions from the given components.
    /// Make a REST call to mark a mission as complete
    /// - Parameter missionId: The id of the mission we want to mark as complete
    func markMissionAsComplete(missionId: String) async throws
    
    // MARK: - History
    var allDepositHistory: [DepositHistoryModel] { get set }
    var allGamesHistory: [GameHistoryModel] { get set }
    
    /// Listen for updates to both game and deposit history
    /// Sends a notification with the updated history, received and digested by TournamentsViewModel
    func observeHistory()

    // MARK: - Live Message
    var liveMessages: [LiveMessage] { get }
    
    /// A function that retrieves the live messages for the current game
    func getLiveMessages() async throws
    func prepareLiveMessagesFromLocalStorage()
    
    // MARK: - Tournaments
    func getTournament(with id: String) async throws -> TournamentData
    func getGameHistory(with tournamentId: String) async -> GameHistoryModel?
    func submitVersusScore(_ score: Double, tournamentId: String) async throws -> TournamentVersus
    func buyIntoGame(tournament config: TournamentModel) async throws -> TournamentVersus
    
    // MARK: - Blitz
    var blitzDefinitions: [BlitzDefinition] { get set }
    
    /// Read tournament configs from Firestore and update presets accordingly
    /// Add new configs to LocalStorage
    func prepareTournamentConfigs() async throws
    func prepareTournamentConfigsFromLocalStorage()
    func observeTournamentConfigs()
    
    // MARK: - Deposit
    var depositDefinitions: [DepositDefinitionResponse] { get }
    
    /// Reads directly from Firestore to retrieve the deposit definitions for the current game
    func getDepositDefinitions() async throws
    
    // MARK: - Other Games
    
    /// A variable that holds an array of Triumph's other games
    var otherGames: [OtherGame] { get }
    
    /// A function that retrieves Triumph's other games, through an endpoint
    func getOtherGames(forceUpdate: Bool) async throws
    func prepareOtherGamesFromLocalStorage()
    
    // MARK: - Tutorial
    /// Set user tutorial status to true once the tutorial has been completed
    func updateUserTutorialStatus() async throws
    
    func prepareHistorySplitedModels()
}

extension Session {
    var currentUserId: String? {
        dependencies.authentication.currentUserId
    }
}

protocol SessionDelegate: AnyObject {
    func missionsDidUpdate()
    func tournamentConfigsDidUpdate()
    func hotstreakSequenceDidUpdate()
    func newGameTokensDeposit(model: DepositHistoryModel)
}

// MARK: - Implementation

final actor SessionManager: Session {

    weak var delegate: SessionDelegate?
    var dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
    
    var presets: Presets = Presets()

    // MARK: - Session

    /*
     A variable that describes the origin of the current data
     Since we display data from the device cache first, before calling out to the server in the background,
     it's important for many operations in Session that we are aware of the current data state.
     */
    var currentDataState: CurrentDataState?

    // MARK: - Missions

    var missions: [MissionModel] = [] {
        didSet {
            delegate?.missionsDidUpdate()
        }
    }

    var missionConfigs: [MissionConfig] = []

    // MARK: - History

    // Key: Day, Value: Array<HistoryModel>
    var history: [String : [HistoryModel]] = [:]
    var gameHistory: Set<GameHistoryModel> = []
    var allDepositHistory: [DepositHistoryModel] = [] {
        didSet(old) {
            guard !old.isEmpty && currentDataState == .db else { return }

            if let newGameDeposit = allDepositHistory
                .filter({ deposit in !old.contains(where: { $0.id == deposit.id }) })
                .filter({ $0.type == .newGame }).first {
                delegate?.newGameTokensDeposit(model: newGameDeposit)
            }
        }
    }
    
    // When this is set in prepareHistoryModel the collection view is reloaded
    var allGamesHistory: [GameHistoryModel] = []
    
    // This is a notification to update the live messages cell without a tableview reload.
    var liveMessages: [LiveMessage] = [] {
        didSet {
            NotificationCenter.default.post(name: .liveMessagesUpdated, object: nil)
        }
    }

    // MARK: - GameStates
    var gameStates: GameStates? {
        didSet(old) {
            Task { [weak self] in
                if let hotStreakConfetti = await self?.gameStates?.hotStreakConfetti,
                      hotStreakConfetti == true {
                    delegate?.hotstreakSequenceDidUpdate()
                }
                if old?.hotStreak != gameStates?.hotStreak {
                    NotificationCenter.default.post(
                        name: .hotstreak,
                        object: gameStates?.hotStreak
                    )
                }
                
                if gameStates?.percentile != old?.percentile {
                    NotificationCenter.default.post(name: .percentileUpdated, object: nil)
                }
            }
        }
    }

    // MARK: - Deposit

    var depositDefinitions: [DepositDefinitionResponse] = []

    // MARK: - Other Games
    var otherGames: [OtherGame] = []
    
    var blitzDefinitions: [BlitzDefinition] = [] {
        didSet(old) {
            if old.isEmpty && !blitzDefinitions.isEmpty {
                NotificationCenter.default.post(name: .blitzDefinitionsFetched, object: nil)
            }
        }
    }
}
