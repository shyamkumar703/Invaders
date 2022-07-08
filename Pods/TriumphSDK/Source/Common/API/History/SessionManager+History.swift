// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

public typealias SplitedByDateHistoryDict = [String: [HistoryModel]]

extension SessionManager {
    func observeHistory() {
        observeGameHistory()
        observeDepositHistory()
    }

    private func observeGameHistory() {
        observeTournamentsHistory()
        observeBlitzHistory()
    }

    private func observeTournamentsHistory() {
        guard let uid = currentUserId else {
            dependencies.logger.log("User ID is Nil", .error)
            return
        }
        let request = TournamentsHistoryRequest(
            userId: uid,
            gameId: dependencies.appInfo.id
        )
        dependencies.network.listenCollection(request: request) { result in
            switch result {
            case .success(let output):
                output.forEach { self.gameHistory.update(with: GameHistoryModel(tournament: $0)) }
                self.allGamesHistory = Array(self.gameHistory)
                self.prepareHistorySplitedModels()
            case .failure(let error):
                self.dependencies.logger.log(error.message, .warning)
            }
        }
    }

    private func observeBlitzHistory() {
        guard let uid = currentUserId else {
            dependencies.logger.log("User ID is Nil", .error)
            return
        }
        let request = BlitzHistoryRequest(
            userId: uid,
            gameId: dependencies.appInfo.id
        )
        dependencies.network.listenCollection(request: request) { result in
            switch result {
            case .success(let output):
                output.forEach { self.gameHistory.update(with: GameHistoryModel(blitz: $0)) }
                self.allGamesHistory = Array(self.gameHistory)
                self.prepareHistorySplitedModels()
            case .failure(let error):
                self.dependencies.logger.log(error.message, .warning)
            }
        }
    }

    private func observeDepositHistory() {
        guard let uid = currentUserId else {
            dependencies.logger.log("User ID is Nil", .error)
            return
        }
        let request = DepositHistoryRequest(id: uid)
        dependencies.network.listenCollection(request: request) { result in
            switch result {
            case .success(let output):
                self.allDepositHistory = output
            case .failure(let error):
                self.dependencies.logger.log(error.message, .warning)
            }
            self.prepareHistorySplitedModels()
        }
    }

    nonisolated private func titleFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL d"
        return dateFormatter.string(from: date)
    }

    // This Function take the games history and the deposit history and coalesces them
    func prepareHistorySplitedModels() {
        Task { [weak self] in
            var historySplitedDict = SplitedByDateHistoryDict()
            var gameHistorySplited = [String: [HistoryModel]]()
            await self?.allGamesHistory.forEach {
                if let title = self?.titleFromDate($0.date){
                    gameHistorySplited[title, default: []].append($0)
                }

            }
            historySplitedDict.merge(dict: gameHistorySplited)
            var despositHistorySplited = [String: [HistoryModel]]()
            await self?.allDepositHistory
                .filter {
                    $0.type == .deposit
                    || $0.type == .hotStreakAward
                    || $0.type == .accountCreationDeposit
                    || $0.type == .finishMission
                    || $0.type == .referral
                    || $0.type == .newGame
                }
                .forEach {
                    if let title = self?.titleFromDate($0.date){
                        despositHistorySplited[title, default: []].append($0)
                    }
                }
            historySplitedDict.merge(dict: despositHistorySplited)
            await self?.dependencies.logger.log("History has been updated")
            NotificationCenter.default.post(name: .historyUpdate, object: historySplitedDict)
        }
    }
}
