// Copyright © TriumphSDK. All rights reserved.

import Foundation

public enum ApplicationType {
    case app(String)
    case game(String)
    
    var path: String {
        switch self {
        case .app(let id):
            return "appConfig/\(id)"
        case .game(let id):
            return "games/\(id)"
        }
    }
}
