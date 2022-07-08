// Copyright © TriumphSDK. All rights reserved.

import UIKit

public class NoDataView: UIView {
    private lazy var placeholerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 45,
            weight: .regular,
            scale: .default
        )
        imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 21, weight: .regular)
        label.numberOfLines = 1
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var subTitle: String? {
        didSet {
            subTitleLabel.text = subTitle
        }
    }
    
    public var image: UIImage? {
        didSet {
            placeholerImageView.image = image
        }
    }
    
    public init(model: NoDataModel) {
        super.init(frame: .zero)
        setupCommon()
        setupViews()
        
        titleLabel.text = model.title
        subTitleLabel.text = model.subTitle
        placeholerImageView.image = UIImage(systemName: model.image)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension NoDataView {
    func setupCommon() {
        
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(placeholerImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subTitleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 40),
            subTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -40),
            
            placeholerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholerImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20)
        ])
    }
}
