//
//  TutorialBabyCell.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/26/22.
//

import Foundation
import UIKit

protocol BabyCellDelegate {
    func playTapped()
}

class TutorialBabyCell: UIView {
    
    var delegate: BabyCellDelegate?
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Apple Color Emoji", size: 48)
        label.text = "👶"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var itemViewStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        
        stack.addArrangedSubview(infoViewStack)
        stack.addArrangedSubview(playButtonView)
        return stack
    }()
    
    private lazy var infoViewStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.spacing  = 4
        stack.addArrangedSubview(tournamentNameLabel)
        stack.addArrangedSubview(tournamentPrizeLabel)
        return stack
    }()
    
    private lazy var tournamentNameLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(ofSize: 16, weight: .regular)
        label.textColor = .white
        label.text = "Baby"
        return label
    }()
    
    private lazy var tournamentPrizeLabel: UILabel = {
        let label = UILabel()
        label.font = .rounded(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.text = "Win $1"
        return label
    }()
    
    private lazy var playButtonView: UIView = {
        let outerView = UIView()
        return outerView
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Play \(60.formatCurrency())", for: .normal)
        button.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1)
        button.layer.doGlowAnimation(withColor: #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1), from: 2, to: 6)
        
        if #available(iOS 15.0, *) {
            button.configuration = .plain()
            button.configuration?.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 20,
                bottom: 8,
                trailing: 20
            )
        } else {
            // Fallback on earlier versions
            button.titleEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        }
        
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
        layer.cornerRadius = 10
        backgroundColor = .lead
        
        addSubview(emojiLabel)
        addSubview(itemViewStack)
        playButtonView.addSubview(playButton)
        playButton.layer.cornerRadius = 6
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            
            itemViewStack.topAnchor.constraint(equalTo: emojiLabel.topAnchor, constant: 8),
            itemViewStack.leftAnchor.constraint(equalTo: emojiLabel.rightAnchor, constant: 8),
            itemViewStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            itemViewStack.bottomAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: -8),
            
            playButton.rightAnchor.constraint(equalTo: playButtonView.rightAnchor),
            playButton.centerYAnchor.constraint(equalTo: playButtonView.centerYAnchor)
        ])
    }
    
    @objc func playButtonPressed() {
        UIImpactFeedbackGenerator().impactOccurred()
        delegate?.playTapped()
        playButton.isUserInteractionEnabled = false
    }
}
