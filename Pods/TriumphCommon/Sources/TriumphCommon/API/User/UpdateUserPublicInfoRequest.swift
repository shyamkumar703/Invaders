// Copyright © TriumphSDK. All rights reserved.

import Foundation

struct UpdateUserPublicInfoRequest: Request {
    typealias Output = EmptyResponse
    var path: String = "users/update_info"
    var query: RequestQuery?
    var stringifyWithoutEscapingSlashes: Bool = true
    var body: String?
    
    init(query: UpdateUserQuery) {
        self.query = query
        self.body = query.dictionary?.stringify(withoutEscapingSlashes: true)
    }
}

struct UpdateUserQuery: RequestQuery {
    var name: String
    var profilePhotoURL: String
    var username: String?
}
