// Copyright © TriumphSDK. All rights reserved.
// Documentation April 11 2022 Henry Boswell

import Foundation
import TriumphCommon

protocol GameManagerDelegate: AnyObject {
    func gameFinishLoadingData()
    func gameRunConfetti()
}

protocol BlitzGameManagerDelegate: AnyObject {
    func newBlitzDataLoaded()
    func blitzSubmitDidFinish()
}

protocol GameProtocol {
    var delegate: GameManagerDelegate? { get set }
    var blitzDelegate: BlitzGameManagerDelegate? { get set }
    
    var amount: Double { get }
    var buyInAmount: Double { get }
    var score: Double { get }
    var title: String { get }
    var icon: String { get }
    
    var gameOverResultStatus: GameHistoryModel.ResultStatus? { get }
    var opponent: PlayerModel? { get }
    var tournament: TournamentModel? { get }
    var tournamentResponseId: String? { get }
    var gameHistoryModel: GameHistoryModel? { get }

    /// RandomSeed for the game.
    /// Behind the scenes this seed is set by the server as required
    ///  1. Blitz - Rolling time based seed
    ///  2. Async - Per game seed
    func getRandomSeed() -> TriumphRNG?
    
    ///  This function buys into an async tournament
    ///  - Parameters config: TournamentModel this is a tournament config object
    func buyIntoGame(tournament config: TournamentModel) async throws
    
    /// This function buys into a blitz tournament
    ///  - Parameters config: BlitzModel this is a blitz tournamnet model
    func buyIntoGame(blitz config: BlitzModel) async throws
    
    // This function ends the game with a score
    // - Parameters score: the function take a double but the score can be an Int cast to a Double as is the case in brick breaker
    func finishGame(score: Double)
    
    func getBucket(response: [BlitzDataPointResponse]) async
    
    // FIXME: Should be refactored
    var tournamentType: TournamentType? { get }
    func setTournamentType(_ type: TournamentType)
    
    // MARK: BLITZ Mode
    
    /// Observes the blitz datapoint dictonary on the server to show the blitz UI
    func startObserveBlitzDataPoints() async throws
    
    /// blitzScoreArray getter
    func getBlitzScoreArray() -> [Double: Double]?
    
    /// GameManager.blitzBuyIn = blitzBuyIn
    func setBlitzAmount(blitzBuyIn: Double)
}

// MARK: - GameManager Impl.

final class GameManager: GameProtocol {

    //MARK: GameManager static varriables
    private static var tournament: TournamentModel?
    private static var randomSeed: Int?
    private static var tournamentResponseId: String?
    private static var tournamentData: TournamentData?
    private static var tournamentType: TournamentType?
    
    
    /// These are set on buyIntoGame(config: )
    static var gameTitle: String?
    static var amount: Double = 0
    static var prize: Double = 0
    
    
    var gameHistoryModel: GameHistoryModel?
    
    var tournament: TournamentModel? {
        GameManager.tournament
    }
    
    var tournamentData: TournamentData? {
        GameManager.tournamentData
    }
    
    var tournamentResponseId: String? {
        GameManager.tournamentResponseId
    }

    var opponent: PlayerModel? {
        gameHistoryModel?.opponent
    }
    
    weak var delegate: GameManagerDelegate?
    weak var blitzDelegate: BlitzGameManagerDelegate?
    
    private var dependencies: AllDependencies
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
    }

    private let defaultIcon = BaseIcon.logo.rawValue

    lazy var icon: String = defaultIcon
    
    var score: Double = 0
    
    var amount: Double {
        switch gameOverResultStatus {
        case .won, .lost: return prize
        case .draw: return prize / 2
        default: return 0
        }
    }
    
    var title: String {
        GameManager.gameTitle ?? ""
    }
    
    var buyInAmount: Double {
        Double(GameManager.amount)
    }

    var prize: Double {
        Double(GameManager.prize)
    }
        
    var gameOverResultStatus: GameHistoryModel.ResultStatus?

    var tournamentType: TournamentType? {
        GameManager.tournamentType
    }
    
    // MARK: - General Methods
    
    /// Set the current tournament type
    func setTournamentType(_ type: TournamentType) {
        GameManager.tournamentType = type
    }
    
    /// Retrieve a random number to seed the upcoming game with
    func getRandomSeed() -> TriumphRNG? {
        guard let seed = GameManager.randomSeed else { return nil }
        let rng = TriumphRNG(seed: UInt64(seed))
        return rng
    }
    
    static func getRandomSeedIntegerRaw() -> Int? {
        return randomSeed
    }
    
    static func setRandomSeedIntegerRaw(seed: Int) {
        randomSeed = seed
    }
    
    /// Switch over finished tournament type to display corresponding screen
    func finishGame(score: Double) {
        self.score = score
        switch self.tournamentType {
        // case .versus: finishVersus()
        case .versus: reportVersusScore()
        case .blitz: finishBlitz()
        default: break
        }
    }

    // MARK: - Versus
    
    /// Buy in to the game specified by the given config
    func buyIntoGame(tournament config: TournamentModel) async throws {
        GameManager.blitzMode = false
        GameManager.tournament = config
        GameManager.gameTitle = config.gameTitleWithEmoji
        GameManager.amount = config.entryPrice ?? 0
        GameManager.prize = Double(config.prize ?? 0) / 100.0
        
        let response = try await dependencies.session.buyIntoGame(tournament: config)
        GameManager.randomSeed = response.tournament?.randomSeed
        GameManager.tournamentResponseId = response.id

        let gameHistoryModel = GameHistoryModel(response: response)
        self.gameHistoryModel = gameHistoryModel

        dependencies.analytics.logEvent(
            LoggingEvent(
                .gameBuyIn,
                parameters: [
                    "gameType": "async1v1",
                    "amount": "\((config.entryPrice ?? 0) * 100)"
                ]
            )
        )
    }
    
    /// Report the score of the recently finished 1v1 tournament
    func reportVersusScore() {
        guard let tournamentId = GameManager.tournamentResponseId else {
            dependencies.logger.log("tournament should have id, but got nil", .error)
            return
        }
        Task { [weak self] in
            do {
                if let tournamentResponse = try await self?.dependencies.session.submitVersusScore(
                    score,
                    tournamentId: tournamentId
                ) {
                    self?.dependencies.logger.log(tournamentResponse.dictionary ?? [:])
                    if await UIApplication.shared.applicationState == .background { return }
                    try await self?.dependencies.sharedSession.getUser()
                    try await self?.dependencies.sharedSession.getUserPublicInfo()
                    try await self?.dependencies.session.getGameStates()
                    await MainActor.run { [weak self] in
                        self?.delegate?.gameFinishLoadingData()
                        let gameHistoryModel = GameHistoryModel(response: tournamentResponse)
                        self?.gameHistoryModel = gameHistoryModel
                        if tournamentResponse.tournament?.status == .waitingToMatch { return }
                        self?.gameOverResultStatus = gameHistoryModel.resultStatus
                        if gameHistoryModel.resultStatus == .won { delegate?.gameRunConfetti() }
                        NotificationCenter.default.post(name: .gameOver, object: gameHistoryModel)
                    }
                }
               
            } catch let error {
                // TODO: Show if error in UI
                print(error)
            }
        }
    }
}

// MARK: - Blitz Mode

extension GameManager {

    /// These are set on buyIntoGame(config: )
    static var blitzScoreArray: [Double: Double]?
    static var blitzMode: Bool?
    static var blitzTimestamp: Int?
    static var blitzBuyIn: Double?
    
    /// Buy into biltz with the given config
    func buyIntoGame(blitz config: BlitzModel) async throws {
        GameManager.blitzMode = true
        GameManager.gameTitle = config.title
        GameManager.amount = config.entryPrice * 100
        
        let response = try await dependencies.session.buyIntoGame(blitz: config)
        dependencies.logger.log(response)
        GameManager.tournamentResponseId = response.id
        GameManager.blitzTimestamp = response.tournament?.createdAt
        dependencies.analytics.logEvent(
            LoggingEvent(
                .gameBuyIn,
                parameters: [
                    "gameType": "blitz",
                    "amount": "\(config.entryPrice * 100)"
                ]
            )
        )
    }
        
    /// Submit the score of the most recent blitz game
    func finishBlitz() {
        self.submitBlitzScore(score: self.score, buyIn: Int(GameManager.blitzBuyIn! * 100))
        self.logSubmitBlitzScore()
    }
    
    /// Retrieve the current blitz distribution
    func getBlitzScoreArray() -> [Double: Double]? {
        return GameManager.blitzScoreArray
    }
    
    /// Set the current blitz buy-in amount
    func setBlitzAmount(blitzBuyIn: Double) {
        GameManager.blitzBuyIn = blitzBuyIn
    }
    
    /// Start observing the blitz distribution
    func startObserveBlitzDataPoints() async throws {
        let data = try await dependencies.session.getBlitzDataPoints()
        await getBucket(response: data)
        blitzDelegate?.newBlitzDataLoaded()
        observeBlitzDataPoints()
    }
    
    /// Observe the blitz distribution
    func observeBlitzDataPoints() {
        Task { [weak self] in
            await self?.dependencies.session.observeBlitzDataPoints { response in
                Task { [weak self] in
                    await self?.getBucket(response: response)
                    self?.blitzDelegate?.newBlitzDataLoaded()
                }
            }
        }
    }
    
    func getBucket(response: [BlitzDataPointResponse]) async {
        if let percentile = await dependencies.session.gameStates?.percentile {
            let maxBucket = 10
            let minBucket = 1
            let bucket = Int(ceil(percentile * 10))
            if bucket > maxBucket {
                prepareBlitzScoreArray(data: getMultipliersFrom(bucket: maxBucket, response: response))
            } else if bucket < minBucket {
                prepareBlitzScoreArray(data: getMultipliersFrom(bucket: minBucket, response: response))
            } else {
                prepareBlitzScoreArray(data: getMultipliersFrom(bucket: bucket, response: response))
            }
        }
    }
    
    private func getMultipliersFrom(bucket: Int, response: [BlitzDataPointResponse]) -> [BlitzMultiplier] {
        return response.filter({ $0.id == String(bucket) }).first?.blitzMultipliers ?? []
    }
    
    // TODO: - TAS-542
    private func prepareBlitzScoreArray(data: [BlitzMultiplier]) {
        GameManager.blitzScoreArray = data.reduce(into: [Double: Double]()) {
            $0[$1.score] = $1.multiple
        }
    }
    
    private func logSubmitBlitzScore() {
        dependencies.analytics.logEvent(
            LoggingEvent(
                .gameEnd,
                parameters: [
                    "gameType": "blitz"
                ]
            )
        )
    }
    
    /// Submit the score of the most recent blitz game
    func submitBlitzScore(score: Double, buyIn: Int) {
        let payout = Int(GameManager.getBlitzPayoutForScoreDouble(totalScore: score) * 100)
        Task { [weak self] in
            do {
                try await self?.dependencies.session.submitBlitzScore(
                    score,
                    buyIn: buyIn,
                    payout: payout,
                    tournamentId: GameManager.tournamentResponseId
                )
                self?.dependencies.logger.log("Blitz Submit Score Complete")
                self?.blitzDelegate?.blitzSubmitDidFinish()
            } catch let error {
                self?.dependencies.logger.log(error, .error)
            }
        }
    }
    
    /// Retrieve the payout for the current score
    static func getBlitzPayoutForScore(totalScore: Double) -> String {
        return getBlitzPayoutForScoreDouble(totalScore: totalScore).formatCurrency()
    }
    
    /// Helper function to retrieve the payout for the current blitz score
    static func getBlitzPayoutForScoreDouble(totalScore: Double) -> Double {
        guard let sortedScores = GameManager.blitzScoreArray?.keys.sorted() , let blitzBuyIn = blitzBuyIn else {
            return 0
        }
        let nextTargetScore = sortedScores.first(where: {$0 > totalScore}) as Double?
        let lastTargetScore = sortedScores.last(where: {$0 <= totalScore }) as Double?
        let nextTargetMoney: Double = GameManager.blitzScoreArray![nextTargetScore ?? 0] ?? 0.0
        let lastTargetMoney: Double = GameManager.blitzScoreArray![lastTargetScore ?? 0] ?? 0.0

        guard let nextTargetScore = nextTargetScore else {
            return (lastTargetMoney * blitzBuyIn).roundToNPlaces(n: 2)
        }

        guard let lastTargetScore = lastTargetScore else {
            let percentOfFirstTarget = Double(nextTargetMoney) * (Double(totalScore) / Double(nextTargetScore))
            return (percentOfFirstTarget * blitzBuyIn).roundToNPlaces(n: 2)
        }
        
        let scoreDifference = nextTargetScore - lastTargetScore
        let scoreDiffPerecent = Double(totalScore - lastTargetScore)/Double(scoreDifference)
        let moneyDifference = Double(nextTargetMoney - lastTargetMoney)
        var updatedMoney = Double(lastTargetMoney) + scoreDiffPerecent * moneyDifference
        updatedMoney *= blitzBuyIn
        return updatedMoney.roundToNPlaces(n: 4) // To make front and BE consistent! Must keep.
    }
}
