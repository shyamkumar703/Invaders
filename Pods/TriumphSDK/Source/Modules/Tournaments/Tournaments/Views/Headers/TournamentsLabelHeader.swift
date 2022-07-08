//
//  TournamentsLabelHeader.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/16/22.
//

import Foundation
import UIKit


struct TournamentsLabelHeaderViewModel {
    var title: String
    var tokenReward: Int?
}

class TournamentsLabelHeader: UITableViewHeaderFooterView {
    
    var viewModel: TournamentsLabelHeaderViewModel? {
        didSet {
            updateView()
        }
    }
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.spacing = 4
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(tokensLabel)
        return stack
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    lazy var tokensLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(stack)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            stack.leftAnchor.constraint(equalTo: leftAnchor),
            stack.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    func updateView() {
        titleLabel.text = viewModel?.title
        tokensLabel.attributedText = viewModel?.tokenReward?.formatTokens(
            attributes: [
                .foregroundColor: UIColor.grayish,
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
            ],
            additionalText: "when you play your first tournament"
        )
    }
}
