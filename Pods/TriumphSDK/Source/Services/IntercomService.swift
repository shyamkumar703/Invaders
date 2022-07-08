// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

// MARK: - Game Issues

extension IntercomService {
    func showGameIssue(title: String, id: String?) {
        if let id = id {
            showMessenger(
                with: "I would like to report an issue with my game \(title)\n\nID: \(id) \n"
            )
        } else {
            dependencies.logger.log("Intercom: \(title) Game ID is Nil", .warning)
            showMessenger(
                with: "I would like to report an issue in \(title)"
            )
        }
    }
}
