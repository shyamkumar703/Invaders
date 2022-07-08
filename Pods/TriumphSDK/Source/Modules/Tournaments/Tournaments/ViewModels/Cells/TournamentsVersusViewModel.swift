// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol TournamentsVersusCellViewDelegate: AnyObject {
    func updatePriceAndTokens()
}

protocol TournamentsVersusViewModelDelegate: AnyObject {
    func tournamentsItemPlayDidPress(_ tournament: TournamentModel)
    func depositAmountWithAuthentication(amount: Double)
}

protocol TournamentsVersusViewModel: TournamentsCellViewModel {
    var prizePoolTitle: String { get }
    var prizePoolValue: String { get }
    var versusTitle: String { get }
    var entryTitle: String { get }
    var emoji: String? { get }
    var cellViewDelegate: TournamentsVersusCellViewDelegate? { get set }
    var maxTokensTitle: NSMutableAttributedString { get }
    
    func playPressed()
    func depositMoney(amount: Double)
}

final class TournamentsVersusViewModelImplementation: TournamentsVersusViewModel {
    
    private var tournamentModel: TournamentModel
    private var dependencies: HasLocalization & HasLocalStorage
    weak var delegate: TournamentsVersusViewModelDelegate?
    weak var viewDelegate: TournamentsVersusSectionViewModelViewDelegate?
    weak var cellViewDelegate: TournamentsVersusCellViewDelegate?

    init(
        tournamentModel: TournamentModel,
        dependencies: Dependencies,
        viewDelegate: TournamentsVersusSectionViewModelViewDelegate?
    ) {
        self.tournamentModel = tournamentModel
        self.dependencies = dependencies
        self.viewDelegate = viewDelegate
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tokensUpdated),
            name: .tokenBalanceUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .tokenBalanceUpdated, object: nil)
    }
    
    lazy var tokens: Int = {
        dependencies.localStorage.readUser()?.tokenBalance ?? 0
    }()
    
    var emoji: String? {
        tournamentModel.emoji
    }
    
    var prizePoolTitle: String {
        localizedString(Content.Tournaments.prizePool)
    }

    var prizePoolValue: String {
        tournamentModel.totalPrice.formatCurrency()
    }
    
    var versusTitle: String {
        tournamentModel.gameTitle
    }
    
    var entryTitle: String {
        switch tournamentModel.entryType {
        case .priceEntry:
            guard let entryPrice = tournamentModel.entryPrice else { return "–" }
            let entry = entryPrice
            return entry == 0 ? "Play Free" : "Play \(tournamentModel.getPriceAfterTokens(tokens: tokens).formatCurrency())"
        }
    }
    
    var maxTokensTitle: NSMutableAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "token")?.withTintColor(.grayish)
        switch tournamentModel.entryType {
        case .priceEntry:
            guard let entryPrice = tournamentModel.entryPrice,
                  entryPrice != 0,
                  tournamentModel.maxTokensToUse(tokens: tokens) != 0 else {
                let fullString = NSMutableAttributedString(string: "Using 0 ")
                fullString.append(NSAttributedString(attachment: imageAttachment))
                return fullString
            }
            let maxTokensToUse = tournamentModel.maxTokensToUse(tokens: tokens)
            let fullString = NSMutableAttributedString(string: "Using \(maxTokensToUse) ")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            return fullString
        }
    }
    
    func playPressed() {
        delegate?.tournamentsItemPlayDidPress(tournamentModel)
    }

    func depositMoney(amount: Double) {
        delegate?.depositAmountWithAuthentication(amount: amount)
    }
    
    @objc func tokensUpdated(_ notification: Notification) {
        if let tokens = notification.userInfo?["balance"] as? Int {
            self.tokens = tokens
            cellViewDelegate?.updatePriceAndTokens()
        }
    }
}

// MARK: - Localization

extension TournamentsVersusViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
