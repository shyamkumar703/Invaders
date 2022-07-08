// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class ClockView: UIView {
    private let circleView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 8
        view.layer.cornerRadius = view.frame.size.width * 0.5
        return view
    }()
    
    private let handsContaierLayer: CALayer = {
        let layer = CALayer()
        layer.position = CGPoint(x: 37.5, y: 37.5)
        return layer
    }()
    
    private let hourHand: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(
            roundedRect: CGRect(x: -3, y: -3, width: 25, height: 6),
            cornerRadius: 3.5
        ).cgPath
        layer.fillColor = UIColor.white.cgColor
        return layer
    }()
    
    private let minuteHand: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(
            roundedRect: CGRect(x: -3, y: -3, width: 6, height: 28),
            cornerRadius: 3
        ).cgPath
        layer.fillColor = UIColor.white.cgColor
        return layer
    }()
    
    private let rotationAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = .pi * 2.0
        animation.duration = 5
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayers()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension ClockView {
    func startAnimating() {
        minuteHand.add(rotationAnimation, forKey: "com.triumph.rotation.animation")
    }
}

private extension ClockView {
    func setupLayers() {
        handsContaierLayer.addSublayer(hourHand)
        handsContaierLayer.addSublayer(minuteHand)
        circleView.layer.addSublayer(handsContaierLayer)
    }
    
    func setupView() {
        addSubview(circleView)
    }
}
