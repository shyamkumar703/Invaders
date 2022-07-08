// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct OtherGamesRequestResponse: Response {
    var games: [OtherGame]
}

struct OtherGamesRequest: Request {
    typealias Output = OtherGamesRequestResponse
    var path: String = "users/games"
    var httpMethod: HttpMethod? = .get
}
