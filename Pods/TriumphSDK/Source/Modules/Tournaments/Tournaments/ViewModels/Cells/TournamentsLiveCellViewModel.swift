//
//  TournamentsLiveCellViewModel.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 4/4/22.
//

import Foundation
import TriumphCommon

protocol TournamentsLiveCellViewDelegate: AnyObject {
    func update(message: NSAttributedString)
}

protocol TournamentsLiveCellViewModel: TournamentsCellViewModel {
    var viewDelegate: TournamentsLiveCellViewDelegate? { get set }
    var loadingText: String { get }
    var initialMessage: NSAttributedString? { get }
    
    func beginScrollingLiveTicker()
}

final class TournamentsLiveCellViewModelImplementation: TournamentsCellViewModel {
    typealias Dependencies = HasSession & HasLocalization
    private var dependencies: Dependencies
    private var messages: [LiveMessage] = []
    private var timer: Timer?
    weak var viewDelegate: TournamentsLiveCellViewDelegate?
    private var currentIndex = -1
    var loadingText: String {
        localizedString(Content.LiveMessage.loading)
    }
    var initialMessage: NSAttributedString?
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(liveMessagesUpdated),
            name: .liveMessagesUpdated,
            object: nil
        )
        
        // note dependencies is a param no need to chain self?
        Task { [weak self] in
            self?.messages = await dependencies.session.liveMessages
            if let message = self?.messages.first {
                self?.currentIndex += 1
                self?.initialMessage = self?.generateAttributedString(message: message)
            }
            
        }
        beginScrollingLiveTicker()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .liveMessagesUpdated, object: nil)
        timer?.invalidate()
    }
    
    @objc func liveMessagesUpdated() {
        if timer == nil {
            refreshMessage()
            beginScrollingLiveTicker()
        }
    }
}

extension TournamentsLiveCellViewModelImplementation: TournamentsLiveCellViewModel {
    @objc func refreshMessage() {
        Task { [weak self] in
            let messages = await self?.dependencies.session.liveMessages
            if messages?.isEmpty == false {
                if let messages = messages {
                    let newIndex = (self?.currentIndex ?? 0) + 1 >= messages.count ? 0 : currentIndex + 1
                    if let message = self?.generateAttributedString(message: messages[newIndex]) {
                        self?.viewDelegate?.update(message: message)
                        self?.currentIndex = newIndex
                        self?.beginScrollingLiveTicker()
                    }
                }
                
            }
        }
    }
    
    func beginScrollingLiveTicker() {
        Task { [weak self] in
            let messages = await self?.dependencies.session.liveMessages
            if let messages = messages {
                guard !messages.isEmpty else { return }
                await MainActor.run { [weak self] in
                    self?.timer?.invalidate()
                    if let self = self {
                        timer = Timer.scheduledTimer(
                            timeInterval: 3,
                            target: self,
                            selector: #selector(refreshMessage),
                            userInfo: nil,
                            repeats: true
                        )
                    }
                }
            }
        }
    }
}

extension TournamentsLiveCellViewModelImplementation {
    func generateAttributedString(message: LiveMessage) -> NSAttributedString? {
        let name = message.name
        switch message.type {
        case .finishTournament:
            guard var tournamentName = message.tournamentName else { return nil }
            if let emoji = message.emoji {
                tournamentName += " \(emoji)"
            }
            return createAttributedString(message: message, name: name, action: "won", type: "in \(tournamentName)")
        case .hotStreakAward:
            return createAttributedString(message: message, name: name, action: "earned a", type: "hot streak award")
        case .finishBlitz:
            return createAttributedString(message: message, name: name, action: "won", type: "in blitz")
        case .referrerBonus:
            return createAttributedString(message: message, name: name, action: "earned a", type: "referral bonus")
        case .finishMission:
            guard let missionName = message.missionName,
                  let missionEmoji = message.missionEmoji else {
                      return nil
                  }
            return createAttributedString(
                message: message,
                name: name,
                action: "won",
                type: "from \(missionName.capitalized) \(missionEmoji)"
            )
        default:
            return nil
        }
    }
    
    private func createAttributedString(
        message: LiveMessage,
        name: String,
        action: String,
        type: String
    ) -> NSAttributedString {
        let moneyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor.lightGreen
        ]
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.grayish
        ]
        
        let attributedString1 = NSMutableAttributedString(
            string: "\(name) \(action) ",
            attributes: textAttributes
        )
        var attributedString2 = NSMutableAttributedString(
            string: "\(message.wonAmount.formatCurrency()) ",
            attributes: moneyAttributes
        )
        if let rewardType = message.rewardType,
           rewardType == "tree" {
            attributedString2 = NSMutableAttributedString(string: "\(message.wonAmount) 🌳", attributes: moneyAttributes)
        }
        if let rewardType = message.rewardType,
           rewardType == "token" {
            attributedString2 = NSMutableAttributedString(string: "\(message.wonAmount.formatTokens(tintColor: .lightGreen))", attributes: moneyAttributes)
        }
        let attributedString3 = NSMutableAttributedString(string: "\(type)", attributes: textAttributes)
        
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        
        return attributedString1
    }
}

private extension TournamentsLiveCellViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
