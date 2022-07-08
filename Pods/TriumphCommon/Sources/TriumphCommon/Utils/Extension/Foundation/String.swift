// Copyright © TriumphSDK. All rights reserved.

import Foundation

public extension String {
    func prepareFirebaseOddPath() -> (path: String, lastPart: String)? {
        if let url = URL(string: self), url.pathComponents.count % 2 != 0 {
            return (
                path: url.deletingLastPathComponent().absoluteString,
                lastPart: url.lastPathComponent
            )
        } else {
            return nil
        }
    }
    
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (
                lower: max(0, min(length, r.lowerBound)),
                upper: min(length, max(0, r.upperBound))
            )
        )
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

    // formatting text for currency textField
    func currencyInputFormatting() -> String {
    
        var number: NSNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
    
        guard let amountWithPrefix = self.onlyNumbers() else { return "" }
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
    
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else { return "" }
        return formatter.string(from: number)!
    }
    
    func onlyNumbers() -> String? {
        var amountWithPrefix = self

        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        return amountWithPrefix
    }
}
