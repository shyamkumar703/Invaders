// Copyright © TriumphSDK. All rights reserved.

import Foundation

public protocol Response: Codable { }

// MARK: - EmptyResponse

public struct EmptyResponse: Response {
    public init() {}
}
