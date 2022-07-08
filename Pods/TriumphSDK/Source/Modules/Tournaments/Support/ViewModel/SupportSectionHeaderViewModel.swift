// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

protocol SupportSectionHeaderViewModelDelegate: AnyObject {
    func supportSectionHeaderButtonDidPress()
}

protocol SupportSectionHeaderViewModel {
    var delegate: SupportSectionHeaderViewModelDelegate? { get set }
    var title: String { get }
    var buttonTitle: String { get }
    var buttonIcon: BaseIcon { get }
    
    func buttonPressed()
}

// MARK: - Impl.

final class SupportSectionHeaderViewModelImplementation: SupportSectionHeaderViewModel {
    
    weak var delegate: SupportSectionHeaderViewModelDelegate?

    typealias Dependencies = HasLogger & HasLocalization
    private var dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    private var isShowAllPressed: Bool = false
    
    var title: String {
        localizedString(Content.Support.faqTitle)
    }
    
    var buttonTitle: String {
        let showAllTitle = commonLocalizedString("btn_show_all_title")
        let showLessTitle = commonLocalizedString("btn_show_less_title")
        let title = isShowAllPressed ? showLessTitle : showAllTitle
        return title + " "
    }
    
    var buttonIcon: BaseIcon {
        .arrowRight
    }
    
    func buttonPressed() {
        isShowAllPressed.toggle()
        delegate?.supportSectionHeaderButtonDidPress()
    }
}

// MARK: - Localization

extension SupportSectionHeaderViewModelImplementation {
    func localizedString(_ key: String) -> String {
        dependencies.localization.localizedString(key)
    }
    
    func commonLocalizedString(_ key: String) -> String {
        dependencies.localization.commonLocalizedString(key)
    }
}
