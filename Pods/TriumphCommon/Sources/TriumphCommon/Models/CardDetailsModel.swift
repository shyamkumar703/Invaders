//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation

public enum CardDetailsInvalidType: String {
    case invalidCardNumber = "INVALID CARD NUMBER"
    case invalidExpDate = "INVALID EXP DATE"
}

public struct CardDetailsModel {
    public var number: String
    public var expirationDate: String
    public var expirationYear: String?
    
    public init(number: String, expirationDate: String, expirationYear: String? = nil) {
        self.number = number
        self.expirationDate = expirationDate
        self.expirationYear = expirationYear
    }
    
    public var invalidType: CardDetailsInvalidType? {
        if expirationDate.count != 4 {
            return .invalidExpDate
        }
        
        if number.count != 16 {
            return .invalidCardNumber
        }
        
        return nil
    }
    
    public var formatedExpiration: String {
        var string = ""
        string.append(expirationDate[2])
        string.append(expirationDate[3])
        string.append("-")
        string.append(expirationDate[0])
        string.append(expirationDate[1])

        return string
    }
    
    public var formatedDate: String {
        var string = expirationDate
        let i = string.index(string.startIndex, offsetBy: 2)
        string.insert("-", at: i)
        return string
    }
    
    public var formatedNumber: String {
        var cardNumber = number
        cardNumber.insert("-", at: cardNumber.index(cardNumber.startIndex, offsetBy: 4))
        cardNumber.insert("-", at: cardNumber.index(cardNumber.startIndex, offsetBy: 9))
        cardNumber.insert("-", at: cardNumber.index(cardNumber.startIndex, offsetBy: 14))
        return cardNumber
    }
}
