// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

enum HistoryCellType {
    case deposit
    case accountCreationDeposit
    case hotStreak
    case game
    case mission
    case referral
    case newGame
}

protocol TournamentsHistoryCellViewModel: TournamentsCellViewModel {
    var title: String { get }
    var gameType: GameHistoryModel.GameType { get }
    var id: String? { get }
    var state: GameHistoryModel.HistoryState { get }
    var resultTitle: FlexibleString? { get }
    var resultDescription: String? { get }
    var resultStatus: GameHistoryModel.ResultStatus? { get }
    var type: HistoryCellType { get }
    var model: HistoryModel { get }
    
    func getHistoryModel<T: HistoryModel>(ofType: T.Type) -> T?
}

// MARK: - Impl.

final class TournamentsHistoryCellViewModelImplementation: TournamentsHistoryCellViewModel {
    private var dependencies: AllDependencies
    var model: HistoryModel
    
    var type: HistoryCellType = .game

    init(model: HistoryModel, dependencies: AllDependencies) {
        self.model = model
        self.dependencies = dependencies
        
        if let depositModel = model as? DepositHistoryModel {
            if depositModel.type == .hotStreakAward {
                type = .hotStreak
            } else if depositModel.type == .accountCreationDeposit {
                type = .accountCreationDeposit
            } else if depositModel.type == .finishMission {
                type = .mission
            } else if depositModel.type == .referral {
                type = .referral
            } else if depositModel.type == .newGame {
                type = .newGame
            } else {
                type = .deposit
            }
        }
        
        if model as? GameHistoryModel != nil {
            type = .game
        }
    }
    
    var resultStatus: GameHistoryModel.ResultStatus? {
        if let model = self.model as? DepositHistoryModel {
            if model.type != .newGame {
                if model.amount > 0 || (model.tokenAmount ?? 0) > 0 {
                    return .won
                } else {
                    return .lost
                }
            } else {
                if (model.tokenAmount ?? 0) > 0 {
                    return .won
                } else {
                    return .lost
                }
            }
        }
        
        if let model = self.model as? GameHistoryModel {
            return model.resultStatus
        }
        
        return nil
    }

    var gameType: GameHistoryModel.GameType {
        if let model = self.model as? GameHistoryModel {
            return model.gameType
        }
        
        return .versus
    }

    var title: String {
        if let model = self.model as? GameHistoryModel {
            return prepareGameHistoryTitle(model: model)
        }
        
        if let model = self.model as? DepositHistoryModel {
            if model.type == .hotStreakAward {
                return "Hot Streak 🔥"
            }
            if model.type == .accountCreationDeposit {
                return "Welcome 👋"
            }
            if model.type == .finishMission {
                if let name = model.missionName,
                   let emoji = model.missionEmoji {
                    return "\(name.capitalized) \(emoji)"
                }
            }
            if model.type == .referral {
                return "Referral 🤝"
            }
            if model.type == .newGame {
                return "New Game 🎉"
            }
            return "Deposit 💸"
        }
        
        return ""
    }
    
    func prepareGameHistoryTitle(model: GameHistoryModel) -> String {
        switch model.gameType {
        case .versus:
            if let title = model.tournamentConfig?.gameTitleWithEmoji, title.isEmpty == false {
                return title
            }
        case .blitz:
            if let title = model.blitzConfig?.tournamentDefinition?.entryPrice?.formatCurrency(), title.isEmpty == false {
                return "\(title) Blitz ⚡️"
            }
        }
        return "Tournament"
    }
    
    var state: GameHistoryModel.HistoryState {
        if let model = self.model as? GameHistoryModel {
            return model.state
        }
        
        return .result
    }
    
    var id: String? {
        model.id
    }
    
    var resultTitle: FlexibleString? {
        
        if let model = self.model as? DepositHistoryModel {
            return prepareDespositResultTitle(model: model)
        }
        
        if let model = self.model as? GameHistoryModel {
            switch state {
            case .result:
                return .string(prepareResultTitle(model: model) ?? "")
            case .done:
                return .string("View results")
            default:
                return nil
            }
        }
        
        return nil
    }
    
    private func prepareDespositResultTitle(model: DepositHistoryModel) -> FlexibleString? {
        if let rewardType = model.rewardType {
            if rewardType == .tree {
                return .string("+ \(Int(model.rawAmount)) 🌳")
            } else if rewardType == .token {
                if let tokenAmount = model.tokenAmount {
                    let attrString = NSMutableAttributedString(string: "+ ")
                    attrString.append(tokenAmount.formatTokens(tintColor: .lightGreen))
                    return .attributedString(attrString)
                }
            }
        }
        if let tokenAmount = model.tokenAmount,
           model.type == .newGame || model.type == .hotStreakAward {
            let attrString = NSMutableAttributedString(string: "+ ")
            attrString.append(tokenAmount.formatTokens(tintColor: .lightGreen))
            return .attributedString(attrString)
        }
        if model.amount > 0 {
            return .string("+ \(model.amount.formatCurrency())")
        } else {
            return .string("- \(abs(model.amount).formatCurrency())") 
        }
    }
    
    private func prepareResultTitle(model: GameHistoryModel) -> String? {
        switch model.gameType {
        case .versus:
            return prepareResultVersusTitle(model: model)
        case .blitz:
            return "+ \((model.wonAmount / 100.0).formatCurrency())"
        }
    }
    
    private func prepareResultVersusTitle(model: GameHistoryModel) -> String? {
        switch model.resultStatus {
        case .draw:
            return "Draw"
        case .lost:
            return "You Lost"
        case .won:
            return "+ \((Double(model.tournamentConfig?.prize ?? 0 ) / 100.0).formatCurrency())"
        default: return nil
        }
    }
    
    var resultDescription: String? {
        if let model = self.model as? GameHistoryModel {
            return prepareGameHistoryDescription(model: model)
        }
        
        // It's using only two: Deposit and Hot streak award
        if let model = self.model as? DepositHistoryModel {
            switch model.type {
            case .finishBlitz: return "finish Blitz"
            case .startBlitz: return "start Blitz"
            case .finishTournament: return "finish tournament"
            case .startTournament: return "start tournament"
            case .deposit: return "Deposit"
            case .withdrawal: return "withdrawal"
            case .withdrawalRedeposit: return "withdrawal redeposit"
            case .finishMission, .referral, .accountCreationDeposit, .hotStreakAward, .newGame: return "Mission"
            default: return ""
            }
        }
        
        return nil
    }
    
    func prepareGameHistoryDescription(model: GameHistoryModel) -> String? {
        switch state {
        case .waiting:
            return "Waiting..."
        case .result:
            if model.gameType == .blitz { return "vs Blitz" }
            return "vs \(model.opponent?.username ?? "Unknown")"
        default: return nil
        }
    }
    
    // Used only for SwiftMessage when mission cell is tapped
    func getHistoryModel<T: HistoryModel>(ofType: T.Type) -> T? {
        return model as? T
    }
}

// MARK: - Localization

extension TournamentsHistoryCellViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
