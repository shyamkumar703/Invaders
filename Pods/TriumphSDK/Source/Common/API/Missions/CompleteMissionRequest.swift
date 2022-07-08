// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct CompleteMissionQuery: RequestQuery {
    var game: String
    var missionName: String
}

struct CompleteMissionRequest: Request {
    typealias Output = EmptyResponse
    var path: String = "missions/complete"
    var query: RequestQuery?
    var body: String?
    
    init(query: CompleteMissionQuery) {
        self.query = query
        self.body = query.dictionary?.stringify()
    }
}
