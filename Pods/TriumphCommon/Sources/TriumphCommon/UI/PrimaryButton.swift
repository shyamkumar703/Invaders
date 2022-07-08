// Copyright © TriumphSDK. All rights reserved.

import UIKit

open class PrimaryButton: BasePrimaryButton {
    
    private var action: (() -> Void)?
    private lazy var haptics = UIImpactFeedbackGenerator()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        isGlowingEnabled = false
        setupTitle()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()

        setupGestureRecognizer()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        setupRadius()
    }
}

// MARK: - Setup

private extension PrimaryButton {
  
    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
    }

    func setupRadius() {
        layer.cornerRadius = frame.size.height / 2
    }
    
    func setupTitle() {
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.textAlignment = .center
        titleLabel?.sizeToFit()
    }

    // MARK: - Action

    @objc private func onTap() {
        haptics.impactOccurred()
        action?()
    }
}

// MARK: - Methods to use

public extension PrimaryButton {
    func onPress(action: @escaping () -> Void) {
        self.action = action
    }
}

