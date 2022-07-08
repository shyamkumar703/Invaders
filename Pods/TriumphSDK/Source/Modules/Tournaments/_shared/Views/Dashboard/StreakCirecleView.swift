// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class StreakCirecleView: UIView {
    
    var isHighlighted: Bool = false {
        didSet {
            circleLayer.fillColor = isHighlighted
            ? TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR.cgColor
            : UIColor.tungsten.cgColor
        }
    }
    
    let circleLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleLayer.position.x = (frame.width - 22) / 2
    }
    
    func setupCommon() {
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 22, height: 22)).cgPath

        layer.addSublayer(circleLayer)
    }
}
