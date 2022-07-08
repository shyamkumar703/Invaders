// Copyright © TriumphSDK. All rights reserved.

import UIKit

open class BaseButton: UIButton {

    public var color: UIColor?
    public var colorOnPress: UIColor?
    public var colorDisabled: UIColor? = .gray
    public var colorTitle: UIColor? = .blue
    public var colorTitleDisabled: UIColor? = .black
    
    public var isGlowingEnabled: Bool = false {
        didSet {
            setupState()
        }
    }
    
    public var isEnabledState: Bool = true {
        didSet {
            setupState()
        }
    }
    
    open override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = self.colorOnPress
            }
            super.isHighlighted = newValue
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        setupState()
    }
}

// MARK: - Setup

private extension BaseButton {
    func setupState() {
        if isEnabled == false || isEnabledState == false {
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = self.colorDisabled
                self.layer.shadowOpacity = 0
                self.setTitleColor(self.colorTitleDisabled, for: .normal)
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = self.color
                self.setTitleColor(self.colorTitle, for: .normal)
                guard self.isGlowingEnabled == true, let color = self.color else { return }
                self.layer.doGlowAnimation(withColor: color)
            }
        }
    }
}

// MARK: - Touches alpha

public extension BaseButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.1) { self.titleLabel?.alpha = 0.3 }
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.1) { self.titleLabel?.alpha = 1 }
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.1) { self.titleLabel?.alpha = 1 }
        super.touchesCancelled(touches, with: event)
    }
}
