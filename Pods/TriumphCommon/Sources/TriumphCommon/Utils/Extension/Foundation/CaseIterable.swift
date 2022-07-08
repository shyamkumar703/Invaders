// Copyright © TriumphSDK. All rights reserved.

import Foundation

public extension CaseIterable where Self: Equatable {
    func ordinal() -> Self.AllCases.Index? {
        return Self.allCases.firstIndex(of: self)
    }
}
