// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

enum TournamentVersusError: SessionErrorProtocol {
    case noTournamentId
    case tournamentResponseIsNil
    
    var message: String {
        switch self {
        case .noTournamentId:
            return "Tournament should have id, but got nil"
        case .tournamentResponseIsNil:
            return "Tournament response is nil"
        }
    }
}

extension SessionManager {
    func buyIntoGame(tournament config: TournamentModel) async throws -> TournamentVersus {
        guard let tournamentId = config.id else {
            throw TournamentVersusError.noTournamentId
        }
        
        let query = TournamentBuyIntoGameQuery(
            game: dependencies.appInfo.id,
            config: config,
            configId: tournamentId
        )
        
        let request = TournamentBuyIntoGameRequest(query: query)
        guard var response = try await dependencies.network.call(request: request) else {
            throw TournamentVersusError.tournamentResponseIsNil
        }
        
        try await updateTorunamentResponseWithUserPublicInfo(response: &response)
        
        dependencies.logger.log(response.dictionary ?? [:], .success)
        return response
    }
    
    func submitVersusScore(_ score: Double, tournamentId: String) async throws -> TournamentVersus {
        let query = TournamentSubmitScoreQuery(
            game: dependencies.appInfo.id,
            score: score,
            tournamentId: tournamentId
        )
        
        let request = TournamentSubmitScoreRequest(query: query)
        guard var response = try await dependencies.network.call(request: request) else {
            throw TournamentVersusError.tournamentResponseIsNil
        }
        
        try await updateTorunamentResponseWithUserPublicInfo(response: &response)
        
        dependencies.logger.log("Score \(score) has been submited for tournament id: \(tournamentId)", .success)

        return response
    }
    
    private func updateTorunamentResponseWithUserPublicInfo(response: inout TournamentVersus) async throws {
        if let player1Uid = response.tournament?.player1.uid {
            let publicInfo = try await dependencies.sharedSession.getUserPublicInfo(from: player1Uid)
            response.tournament?.player1.userpic = publicInfo.profilePhotoURL
            response.tournament?.player1.username = publicInfo.username
        }
        
        if let player2Uid = response.tournament?.player2?.uid {
            let publicInfo = try await dependencies.sharedSession.getUserPublicInfo(from: player2Uid)
            response.tournament?.player2?.userpic = publicInfo.profilePhotoURL
            response.tournament?.player2?.username = publicInfo.username
        }
    }
    
    func getTournament(with id: String) async throws -> TournamentData {
        let request = TournamentVersusRequest(gameId: dependencies.appInfo.id, tournamentId: id)
        guard var response = try await dependencies.network.getData(request: request) else {
            throw TournamentVersusError.tournamentResponseIsNil
        }
        
        let publicInfo = try await dependencies.sharedSession.getUserPublicInfo(from: response.player1.uid)
        response.player1.userpic = publicInfo.profilePhotoURL
        response.player1.username = publicInfo.username
        
        if let player2Uid = response.player2?.uid {
            let publicInfo = try await dependencies.sharedSession.getUserPublicInfo(from: player2Uid)
            response.player2?.userpic = publicInfo.profilePhotoURL
            response.player2?.username = publicInfo.username
        }
        
        return response
    }
    
    func getGameHistory(with tournamentId: String) async -> GameHistoryModel? {
        do {
            let tournament = try await getTournament(with: tournamentId)
            return GameHistoryModel(tournament: tournament)
        } catch let error {
            dependencies.logger.log(error.localizedDescription, .error)
            return nil
        }
    }
}
