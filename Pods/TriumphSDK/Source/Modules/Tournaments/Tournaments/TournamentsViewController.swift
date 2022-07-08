// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

@MainActor
final class TournamentsViewController: BaseViewController {
    
    var viewModel: TournamentsViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }

    lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCommon()
        setupCollectionView()
        viewModel?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTopNavButton(type: .close)
        setupRightTopNavButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopActivityIndicator()
        hideRightTopNavButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        leftTopBarButtonEnabled(true)
    }
}

// MARK: - Setup

private extension TournamentsViewController {
    func setupCommon() {
        view.backgroundColor = .black
    }
    
    func setupRightTopNavButton() {
        setupRightTopNavButton(type: .question)
        guard let navigationController = navigationController as? BaseNavigationController else { return }
        navigationController.viewDelegate = self
    }
}

// MARK: - Setup Collection View

private extension TournamentsViewController {
    func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        
        register()
        
        view.addSubview(collectionView)
        setupCollectionViewFlowLayout()
        setupCollectionViewConstrains()
    }
    
    func setupCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    func register() {
        collectionView.registerHeader(TournamentsGameHeader.self)
        collectionView.registerHeader(TournamentHistoryHeader.self)
        collectionView.registerCell(TournamentsDashboardCell.self)
        collectionView.registerCell(TournamentsBlitzCell.self)
        collectionView.registerCell(TournamentsVersusCell.self)
        collectionView.registerCell(TournamentHistoryCell.self)
        collectionView.registerCell(TournamentsMissionsCollectionViewCell.self)
        collectionView.registerCell(TournamentsWelcomeRewardCell.self)
        collectionView.registerCell(TournamentsLiveMessageCell.self)
        collectionView.registerCell(TournamentsOtherGamesCollectionViewCell.self)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
// swiftlint:disable line_length
extension TournamentsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat = CGFloat(viewModel?.getSectionHeight(at: section) ?? 0)
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = CGFloat(viewModel?.getCellHeight(at: indexPath.section) ?? 0)
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(viewModel?.getMinimumLineSpacingForSection(at: section) ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch viewModel?.getSection(at: section) {
        case .dashboard, .missions, .welcome:
            return UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension TournamentsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelectItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            switch viewModel?.getSection(at: indexPath.section) {
            case .dashboard:
                return prepareHeader(TournamentsGameHeader.self, for: indexPath, ofKind: kind)
            case .history(let viewModel):
                return prepareHeader(TournamentHistoryHeader.self, viewModel, for: indexPath, ofKind: kind)
            default:
                return UICollectionReusableView()
            }
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    private func prepareHeader<T: UICollectionReusableView>(
        _: T.Type,
        _ viewModel: TournamentsSectionViewModel? = nil,
        for indexPath: IndexPath,
        ofKind kind: String
    ) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.identifier,
            for: indexPath
        )
        
        switch view {
        case let header as TournamentsGameHeader:
            return header
        case let header as TournamentHistoryHeader:
            header.text = (viewModel as? TournamentsHistorySectionViewModel)?.title
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.numberOfSections ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.getNumberOfItems(at: section) ?? 0
    }

    private func dequeueReusableCell<T: UICollectionViewCell>(
        _: T.Type,
        _ viewModel: TournamentsCellViewModel?,
        for indexPath: IndexPath
    ) -> UICollectionViewCell {

        let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: T.identifier,
            for: indexPath
        )
        
        switch view {
        case let cell as TournamentsDashboardCell:
            cell.viewModel = viewModel as? TournamentsDashboardViewModel
            return cell
        case let cell as TournamentsBlitzCell:
            cell.viewModel = viewModel as? TournamentsBlitzCellViewModel
            return cell
        case let cell as TournamentsVersusCell:
            cell.viewModel = viewModel as? TournamentsVersusViewModel
            return cell
        case let cell as TournamentHistoryCell:
            cell.viewModel = viewModel as? TournamentsHistoryCellViewModel
            return cell
        case let cell as TournamentsMissionsCollectionViewCell:
            cell.viewModel = viewModel as? TournamentsMissionsCellViewModel
            return cell
        case let cell as TournamentsWelcomeRewardCell:
            cell.viewModel = viewModel as? WelcomeRewardCellViewModel
            return cell
        case let cell as TournamentsLiveMessageCell:
            cell.viewModel = viewModel as? TournamentsLiveCellViewModel
            return cell
        case let cell as TournamentsOtherGamesCollectionViewCell:
            cell.viewModel = viewModel as? TournamentsOtherGamesCellViewModel
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel?.getSection(at: indexPath.section) {
        case .dashboard(let viewModel):
            return dequeueReusableCell(TournamentsDashboardCell.self, viewModel, for: indexPath)
        case .blitz(let viewModel):
            return dequeueReusableCell(TournamentsBlitzCell.self, viewModel, for: indexPath)
        case .tournaments(let viewModel):
            return dequeueReusableCell(TournamentsVersusCell.self, viewModel.prepareViewModel(for: indexPath.row), for: indexPath)
        case .history(let viewModel):
            let cell = dequeueReusableCell(TournamentHistoryCell.self, viewModel.prepareViewModel(for: indexPath.row), for: indexPath)
            configureBorderedCell(cell, at: indexPath)
            return cell
        case .missions(let viewModel):
            let cell = dequeueReusableCell(TournamentsMissionsCollectionViewCell.self, viewModel, for: indexPath)
            return cell
        case .welcome(let viewModel):
            return dequeueReusableCell(TournamentsWelcomeRewardCell.self, viewModel, for: indexPath)
        case .liveMessage(let viewModel):
            return dequeueReusableCell(TournamentsLiveMessageCell.self, viewModel, for: indexPath)
        case .otherGames(let viewModel):
            return dequeueReusableCell(TournamentsOtherGamesCollectionViewCell.self, viewModel, for: indexPath)
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch viewModel?.getSection(at: indexPath.section) {
        case .liveMessage(let viewModel):
            viewModel.beginScrollingLiveTicker()
        default:
            return
        }
    }
    
    private func configureBorderedCell(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
        let numberOfRows = collectionView.numberOfItems(inSection: indexPath.section)
        if cell.frame.minX == 0 {
            cell.frame = cell.frame.insetBy(dx: 20, dy: -0)
        }
        cell.layer.borderColor = UIColor.tungsten.cgColor
        cell.layer.borderWidth = 1
        cell.layer.maskedCorners = []
        cell.layer.cornerRadius = 10
        
        if numberOfRows == 1 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            return
        }
        
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        if numberOfRows > 1 && indexPath.row == numberOfRows - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}

// MARK: - TournamentsViewModelViewDelegate

extension TournamentsViewController: TournamentsViewModelViewDelegate {
    func showLoadingProcess() {
        startActivityIndicator()
        leftTopBarButtonEnabled(false)
        rightTopBarButtonEnabled(false)
    }
    
    func showLoadingProcess(with message: String?) {
        startActivityIndicator(with: message)
        leftTopBarButtonEnabled(false)
        rightTopBarButtonEnabled(false)
    }
    
    func hideLoadingProcess() {
        stopActivityIndicator()
        leftTopBarButtonEnabled(true)
        rightTopBarButtonEnabled(true)
    }
    
    func tournamentsReload() {
        Task { @MainActor [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - Constrains

private extension TournamentsViewController {
    func setupCollectionViewConstrains() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - BaseNavigationControllerViewDelegate

extension TournamentsViewController: BaseNavigationControllerViewDelegate {
    func baseNavigationControllerTopBarButtonDidPress(senderType: BaseTopBarButtonType) {
        if senderType == .question {
            viewModel?.supportButtonTap()
        }
    }
}
