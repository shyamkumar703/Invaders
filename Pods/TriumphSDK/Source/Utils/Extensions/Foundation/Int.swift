//
//  Int.swift
//  TriumphSDK
//
//  Created by Maksim Kalik on 6/1/22.
//

import Foundation

extension Int {
    func formatTokens(
        attributes: [NSMutableAttributedString.Key: Any] = [:],
        tintColor: UIColor = .white,
        size: UIFont.TextStyle? = nil,
        additionalText: String? = nil,
        shouldIncludeWordTokens: Bool = false
    ) -> NSMutableAttributedString {
        let mutableString = NSMutableAttributedString(string: "\(self) \(shouldIncludeWordTokens ? "tokens " : "")", attributes: attributes)
        
        if let size = size {
            mutableString.append(NSMutableAttributedString.token(with: size, tintColor: tintColor))
        } else {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(named: "token")?.withTintColor(tintColor)

            mutableString.append(NSMutableAttributedString(attachment: imageAttachment))
        }
        
        if let additionalText = additionalText {
            mutableString.append(NSMutableAttributedString(string: " \(additionalText)", attributes: attributes))
        }
        return mutableString
    }
}
