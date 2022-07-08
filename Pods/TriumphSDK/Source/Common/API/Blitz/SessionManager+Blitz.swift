// Copyright © TriumphSDK. All rights reserved.
// Documentation April 11 2022 Henry Boswell

import Foundation
import TriumphCommon

enum BlitzError: Error {
    case blitzResponseIsNil
}

extension Session {
    func buyIntoGame(blitz config: BlitzModel) async throws -> BlitzResponse {
        let definitionID = blitzDefinitions.filter({ $0.entryPrice ?? 0 == Int(config.entryPrice * 100) }).first?.id
        guard let definitionID = definitionID,
              let seed = GameManager.getRandomSeedIntegerRaw(),
              let multipliers = config.multipliers else {
            throw BlitzError.blitzResponseIsNil
        }
        
        var multipliersTuples: [BlitzMultiplier] = []
        for (key, value) in multipliers { multipliersTuples.append(BlitzMultiplier(multiple: value, score: key)) }
        
        let query = BlitzModeQuery(tournamentDefinitionId: definitionID, blitzMultipliers: multipliersTuples, seed: Int(seed))
        
        let request = BlitzModeRequest(query: query)
        guard let response = try await dependencies.secure.call(request: request) else {
            throw BlitzError.blitzResponseIsNil
        }
        return response
    }
    
    func submitBlitzScore(_ score: Double, buyIn: Int, payout: Int, tournamentId: String?) async throws {
        let query = SubmitBlitzScoreQuery(
            score: score,
            tournamentId: tournamentId
        )
        
        let request = SubmitBlitzScoreRequest(query: query)
        try await dependencies.secure.call(request: request)
    }
    
    func getBlitzDataPoints() async throws -> [BlitzDataPointResponse] {
        let request = BlitzDataPointsRequest(id: dependencies.appInfo.id)
        return try await dependencies.network.getData(request: request)
    }
    
    func observeBlitzDataPoints(completion: @escaping ([BlitzDataPointResponse]) -> Void) {
        let request = BlitzDataPointsRequest(id: dependencies.appInfo.id)
        
        dependencies.network.listenCollection(request: request) { result in
            switch result {
            case .success(let output):
                completion(output)
            case .failure(let error):
                self.dependencies.logger.log(error.message, .error)
            }
        }
    }
    
    func getBlitzDefinitions() async throws {
        let request = BlitzDefinitionsRequest(id: dependencies.appInfo.id)
        let definitions = try await dependencies.network.getData(request: request)
        self.blitzDefinitions = definitions.filter { !$0.archived }
    }
    
    func removeBlitzListener() async {
        await dependencies.network.removeListener(path: "games/\(dependencies.appInfo.id)/blitzMultipliersV2")
    }
}
