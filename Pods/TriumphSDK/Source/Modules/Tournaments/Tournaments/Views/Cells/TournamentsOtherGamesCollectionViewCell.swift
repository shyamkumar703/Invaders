//
//  TournamentsOtherGamesCollectionViewCell.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 6/28/22.
//

import Foundation
import UIKit

fileprivate var cellId = "cell"

protocol TournamentsOtherGamesViewDelegate: AnyObject {
    var collectionView: UICollectionView { get }
}

class TournamentsOtherGamesCellViewModel: TournamentsCellViewModel {
    var items: [OtherGamesCollectionViewModel] = [] {
        didSet(old) {
            if old.isEmpty && !items.isEmpty {
                Task { @MainActor in
                    viewDelegate?.collectionView.reloadData()
                }
            }
        }
    }
    var dependencies: AllDependencies
    var coordinator: TournamentsCoordinator?
    weak var viewDelegate: TournamentsOtherGamesViewDelegate?
    
    init(dependencies: AllDependencies, coordinator: TournamentsCoordinator?) {
        self.dependencies = dependencies
        self.coordinator = coordinator
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(retrieveOtherGames),
            name: .didRetrieveOtherGames,
            object: nil
        )
    }
    
    @objc func retrieveOtherGames() {
        Task { @MainActor [weak self] in
            var items = await dependencies.session.otherGames
                .filter { $0.appStoreURL != nil && $0.image != nil && $0.gameId != dependencies.appInfo.id }
                .map({ OtherGamesCollectionViewModel(
                    otherGame: $0,
                    dependencies: dependencies,
                    imageType: $0.imageType ?? .link
                )
            })
            self?.items = items
        }
    }
    
    func linkTo(model: OtherGamesCollectionViewModel) {
        if model.otherGame.gameId != dependencies.appInfo.id && model.imageType == .link {
            if let urlScheme = model.otherGame.urlScheme, let url = URL(string: "\(urlScheme)://") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    return
                }
            }
            
            guard let appStoreURL = model.otherGame.appStoreURL else { return }
            coordinator?.openAppStoreURL(rawURL: appStoreURL)
        } else if model.imageType == .local {
            coordinator?.respondTo(action: .makeReferral, model: nil)
        }
    }
}

class TournamentsOtherGamesCollectionViewCell: UICollectionViewCell, TournamentsOtherGamesViewDelegate {
    
    var viewModel: TournamentsOtherGamesCellViewModel? {
        didSet {
            viewModel?.viewDelegate = self
            Task { @MainActor [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(OtherGamesCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alwaysBounceHorizontal = true
        layout.minimumLineSpacing = 16
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .clear
        contentView.addSubview(collectionView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

extension TournamentsOtherGamesCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? OtherGamesCollectionViewCell {
            if let viewModel = viewModel {
                cell.viewModel = OtherGamesCollectionViewCellModel(
                    image: viewModel.items[indexPath.item].otherGame.image ?? "",
                    gameId: viewModel.items[indexPath.item].otherGame.gameId,
                    isCompleted: viewModel.items[indexPath.item].otherGame.isCompleted,
                    dependencies: viewModel.dependencies,
                    imageType: viewModel.items[indexPath.item].imageType
                )
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let item = viewModel?.items[indexPath.item] {
            UIImpactFeedbackGenerator().impactOccurred(intensity: 1)
            viewModel?.linkTo(model: item)
        }
    }
}

extension TournamentsOtherGamesCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 160)
    }
}
