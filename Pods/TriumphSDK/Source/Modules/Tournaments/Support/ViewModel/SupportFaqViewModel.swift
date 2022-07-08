//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation
import TriumphCommon

protocol SupportFaqViewModelViewDelegate: AnyObject {
    func supportFaqShowAllDidPress()
}

protocol SupportFaqViewModel {
    var viewDelegate: SupportFaqViewModelViewDelegate? { get set }
    var title: String { get }
    var items: [SupportCellViewModel] { get }
    var headerViewModel: SupportSectionHeaderViewModel { get }

    func prepareViewModel(for index: Int) -> SupportCellViewModel?
    func didSelectItemAt(index: Int)
}

extension SupportFaqViewModel {
    var numberOfItems: Int {
        items.count
    }
    
    func prepareViewModel(for index: Int) -> SupportCellViewModel? {
        return items.indices.contains(index) ? items[index] : nil
    }

    func didSelectItemAt(index: Int) {
        items[index].toggleExpanded()
    }
}

// MARK: Impl.

final class SupportFaqViewModelImplementation: SupportFaqViewModel {
    
    weak var viewDelegate: SupportFaqViewModelViewDelegate?
    
    typealias Dependencies = HasLogger & HasLocalization
    private var dependencies: Dependencies
    private var isAllExpanded: Bool = false
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    var title: String {
        localizedString(Content.Support.faqTitle)
    }

    lazy var headerViewModel: SupportSectionHeaderViewModel = {
        let viewModel = SupportSectionHeaderViewModelImplementation(dependencies: dependencies)
        viewModel.delegate = self
        return viewModel
    }()
    
    lazy var items: [SupportCellViewModel] = {
        Content.Support.questions.map {
            let model = SupportItemModel(title: $0.0, text: $0.1, iconName: .checkmarkLarge)
            return SupportCellViewModelImplementation(model: model, dependencies: dependencies)
        }
    }()
}

// MARK: - SupportSectionHeaderViewModelDelegate

extension SupportFaqViewModelImplementation: SupportSectionHeaderViewModelDelegate {
    func supportSectionHeaderButtonDidPress() {
        viewDelegate?.supportFaqShowAllDidPress()
        isAllExpanded.toggle()

        items.forEach { $0.setIsExpanded(isAllExpanded) }
    }
}

// MARK: - Localization

extension SupportFaqViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}
