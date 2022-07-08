// Copyright © TriumphSDK. All rights reserved.

import UIKit

public enum FlexibleString {
    case string(String)
    case attributedString(NSAttributedString)
}

public extension UILabel {

    func setText(_ text: FlexibleString?) {
        guard let text = text else { return }
        switch text {
        case .string(let text):
            self.text = text
        case .attributedString(let attributedString):
            self.attributedText = attributedString
        }
    }

    func addInterlineSpacing(spacingValue: CGFloat = 2) {
        guard let textString = text else { return }
        let attributedString = NSMutableAttributedString(string: textString)
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineSpacing = spacingValue
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )
        attributedText = attributedString
    }
    
    func addCharacterSpacing(kernValue: Double = 1) {
        if let labelText = text, !labelText.isEmpty {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(
                .kern,
                value: kernValue,
                range: NSRange(location: 0, length: attributedString.length - 1)
            )
            attributedText = attributedString
        }
    }
}
