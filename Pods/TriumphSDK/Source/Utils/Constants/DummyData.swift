//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation
import TriumphCommon

struct Dummy {
    struct Tournaments {
        static let tournaments = [
            TournamentModel(
                entryPrice: 0,
                prize: 1,
                emoji: "⚔️",
                entryType: .priceEntry,
                gameTitle: "Practice",
                archived: false,
                entryTokens: 0,
                prizeTokens:0
            ),
            TournamentModel(
                entryPrice: 110,
                prize: 200,
                emoji: "🥉",
                entryType: .priceEntry,
                gameTitle: "Bronze",
                archived: false,
                entryTokens: 0,
                prizeTokens:0
            ),
            TournamentModel(
                entryPrice: 220,
                prize: 400,
                emoji: "🥈",
                entryType: .priceEntry,
                gameTitle: "Silver",
                archived: false,
                entryTokens: 0,
                prizeTokens:0
            ),
            TournamentModel(
                entryPrice: 550,
                prize: 1000,
                emoji: "🥇",
                entryType: .priceEntry,
                gameTitle: "Gold",
                archived: false,
                entryTokens: 0,
                prizeTokens:0
            ),
            TournamentModel(
                entryPrice: 2750,
                prize: 5000,
                emoji: "💎",
                entryType: .priceEntry,
                gameTitle: "Diamond",
                archived: false,
                entryTokens: 0,
                prizeTokens:0
            )
        ]

        static let tournamentsPointsBalance = "5"
        static let tournamentsPointsTickets = "10"
        
        static let history: [GameHistoryModel] = [
            
        ]
    }
    
    struct PhoneOTP {
        static let code = "123456"
    }
    
    struct Matching {
        static let players: [PlayerModel] = []
    }
    
    struct GameOver {
        static let userScore = "1457"
        static let isOpponentPlaying = false
    }
    
    struct Blitz {
        static let segmentItems: [Double] = [1.00, 5.00, 10.00]
        static let scoreMultipliers: [Double] = [0.25, 0.5, 0.75, 1.25, 1.50, 1.75, 2.00, 2.25, 2.5]
        static var blitzItems: [Int: Double] = [
            2700 : 1.6,
            1800 : 1.4,
            1600 : 1.2,
            1543 : 1.0,
            1000 : 0.6,
            800  : 0.4,
            600  : 0.3,
            400  : 0.2,
            200  : 0.1
        ]
    }
}
