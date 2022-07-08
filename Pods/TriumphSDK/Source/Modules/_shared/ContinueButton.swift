// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

class ContinueButton: PrimaryButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        isGlowingEnabled = true
        setupTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupRadius()
    }
}

// MARK: - Setup

private extension ContinueButton {
  
    func setupRadius() {
        layer.cornerRadius = frame.size.height / 2
    }
    
    func setupTitle() {
        titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .medium)
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        titleLabel?.sizeToFit()
    }
}

