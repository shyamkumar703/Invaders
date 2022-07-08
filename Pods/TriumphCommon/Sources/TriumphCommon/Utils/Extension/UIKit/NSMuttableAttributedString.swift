// Copyright © TriumphSDK. All rights reserved.

import UIKit

public struct TextWithLink {
    public typealias Link = (text: String, link: String)
    
    public var string: String
    public var links: [Link]
}

public extension NSMutableAttributedString {

    convenience init(
        _ model: TextWithLink?,
        linkColor color: UIColor = .orandish
    ) {
        
        self.init(string: model?.string ?? "")
        guard let model = model else { return }
        withLinks(model.links, color: color)
    }
    
    func setColorFor(text: String, color: UIColor = .orandish, font: UIFont? = nil) {
        let range = self.mutableString.range(of: text, options: .caseInsensitive)
        if range.location != NSNotFound {
            self.addAttributes(
                [
                    .foregroundColor: color
                ],
                range: range
            )
            guard let font = font else { return }
            self.addAttribute(.font, value: font, range: range)
        }
    }
    
    func setLinkFor(text: String, link: String, color: UIColor = .orandish) {
        let range = self.mutableString.range(of: text, options: .caseInsensitive)
        if range.location != NSNotFound {
            self.addAttributes(
                [
                    .foregroundColor: color,
                    .link: link
                ],
                range: range
            )
        }
    }
    
    func setLinkFor(textLink: TextWithLink.Link, color: UIColor = .orandish) {
        setLinkFor(text: textLink.text, link: textLink.link, color: color)
    }
    
    func withLinks(_ textLinks: [TextWithLink.Link], color: UIColor = .orandish) {
        textLinks.forEach {
            setLinkFor(textLink: $0)
        }
    }
}
