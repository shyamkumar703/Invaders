// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol SupportCellViewModel {
    var title: String { get }
    var subTitle: String? { get }
    var text: String? { get }
    var leftIcon: BaseIcon? { get }
    var isExpanded: Bool { get }
    
    func toggleExpanded()
    func setIsExpanded(_ isExpanded: Bool)
}

extension SupportCellViewModel {
    var rightIcon: BaseIcon? {
        .arrowRight
    }
}

// MARK: - Impl.

final class SupportCellViewModelImplementation: SupportCellViewModel {
    
    typealias Dependencies = HasLogger & HasLocalization
    private var dependencies: Dependencies
    private var model: SupportItemModel
    var isExpanded: Bool = false
    
    init(model: SupportItemModel, dependencies: Dependencies) {
        self.model = model
        self.dependencies = dependencies
    }
    
    var title: String {
        localizedString(model.title)
    }
    
    var subTitle: String? {
        guard let subtitle = model.subTitle else { return nil }
        return localizedString(subtitle)
    }

    var text: String? {
        if isExpanded == false { return nil }
        guard let text = model.text else { return nil }
        return localizedString(text)
    }
    
    var leftIcon: BaseIcon? {
        model.iconName
    }
    
    func toggleExpanded() {
        isExpanded.toggle()
    }
    
    func setIsExpanded(_ isExpanded: Bool) {
        self.isExpanded = isExpanded
    }
}

// MARK: - Localization

extension SupportCellViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
