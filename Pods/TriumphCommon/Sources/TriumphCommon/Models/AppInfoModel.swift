// Copyright © TriumphSDK. All rights reserved.

import Foundation

public struct AppInfoModel {
    public var id: String
    public var title: String?
    public var icon: String?
    public var scoreType: DecimalPoints = .zero
    
    public init(
        id: String,
        title: String? = nil,
        icon: String? = nil,
        scoreType: DecimalPoints = .zero
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.scoreType = scoreType
    }
}

public enum DecimalPoints: Int {
    case zero = 0
    case one = 1
    case two = 2

    public var format: String {
        switch self {
        case .zero: return "%.0f"
        case .one: return "%.1f"
        case .two: return "%.2f"
        }
    }
}
