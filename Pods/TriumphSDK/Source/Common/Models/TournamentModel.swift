// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

public enum TournamentType: String {
    case versus, blitz
}

public class TournamentModel: Response, SelfIdentifiable {
    public enum EntryType: String, Codable {
        case priceEntry
    }
    
    public var id: String? // FIXME: Shouldn't be optional
    
    // backing for computed property entryPrice
    private var dbEntryPrice: Double?
    
    // computed property to accomodate Codable
    public var entryPrice: Double? {
        get {
            (dbEntryPrice ?? 0) / 100.0
        }
        set {}
    }
   
    public var type: String?
    public var archived: Bool?
    public var prize: Int?
    public var emoji: String?
    public var entryTokens: Int?
    public var prizeTokens: Int?

    public var totalPrice: Double {
        get {
            Double(prize ?? 0)/100.0
        }
        set {}
    }
    
    public var entryType: EntryType = .priceEntry
    public var gameTitle: String
    public var gameTitleWithEmoji: String {
        "\(gameTitle) \(emoji ?? "")"
    }
        
    public init(
        entryPrice: Double,
        prize: Int,
        emoji: String? = nil,
        entryType: EntryType = .priceEntry,
        gameTitle: String,
        archived: Bool,
        entryTokens: Int,
        prizeTokens: Int
    ) {
        self.dbEntryPrice = entryPrice * 100
        self.prize = prize
        self.entryType = entryType
        self.gameTitle = gameTitle
        self.archived = archived
        self.emoji = emoji
        self.entryTokens = entryTokens
        self.prizeTokens = prizeTokens
    }
    
    private enum CodingKeys: String, CodingKey {
        case dbEntryPrice = "entryPrice"
        case prize
        case gameTitle = "name"
        case type
        case archived
        case emoji
        case entryTokens
        case prizeTokens
    }
    
    public func maxTokensToUse(tokens: Int) -> Int {
        return min(tokens, entryTokens ?? 0)
    }
    
    public func getPriceAfterTokens(tokens: Int) -> Double {
        guard let entryPrice = entryPrice else { return 0 }

        let maxReplaceablePrice = Double(maxTokensToUse(tokens: tokens)) / 100
        return entryPrice - maxReplaceablePrice
    }
}
