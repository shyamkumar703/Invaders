// Copyright © TriumphSDK. All rights reserved.

import UIKit

open class BottomDisclaimerView: UITextView {
    
    public var disclaimerText: NSAttributedString? {
        didSet {
            setupDisclaimer()
        }
    }

    public init() {
        super.init(frame: .zero, textContainer: nil)
        setupCommon()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension BottomDisclaimerView {
    func setupCommon() {
        backgroundColor = .clear
        // TODO: Color Shoud be configurable
        tintColor = .orandish
    }
    
    func setupDisclaimer() {
        attributedText = disclaimerText
        textColor = .white
        font = UIFont.systemFont(ofSize: 12, weight: .bold)
        textAlignment = .center
    }
}
