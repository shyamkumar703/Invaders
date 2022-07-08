// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TweeTextField

class TweeTextField: TweeAttributedTextField {
    private var content: TextFieldContent
    
    init(_ content: TextFieldContent) {
        self.content = content
        super.init(frame: .zero)
        setupCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var contentType: TextFieldContentType {
        content.type
    }
    
    func setupCommon() {
        tweePlaceholder = content.placeholder
        keyboardType = .default
        keyboardAppearance = .dark
        font = .systemFont(ofSize: 24)
        textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        placeholderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        lineColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        lineWidth = 1
        placeholderDuration = 0.2
        placeholderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        originalPlaceholderFontSize = 17.0
        placeholderLabel.font = .boldSystemFont(ofSize: 17.0)
        autocorrectionType = .no
        
        if content.type == .givenName {
            textContentType = .givenName
        }
        
        if content.type == .familyName {
            textContentType = .familyName
        }
    }
}
