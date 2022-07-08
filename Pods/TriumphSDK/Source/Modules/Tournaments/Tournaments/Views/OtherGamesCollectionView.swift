//
//  OtherGamesCollectionView.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/16/22.
//

import UIKit
import TriumphCommon

fileprivate var cellId = "cell"

struct OtherGamesCollectionViewModel {
    var otherGame: OtherGame
    var dependencies: AllDependencies
    var imageType: ImageType = .link
}

class OtherGamesTableViewCell: UITableViewCell {
    var viewModels = [OtherGamesCollectionViewModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    weak var viewDelegate: OtherGamesViewDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
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
        layout.minimumLineSpacing = 16
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
    }
    
    func updateView() {
        Task { @MainActor [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension OtherGamesTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? OtherGamesCollectionViewCell {
//            cell.image = viewModels[indexPath.item].image
            cell.viewModel = OtherGamesCollectionViewCellModel(
                image: viewModels[indexPath.item].otherGame.image ?? "",
                gameId: viewModels[indexPath.item].otherGame.gameId,
                isCompleted: viewModels[indexPath.item].otherGame.isCompleted,
                dependencies: viewModels[indexPath.item].dependencies
            )
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if viewModels[indexPath.item].otherGame.isCompleted { return }
        viewDelegate?.respondToTap(model: viewModels[indexPath.item])
    }
}

extension OtherGamesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 160)
    }
}
