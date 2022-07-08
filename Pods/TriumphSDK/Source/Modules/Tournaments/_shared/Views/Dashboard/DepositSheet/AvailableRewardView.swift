//
//  AvailableRewardView.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/5/22.
//

import Foundation
import UIKit

class AvailableRewardView: UIView {
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        let text = NSMutableAttributedString(
            string: "Refer a friend 🤝\nYou'll get $5 when they sign up",
            attributes: [
                .foregroundColor: UIColor.darkGrayish,
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
            ]
        )
        text.setColorFor(text: "Refer a friend 🤝", color: .white, font: .systemFont(ofSize: 16, weight: .medium))
        text.setColorFor(text: "$5", color: .lightGreen, font: .systemFont(ofSize: 14, weight: .medium))
        label.attributedText = text
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Refer", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(referralTapped), for: .touchUpInside)
        return button
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
//        layer.borderColor = UIColor.white.cgColor
//        layer.borderWidth = 0.7
        
        addSubview(infoLabel)
        addSubview(actionButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            infoLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 80),
            actionButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            actionButton.leftAnchor.constraint(equalTo: infoLabel.rightAnchor, constant: 8)
        ])
    }
    
    @objc func referralTapped() {
        NotificationCenter.default.post(name: .respondToReferralFromDepositSheet, object: nil)
    }
}
