// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol MissionViewModel {
    var delegate: MissionsViewDelegate? { get set }
    var emoji: String? { get }
    var title: String? { get }
    var isLocked: Bool { get }
    var isCompleted: Bool { get }
    var incentiveAmount: Int? { get }
    var displayOrder: Int { get }
    var missionAction: MissionAction { get }
    var model: MissionModel { get }
    var description: String? { get }
    
    func generateClaimButtonTitle() -> String
    func generateRewardTitle() -> FlexibleString?
}

final class MissionViewModelImplementation: MissionViewModel {

    var model: MissionModel
    weak var delegate: MissionsViewDelegate?
    var dependencies: Dependencies?
    
    init(model: MissionModel) {
        self.model = model
    }
    
    var description: String? {
        model.description
    }
    
    var emoji: String? {
        model.emoji
    }
    
    var title: String? {
        model.title.capitalized
    }
    
    var isLocked: Bool {
        !(model.unlockedFor.keys.contains(dependencies?.appInfo.id ?? ""))
    }
    
    var isCompleted: Bool {
        model.isCompleted || model.completedFor.keys.contains(dependencies?.appInfo.id ?? "")
    }
    
    var incentiveAmount: Int? {
        model.incentiveAmount
    }
    
    var displayOrder: Int {
        model.displayOrder
    }
    
    var missionAction: MissionAction {
        MissionAction(rawValue: model.id) ?? .description
    }
    
    func generateClaimButtonTitle() -> String {
        return model.title.uppercased()
    }
    
    func generateRewardTitle() -> FlexibleString? {
        guard let incentiveAmount = incentiveAmount else {
            return nil
        }
        
        switch model.rewardType {
        case .money:
            return .string("Get \(incentiveAmount.formatCurrency())")
        case .tree:
            return .string("Plant Tree")
        case .token:
            let attrString = NSMutableAttributedString(string: "Get ")
            attrString.append(incentiveAmount.formatTokens())
            return .attributedString(attrString)
        }
    }
}
