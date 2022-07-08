// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentsBlitzCellButton: UIButton {
    
    private var haptics = UIImpactFeedbackGenerator()
    
    var titleColor = TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR {
        didSet {
            setTitleColor(titleColor, for: .normal)
        }
    }
    
    var title: String? {
        didSet {
            setupTitle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension TournamentsBlitzCellButton {
    func setupCommon() {
        setTitleColor(titleColor, for: .normal)
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func setupTitle() {
        setTitle(title, for: .normal)
        titleLabel?.font = .rounded(ofSize: 24, weight: .semibold)
        titleLabel?.addCharacterSpacing(kernValue: -0.4)
    }
}

// MARK: - Touches

extension TournamentsBlitzCellButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateWithScale(0.9)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        haptics.impactOccurred()
        animateWithScale(1)
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateWithScale(1)
        super.touchesCancelled(touches, with: event)
    }
    
    func animateWithScale(_ scale: CGFloat) {
        UIView.animate(withDuration: 0.2) { [self] in
            layer.transform = CATransform3DMakeScale(scale, scale, 1)
        }
    }
}
