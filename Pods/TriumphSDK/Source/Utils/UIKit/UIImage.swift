// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

extension UIImage {
    convenience init?(named: String) {
        guard let bundle = TriumphSDK.bundle else { return nil }
        self.init(named: named, in: bundle, compatibleWith: nil)
    }
    
    convenience init?(path: String, extenstion: String = "png") {
        guard let bundle = TriumphSDK.bundle else { return nil }
        guard let bundleUrl = bundle.url(forResource: path, withExtension: extenstion) else { return nil }
        self.init(contentsOfFile: bundleUrl.path)
    }
}
