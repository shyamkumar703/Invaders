//
//  TournamentsLiveMessageCell.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 4/4/22.
//

import UIKit

class TournamentsLiveMessageCell: UICollectionViewCell {
    
    var viewModel: TournamentsLiveCellViewModel? {
        didSet {
            viewModel?.viewDelegate = self
            if self.label.attributedText == nil {
                self.label.attributedText = self.viewModel?.initialMessage
            }
        }
    }
    
    private var liveLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.clipsToBounds = true
        label.text = "LIVE"
        return label
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .rounded(ofSize: 15, weight: .regular)
        label.textColor = .grayish
        label.textAlignment  = .right
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TournamentsLiveMessageCell {
    func setupView() {
//        backgroundColor = .lead
//        layer.cornerRadius = 10
        addSubview(liveLabel)
        addSubview(label)
    }
    
    func setupConstraints() {
        liveLabel.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            liveLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            liveLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            liveLabel.widthAnchor.constraint(equalToConstant: 48),
            
            label.leftAnchor.constraint(equalTo: liveLabel.rightAnchor, constant: 16),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

extension TournamentsLiveMessageCell: TournamentsLiveCellViewDelegate {
    func update(message: NSAttributedString) {
        // animate
        Task { @MainActor in
            UIView.transition(
                with: label,
                duration: 0.4,
                options: .transitionFlipFromBottom,
                animations: {
                    self.label.attributedText = message
                },
                completion: nil
            )
        }
    }
}
