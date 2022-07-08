//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import UIKit

public extension UITableView {
    func registerCell<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.identifier)
    }
}
