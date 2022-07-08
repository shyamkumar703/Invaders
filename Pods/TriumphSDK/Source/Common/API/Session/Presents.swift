// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

struct Presets: Codable, Sendable {
    var _tournamentDefinitions = [TournamentModel]()
    var tournamentDefinitions: [TournamentModel] {
        get {
            return _tournamentDefinitions
        }
        set {
            _tournamentDefinitions = newValue
                .filter { $0.archived == false }
                .sorted { $0.entryPrice ?? 0 < $1.entryPrice ?? 0 }
            NotificationCenter.default.post(name: .tournamentDefinitionsUpdated, object: nil)
        }
    }
}
