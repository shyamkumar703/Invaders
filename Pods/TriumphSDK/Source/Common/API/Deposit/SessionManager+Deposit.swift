// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

extension SessionManager {
    func getDepositDefinitions() async throws {
        let request = DepositDefinitionsRequest(gameId: dependencies.appInfo.id)
        depositDefinitions = try await dependencies.network.getData(request: request)
    }
}
