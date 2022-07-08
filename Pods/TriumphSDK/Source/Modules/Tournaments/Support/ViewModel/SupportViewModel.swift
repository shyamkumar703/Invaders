// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

enum SupportSection {
    case header(SupportCellViewModel)
    case primary([SupportCellViewModel])
    case profile(SupportCellViewModel)
    case faq(SupportFaqViewModel)
}

protocol SupportViewModelCoordinatorDelegate: Coordinator {
    func supportViewModelOpenProfile()
    func supportViewModel(
        _ viewModel: SupportViewModel,
        startLogout: @escaping () -> Void,
        finishedLogout: @escaping (Bool) -> Void
    )
}

protocol SupportViewModelViewDelegate: BaseViewModelViewDelegate { }

protocol SupportViewModel {
    var numberOfSections: Int { get }
    var viewDelegate: SupportViewModelViewDelegate? { get set }

    func getSection(at index: Int) -> SupportSection?
    func getNumberOfItems(at index: Int) -> Int
    func didSelectRowAt(_ index: Int, section: Int)
    func logout()
    func presentIntercomViewController()
    func markFaqMissionAsComplete() async
    func deleteAccount()
}

// MARK: - Impl.

final class SupportViewModelImplementation: SupportViewModel {

    private var dependencies: AllDependencies
    weak var coordinatorDelegate: SupportViewModelCoordinatorDelegate?
    weak var viewDelegate: SupportViewModelViewDelegate?
    
    init(dependencies: AllDependencies) {
        self.dependencies = dependencies
        prepareViewModels()
    }
    
    deinit {
        print("DEINIT \(self)")
    }

    var sections: [SupportSection] = []
    
    var numberOfSections: Int {
        sections.count
    }
}

extension SupportViewModelImplementation {

    func getSection(at index: Int) -> SupportSection? {
        sections.indices.contains(index) ? sections[index] : nil
    }
    
    func getNumberOfItems(at index: Int) -> Int {
        switch getSection(at: index) {
        case .header: return 1
        case .primary(let items): return items.count
        case .profile: return 1
        case .faq(let viewModel): return viewModel.numberOfItems
        default: return 0
        }
    }
    
    func prepareViewModels() {
        prepareHeaderSection()
        preparePrimarySection()
        prepareProfileSection()
        prepareFaqSection()
    }
    
    func prepareHeaderSection() {
        let model = SupportItemModel(
            title: localizedString(Content.Support.title),
            iconName: .concierge
        )
        let viewModel = SupportCellViewModelImplementation(
            model: model,
            dependencies: dependencies
        )
        sections.append(.header(viewModel))
    }
    
    func preparePrimarySection() {
        let items: [SupportCellViewModel] = Content.Support.primaryRows.map {
            let model = SupportItemModel(title: $0.0, subTitle: $0.1, iconName: .message)
            return SupportCellViewModelImplementation(model: model, dependencies: dependencies)
        }
        sections.append(.primary(items))
    }
    
    func prepareProfileSection() {
        let model = SupportItemModel(
            title: "Edit profile",
            subTitle: "Update your profile information",
            iconName: .profile
        )
        let viewModel = SupportCellViewModelImplementation(model: model, dependencies: dependencies)
        sections.append(.profile(viewModel))
    }
    
    func presentIntercomViewController() {
        dependencies.intercom.showMessenger()
    }
    
    func prepareFaqSection() {
        let viewModel = SupportFaqViewModelImplementation(dependencies: dependencies)
        sections.append(.faq(viewModel))
    }
    
    func didSelectRowAt(_ index: Int, section: Int) {
        switch getSection(at: section) {
        case .primary:
            presentIntercomViewController()
        case .profile:
            coordinatorDelegate?.supportViewModelOpenProfile()
        case .faq(let viewModel):
            viewModel.didSelectItemAt(index: index)
        default: return
        }
    }
    
    func markFaqMissionAsComplete() async {
        do {
            if let faqMission = await dependencies.session.missions.filter({ $0.id == "visitFaq" }).first {
                if !faqMission.isCompleted && faqMission.unlockedFor[dependencies.appInfo.id] != nil {
                    try await dependencies.session.markMissionAsComplete(missionId: "visitFaq")
                }
            }
        } catch {
            dependencies.logger.log(error.localizedDescription, .error)
        }
    }
    
    func deleteAccount() {
        dependencies.authentication.showDeleteAccountAlert { [weak self] isSuccess in
            DispatchQueue.main.async { [weak self] in
                self?.coordinatorDelegate?.didFinish()
            }
        }
    }
}

// MARK: - Localization

extension SupportViewModelImplementation {
    func localizedString(_ key: String) -> String {
        return dependencies.localization.localizedString(key)
    }
}

// MARK: - Logout

extension SupportViewModelImplementation {
    func logout() {
        self.coordinatorDelegate?.supportViewModel(self, startLogout: { [weak self] in
            self?.viewDelegate?.showLoadingProcess()
        }, finishedLogout: { [weak self] _ in
            self?.viewDelegate?.hideLoadingProcess()
        })
    }
}
