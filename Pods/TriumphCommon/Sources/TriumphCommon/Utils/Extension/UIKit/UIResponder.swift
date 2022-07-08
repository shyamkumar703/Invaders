// Copyright © TriumphSDK. All rights reserved.

import UIKit

public extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
