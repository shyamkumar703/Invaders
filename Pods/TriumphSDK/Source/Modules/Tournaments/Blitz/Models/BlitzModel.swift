// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct BlitzModel {
    var score: Int
    var entryPrice: Double
    var seed: UInt64?
    var multipliers: [Double: Double]?

    var title: String {
        "$ " + String(format: "%.2f", entryPrice) + " Blitz"
    }
}
