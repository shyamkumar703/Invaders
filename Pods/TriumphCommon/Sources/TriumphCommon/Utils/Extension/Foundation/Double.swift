// Copyright © TriumphSDK. All rights reserved.

import Foundation

public extension Double {
    func formatCurrency() -> String {
        var currencyMoney = ""
        if self < 1.00 {
            currencyMoney = String(format: "%.0f¢", self*100)
        } else {
            currencyMoney = String(format: "$%.02f", self)
            if currencyMoney.hasSuffix(".00") {
                currencyMoney = String(currencyMoney.dropLast(3))
            }
        }
        return currencyMoney
    }
    
    func roundToNPlaces(n: Int) -> Double {
        if n < 1 {
            return self.rounded()
        }
        let tenToTheN = pow(10.0,Double(n))
        return Double(Int(self * tenToTheN)) / tenToTheN
    }
    
    func makeCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        let cleanFormatter = NumberFormatter()
        cleanFormatter.numberStyle = .currency
        cleanFormatter.minimumFractionDigits = 0
        cleanFormatter.maximumFractionDigits = 2
        
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(String(describing: cleanFormatter.string(from: (self) as NSNumber)!))"
        } else {
            return "\(String(describing: formatter.string(from: (self) as NSNumber)!))"
        }
    }
}
