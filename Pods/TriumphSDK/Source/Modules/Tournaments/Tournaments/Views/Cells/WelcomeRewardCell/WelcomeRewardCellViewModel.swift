// Copyright © TriumphSDK. All rights reserved.

import Foundation

protocol WelcomeRewardCellViewModel: TournamentsCellViewModel {
    var title: String? { get }
    var subtitle: String? { get }
    var onClaimTapped: () -> Void { get set }
    
    func generateClaimButtonTitle() async -> NSAttributedString?
}

class WelcomeRewardCellViewModelImplementation: WelcomeRewardCellViewModel {
    var dependencies: AllDependencies?
    var title: String? {
        localizedString(Content.Tournaments.welcomeCellTitle)
    }
    var subtitle: String? {
        localizedString(Content.Tournaments.welcomeCellSubtitle)
    }
    
    var onClaimTapped: () -> Void = { return }
    
//    init(dependencies: AllDependencies?, coordinator: TournamentsCoordinator?) {
//        self.dependencies = dependencies
//        self.coordinator = coordinator
//    }
    
    init(dependencies: AllDependencies?) {
        self.dependencies = dependencies
//        self.coordinator = coordinator
    }
    
    func generateClaimButtonTitle() async -> NSAttributedString? {
        guard let unclaimedBalance = await dependencies?.sharedSession.user?.unclaimedBalance else {
            return nil
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold),
            .foregroundColor: UIColor.white
        ]
        return NSMutableAttributedString(
            string: "Claim \((Double(unclaimedBalance) / 100.0).formatCurrency())",
            attributes: attributes
        )
    }
}

// MARK: - Localization
extension WelcomeRewardCellViewModelImplementation {
    func localizedString(_ key: String) -> String? {
        return dependencies?.localization.localizedString(key)
    }
}
