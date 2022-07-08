// Copyright © TriumphSDK. All rights reserved.

import Foundation

enum BlitzInfographicItemType {
    case unit, title, result
}

struct BlitzInfographicItemModel {
    var score: String
    var prize: String
    var type: BlitzInfographicItemType
}
