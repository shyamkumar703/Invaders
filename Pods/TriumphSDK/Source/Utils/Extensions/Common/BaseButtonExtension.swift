// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

// MARK: - Allow color changes
// TODO: - COMMON: it is needed?
extension BaseButton {
    func setColor(color: UIColor, colorOnPress: UIColor? = nil) {
        self.color = color
        self.colorOnPress = (colorOnPress != nil) ? colorOnPress : color
    }
}
