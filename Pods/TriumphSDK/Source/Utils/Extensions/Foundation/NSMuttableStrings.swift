// Copyright © TriumphSDK. All rights reserved.

import UIKit

extension NSMutableAttributedString {
    func addToken(attributes: [NSAttributedString.Key: Any]) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "token")?.withTintColor(.white)
        self.append(NSMutableAttributedString(string: " "))
        self.append(NSMutableAttributedString(attachment: imageAttachment))
    }
    
    static var largeToken: NSAttributedString {
        let imageAttachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        imageAttachment.image = UIImage(named: "token")?.withTintColor(.lightGreen).withConfiguration(configuration)
        return NSAttributedString(attachment: imageAttachment)
    }
    
    static func token(with size: UIFont.TextStyle, tintColor: UIColor = .white) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        let configuration = UIImage.SymbolConfiguration(textStyle: size)
        imageAttachment.image = UIImage(named: "token")?.withTintColor(tintColor).withConfiguration(configuration)
        return NSAttributedString(attachment: imageAttachment)
    }
}
