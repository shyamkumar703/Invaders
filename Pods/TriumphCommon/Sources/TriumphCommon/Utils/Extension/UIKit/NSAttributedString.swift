// Copyright © TriumphSDK. All rights reserved.

import UIKit

public extension NSAttributedString {
    func withCustomFormat(lineSpacing: CGFloat? = nil, paragraphSpacing: CGFloat? = nil, alignemnt: NSTextAlignment? = nil) -> NSAttributedString {
        
        guard lineSpacing != nil && paragraphSpacing != nil && alignemnt != nil else {
            return self
        }
        
        let attributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        if let lineSpacing = lineSpacing {
            paragraphStyle.lineSpacing = lineSpacing
        }

        if let paragraphSpacing = paragraphSpacing {
            paragraphStyle.paragraphSpacing = paragraphSpacing
        }
        
        if let alignemnt = alignemnt {
            paragraphStyle.alignment = alignemnt
        }
        
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: string.count)
        )

        return NSAttributedString(attributedString: attributedString)
    }
}
