// Copyright © TriumphSDK. All rights reserved.

import UIKit

public extension UIImage {
    internal convenience init?(named: String) {
        let bundle = TriumphCommon.bundle
        self.init(named: named, in: bundle, compatibleWith: nil)
    }
    
    /// Base User Interface Icon
    convenience init?(icon: BaseIcon) {
        self.init(named: icon.rawValue)
    }
    
    convenience init?(commonNamed: String) {
        self.init(named: commonNamed)
    }
}

extension UIImage {
    
}
