// Copyright © TriumphSDK. All rights reserved.

import Foundation

// MARK: - View Model

protocol MatchingPlayersViewModel {
    var vsTitle: String { get }
    var userNameTitle: String { get }
    var opponentNameTitle: String { get }
    var userpicUrl: URL? { get async }
    var opponentImageUrl: URL? { get }
    var isGameMatched: Bool { get }
}

// MARK: - Implementation

final class MatchingPlayersViewModelImplementation: MatchingPlayersViewModel {

    private var dependencies: AllDependencies
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
    }
    
    var vsTitle: String {
        localizedString(Content.Matching.vcTitle)
    }
    
    var userNameTitle: String {
        "You"
    }
    
    var opponentNameTitle: String {
        dependencies.game.opponent?.username ?? "Searching..."
    }
    
    var userpicUrl: URL? {
        get async {
            guard let urlString = await dependencies.sharedSession.userPublicInfo?.profilePhotoURL else { return nil }
            return URL(string: urlString)
        }
    }
    
    var opponentImageUrl: URL? {
        guard let urlString = dependencies.game.opponent?.userpic else { return nil }
        return URL(string: urlString)
    }
    
    var isGameMatched: Bool {
        return opponentImageUrl != nil
    }
}

// MARK: - Localization

extension MatchingPlayersViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
