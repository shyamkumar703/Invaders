// Copyright © TriumphSDK. All rights reserved.

import UIKit

public extension Int {
    func prepareCurrency() -> Double {
        Double(self) / 100
    }

    func formatCurrency() -> String {
        self.prepareCurrency()
            .formatCurrency()
    }
}
