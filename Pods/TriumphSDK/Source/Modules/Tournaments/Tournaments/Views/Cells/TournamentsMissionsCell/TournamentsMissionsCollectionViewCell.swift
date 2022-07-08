// Copyright © TriumphSDK. All rights reserved.

import AVFoundation
import UIKit

fileprivate var cellId: String = "missionCell"

@MainActor
final class TournamentsMissionsCollectionViewCell: UICollectionViewCell {
    
    var viewModel: TournamentsMissionsCellViewModel?
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        
        stack.addArrangedSubview(referrralLabel)
        stack.addArrangedSubview(moreGamesLabel)
        return stack
    }()
    
    lazy var referrralLabel: UILabel = {
        // 24, 17
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.backgroundColor = UIColor(red:0.50, green:0.55, blue:0.91, alpha:1.0)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        
        let largeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let smallAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        
        let attrString = NSMutableAttributedString(string: "REFERRAL\n", attributes: largeAttributes)
        attrString.append(NSAttributedString(string: "$5 bonus", attributes: smallAttributes))
        label.attributedText = attrString
        
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(referralTapped))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    lazy var moreGamesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.backgroundColor = .greenish
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "MORE\nGAMES"
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moreGamesTapped))
        label.addGestureRecognizer(tapGesture)
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

extension TournamentsMissionsCollectionViewCell {
    func setupView() {
        contentView.addSubview(stack)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            stack.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    @objc func referralTapped() {
        viewModel?.referralButtonTapped()
    }
    
    @objc func moreGamesTapped() {
        viewModel?.moreGamesTapped()
    }
}
