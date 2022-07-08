// Copyright © TriumphSDK. All rights reserved.

import UIKit

open class BaseTextFieldButton: UIButton {
    public var action: (() -> Void)?
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()

        setupGestureRecognizer()
    }
    
    public func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func onTap() {
        action?()
    }
    
    public func onPress(action: @escaping () -> Void) {
        self.action = action
    }
}
