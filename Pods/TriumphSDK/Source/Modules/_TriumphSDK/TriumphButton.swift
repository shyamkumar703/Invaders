// Copyright © TriumphSDK. All rights reserved.

import UIKit

public class TriumphButton: UIButton {
    private let haptics = UIImpactFeedbackGenerator()

    public init() {
        super.init(frame: .zero)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public methods

public extension TriumphButton {
    /// Simple small button with Triumph Logo
    func setupWithTriumphLogo() {
        let image = UIImage(named: "logo")
        setImage(image, for: .normal)
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = UIEdgeInsets(top: 16, left: 14, bottom: 14, right: 16)
        backgroundColor = .black
        frame.size = CGSize(width: 60, height: 60)
        layer.cornerRadius = 0.5 * frame.height
        clipsToBounds = true
    }
}
// MARK: - Setup

private extension TriumphButton {
    func setupCommon() {
        configureTriumph()
    }
    
    func configureTriumph() {
        addTarget(self, action: #selector(onTriumphButtonPress), for: .touchUpInside)
    }

    @objc func onTriumphButtonPress(_ sender: UIButton) {
        haptics.impactOccurred()
        TriumphSDK.presentTriumphViewController()
    }
}
