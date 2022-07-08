// Copyright © TriumphSDK. All rights reserved.

import UIKit

class DashedLineView: UIView {
    var perDashLength: CGFloat = 23.0
    var spaceBetweenDash: CGFloat = 3.0
    var dashColor: UIColor = UIColor.white
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let  path = UIBezierPath()
        if height > width {
            let  point0 = CGPoint(x: self.bounds.midX, y: self.bounds.minY)
            path.move(to: point0)
            
            let  point1 = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
            path.addLine(to: point1)
            path.lineWidth = width
            
        } else {
            let  point0 = CGPoint(x: self.bounds.minX, y: self.bounds.midY)
            path.move(to: point0)
            
            let  point1 = CGPoint(x: self.bounds.maxX, y: self.bounds.midY)
            path.addLine(to: point1)
            path.lineWidth = height
        }
        
        let  dashes: [ CGFloat ] = [ perDashLength, spaceBetweenDash ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)
        
        path.lineCapStyle = .butt
        dashColor.set()
        path.stroke()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .clear
    }
    
    private var width : CGFloat {
        return self.bounds.width
    }
    
    private var height : CGFloat {
        return self.bounds.height
    }
}
