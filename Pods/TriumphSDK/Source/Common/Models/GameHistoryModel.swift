// Copyright © TriumphSDK. All rights reserved.

import Foundation
import FirebaseAuth
    
struct GameHistoryModel: HistoryModel, Hashable {
    enum HistoryState {
        case result, waiting, done
    }

    enum GameType: String {
        case versus = "Versus"
        case blitz = "Blitz"
    }
    
    enum ResultStatus {
        case won, lost, draw
    }
    
    var currentUserUID: String?
    var id: String?
    var player: PlayerModel?
    var opponent: PlayerModel?
    var gameTitle: String?
    var amount: Double?
    var prize: Double?
    var createdAt: Int?
    var matchedAt: Int?
    var tournamentConfig: TournamentModel?
    var blitzConfig: BlitzData?
    var gameType: GameType = .versus
    
    // MARK: - Init of a player with ready score
    public init(_ player: PlayerModel?, currentUserUID: String? = Auth.auth().currentUser?.uid) {
        self.player = player
        self.currentUserUID = currentUserUID
    }
    
    // MARK: - Init with TournamentResponse
    public init(response: TournamentVersus, currentUserUID: String? = Auth.auth().currentUser?.uid) {
        self.currentUserUID = currentUserUID
        self.id = response.id
        self.createdAt = response.tournament?.createdAt
        self.matchedAt = response.tournament?.matchedAt

        guard let tournament = response.tournament else { return }
        initVersus(tournament)
        
        self.amount = response.tournament?.config?.entryPrice
        self.prize = (Double(response.tournament?.config?.prize ?? 0) / 100.0)
        self.tournamentConfig = tournament.config
        self.tournamentConfig?.id = tournament.configId
    }
    
    // MARK: - Init with tournamentResponseId and TournamentData
    init(tournament: TournamentData) {
        self.init(tournamentResponseId: tournament.id, tournament: tournament)
    }
    
    init(
        tournamentResponseId: String?,
        tournament: TournamentData,
        currentUserUID: String? = Auth.auth().currentUser?.uid
    ) {
        self.currentUserUID = currentUserUID
        self.id = tournamentResponseId
        self.createdAt = tournament.createdAt
        self.matchedAt = tournament.matchedAt
        self.amount = tournament.config?.entryPrice
        self.prize = (Double(tournament.config?.prize ?? 0) / 100.0)
        self.gameType = .versus
        self.gameTitle = tournament.config?.gameTitle
        self.tournamentConfig = tournament.config
        self.tournamentConfig?.id = tournament.configId
        
        initVersus(tournament)
    }
    
    init(blitz: BlitzData) {
        self.init(blitzData: blitz, id: blitz.id)
    }
    
    init(blitzData: BlitzData, id: String?) {
        self.id = id
        self.gameType = .blitz
        self.gameTitle = blitzData.tournamentDefinition?.entryPrice?.formatCurrency()
        self.createdAt = blitzData.createdAt
        self.matchedAt = blitzData.finishedAt
        self.amount = blitzData.score
        self.blitzConfig = blitzData
        
        self.player = PlayerModel(uid: blitzData.uid, score: blitzData.payout ?? 0, username: nil, userpic: nil)
    }
}

private extension GameHistoryModel {

    mutating func initVersus(_ tournament: TournamentData) {
        if currentUserUID == tournament.player1.uid {
            self.player = tournament.player1
            self.opponent = tournament.player2
        } else {
            self.player = tournament.player2
            self.opponent = tournament.player1
        }
    }
}

extension GameHistoryModel {
    var wonAmount: Double {
        switch gameType {
        case .versus:
            switch resultStatus {
            case .lost: return 0
            case .draw: return potAmount / 2
            default: return potAmount
            }
            
        case .blitz:
            // It's not actually a score it's a prize
            return Double(player?.score ?? 0)
        }
    }
    
    var potAmount: Double {
        (prize ?? 0)
    }
    
    var state: HistoryState {
        switch gameType {
        case .versus:
            guard opponent?.score != nil else { return .waiting }
            return .result
        case .blitz:
            return .result
        }
    }
    
    var participants: Int {
        switch gameType {
        case .versus:
            return 2
        case .blitz:
            return 1
        }
    }
    
    var result: [PlayerModel?] {
        switch gameType {
        case .versus: return [opponent, player]
        case .blitz: return [player]
        }
    }

    var winnerScore: Double? {
        guard let playerScore = player?.score,
              let opponentScore = opponent?.score else { return nil }
        return max(playerScore, opponentScore)
    }
    
    var resultStatus: ResultStatus? {
        guard let opponentScore = opponent?.score ?? opponent?.finalScore?.value else { return nil }
        
        switch (player?.score ?? 0, opponentScore) {
        case let (score1, score2) where score1 > score2: return .won
        case let (score1, score2) where score1 < score2: return .lost
        case let (score1, score2) where score1 == score2: return .draw
        default: return nil
        }
    }
    
    var isZeroDraw: Bool {
        player?.score == .zero && opponent?.score == .zero
    }
    
    var buyIn: Double {
        potAmount / Double(participants)
    }
    
    var date: Date {
        guard let timestamp = matchedAt ?? createdAt else { return Date() }
        return Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
    }
}

// MARK: - HistoryProtocol conformance

extension GameHistoryModel {
    var title: String? {
        gameTitle
    }

    var resultTitle: String? {
        nil
    }
    
    var description: String? {
        nil
    }
}

// MARK: - Hashable Conformance

extension GameHistoryModel {
    static func == (lhs: GameHistoryModel, rhs: GameHistoryModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
