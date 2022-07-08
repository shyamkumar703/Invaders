// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentsItemPlayButton: UIButton {
    
    private let haptics = UIImpactFeedbackGenerator()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = .white
        layer.cornerRadius = 10
        setImage(UIImage(systemName: "play.fill"), for: .normal)
        tintColor = TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR
        imageView?.contentMode = .scaleAspectFit
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
        imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
}

// MARK: - Touches alpha

extension TournamentsItemPlayButton {
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
