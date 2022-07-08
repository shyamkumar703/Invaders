// Copyright © TriumphSDK. All rights reserved.

import Foundation
struct UserSupportedLocationQuery: RequestQuery {
    var isInSupportedLocation: Bool
}

struct UpdateUserLocationEligibilityRequest: Request {
    typealias Output = EmptyResponse
    var path: String
    var query: RequestQuery?
    var dict: [AnyHashable: Any]?

    init(uid: String, isInSupportedLocation: Bool) {
        self.path = "appUsers/\(uid)"
        self.query = UserSupportedLocationQuery(isInSupportedLocation: isInSupportedLocation)
    }
}
