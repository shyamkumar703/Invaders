// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct BlitzMultiplier: Codable {
    var multiple: Double
    var score: Double
}

struct BlitzDataPointResponse: Response, SelfIdentifiable {
    var id: String?
    var blitzMultipliers: [BlitzMultiplier]
}

struct BlitzDataPointsRequest: IdentifiableOutputRequest {
    typealias Output = BlitzDataPointResponse
    var path: String
    
    init(id: String) {
        path = "games/\(id)/blitzBuckets"
    }
}
