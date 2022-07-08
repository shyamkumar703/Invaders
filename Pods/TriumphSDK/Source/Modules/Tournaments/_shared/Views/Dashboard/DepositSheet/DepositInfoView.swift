//
//  ReferralInfoView.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/5/22.
//

import Foundation
import UIKit

struct DepositInfoViewModel {
    var referrerFirstName: String
}

class DepositInfoView: UIView {
    
    var viewModel: DepositInfoViewModel? {
        didSet {
            updateView()
        }
    }
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
        label.textAlignment = .center
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
    
    func setupView() {
        backgroundColor = .clear
//        layer.cornerRadius = 8
//
//        layer.borderColor = UIColor.white.cgColor
//        layer.borderWidth = 0.7
        
        addSubview(infoLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            infoLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
            infoLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -4),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    func updateView() {
        if let referrerFirstName = viewModel?.referrerFirstName {
            let text = NSMutableAttributedString(
                string: "\(referrerFirstName) Referred You 🎉\n\nThey'll get a $5 bonus when you make your first deposit",
                attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .regular), .foregroundColor: UIColor.white]
            )
            text.setColorFor(text: "\(referrerFirstName) Referred You 🎉", color: .white, font: .systemFont(ofSize: 20, weight: .medium))
            text.setColorFor(text: "$5", color: .lightGreen)
            
            infoLabel.attributedText = text
        } else {
            let text = NSMutableAttributedString(
                string: "You Were Referred 🎉\n\nThey'll get a $5 bonus when you make your first deposit",
                attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .regular), .foregroundColor: UIColor.white]
            )
            text.setColorFor(text: "You Were Referred 🎉", color: .white, font: .systemFont(ofSize: 20, weight: .medium))
            text.setColorFor(text: "$5", color: .lightGreen)
            
            infoLabel.attributedText = text
        }
    }
}
