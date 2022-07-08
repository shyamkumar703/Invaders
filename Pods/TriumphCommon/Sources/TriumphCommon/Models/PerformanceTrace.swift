// Copyright © TriumphSDK. All rights reserved.

import Foundation
import FirebasePerformance

public struct PerformanceTrace: Hashable, RawRepresentable {
    public var rawValue: String
    public var trace: Trace?

    public init(rawValue: String) {
        self.rawValue = rawValue
        self.trace = Performance.sharedInstance().trace(name: name)
    }
    
    public var id: String {
        rawValue
    }
    
    public var name: String {
        rawValue
    }
}
