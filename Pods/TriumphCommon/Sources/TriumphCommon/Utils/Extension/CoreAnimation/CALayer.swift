// Copyright © TriumphSDK. All rights reserved.

import UIKit

public extension CALayer {
    func applyGradient(of colors: [UIColor], atAngle angle: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.calculatePoints(for: angle)
        masksToBounds = true
        insertSublayer(gradient, at: 0)
    }
    
    func doGlowAnimation(withColor color: UIColor, from: CGFloat = 4, to: CGFloat = 15) {
        masksToBounds = false
        shadowColor = color.cgColor
        shadowRadius = 0
        shadowOpacity = 1
        shadowOffset = .zero

        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = from
        glowAnimation.toValue = to
        glowAnimation.beginTime = CACurrentMediaTime() + 0.05
        glowAnimation.duration = 1
        glowAnimation.fillMode = .removed
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = .infinity
        glowAnimation.isRemovedOnCompletion = false
        add(glowAnimation, forKey: "shadowGlowingAnimation")
    }
    
    func stopGlowAnimation() {
        
    }
    
    func shakeAnimation<T: UIView>(sender: T) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.speed = 0.8
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: sender.center.x - 5, y: sender.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: sender.center.x + 5, y: sender.center.y))
        add(animation, forKey: "position")
    }
}
