//
//  OtherGamesCollectionViewCell.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/16/22.
//

import Foundation
import UIKit
import SDWebImage

struct OtherGamesCollectionViewCellModel {
    var image: String
    var gameId: String
    var isCompleted: Bool
    var dependencies: AllDependencies
    var imageType: ImageType = .link
    
    var isCurrentGame: Bool {
        return gameId == dependencies.appInfo.id
    }
}

class OtherGamesCollectionViewCell: UICollectionViewCell {
    
    var viewModel: OtherGamesCollectionViewCellModel? {
        didSet {
            updateView()
        }
    }
        
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .tungsten
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
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
        layer.cornerRadius = 10
        
        addSubview(imageView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func updateView() {
        guard let viewModel = viewModel else { return }
        switch viewModel.imageType {
        case .link:
            imageView.sd_imageIndicator = SDWebImageActivityIndicator.white
            imageView.sd_setImage(with: URL(string: viewModel.image))
        case .local:
            Task { @MainActor [weak self] in
                self?.imageView.image = UIImage(named: viewModel.image)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
    }
}
