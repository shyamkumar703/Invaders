//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit

public struct TriumphColors {
    public var TRIUMPH_PRIMARY_COLOR: UIColor
    public var TRIUMPH_GRADIENT_COLORS: [UIColor]
    
    public init(
        primary: UIColor = #colorLiteral(
            red: 1,
            green: 0.4078431373,
            blue: 0.137254902,
            alpha: 1
        ),
        gradient: [UIColor] = [#colorLiteral(red: 0.9136844277, green: 0.2966261506, blue: 0.2330961823, alpha: 1), #colorLiteral(red: 0.9810395837, green: 0.5708991885, blue: 0.154723525, alpha: 1)]
    ) {
        self.TRIUMPH_PRIMARY_COLOR = primary
        self.TRIUMPH_GRADIENT_COLORS = gradient
    }
}

public extension UIColor {
    static let orandish = #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1)
    static let darkOrandish = #colorLiteral(red: 0.7608085393, green: 0.3385702903, blue: 0.2182116384, alpha: 1)
    static let lightSilver = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    static let grayish = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    static let darkGrayish = #colorLiteral(red: 0.4916929672, green: 0.5, blue: 0.4706595721, alpha: 1)
    static let greenish = #colorLiteral(red: 0.05490196078, green: 0.6470588235, blue: 0, alpha: 1)
    static let lightGreen = #colorLiteral(red: 0.2901960784, green: 0.937254902, blue: 0.137254902, alpha: 1)
    static let lostRed = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    static let tungsten = #colorLiteral(red: 0.2039215686, green: 0.2196078431, blue: 0.2470588235, alpha: 1)
    static let ironDark = #colorLiteral(red: 0.2039215686, green: 0.2196078431, blue: 0.2470588235, alpha: 1)
    static let lead = #colorLiteral(red: 0.09300848097, green: 0.09300848097, blue: 0.09300848097, alpha: 1)
    static let lightDark = #colorLiteral(red: 0.0431372549, green: 0.0431372549, blue: 0.0431372549, alpha: 1)
}
