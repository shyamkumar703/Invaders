// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct UserTutorialQuery: RequestQuery {
    var hasSeenTutorial: Bool = false
}

struct UserTutorialRequest: Request {
    typealias Output = EmptyResponse
    var path: String
    var query: RequestQuery?
    
    init(uid: String, isTutorialCompleted: Bool = true) {
        self.path = "appUsers/\(uid)"
        self.query = UserTutorialQuery(hasSeenTutorial: isTutorialCompleted)
    }
}
