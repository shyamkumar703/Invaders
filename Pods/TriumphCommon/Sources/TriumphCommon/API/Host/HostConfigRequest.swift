// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct HostConfigRequest: Request {
    typealias Output = HostConfig
    var path: String = "appConfig/hostApp"
}
