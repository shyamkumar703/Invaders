//
//  MatchingConditionView.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 6/8/22.
//

import Foundation
import UIKit

class MatchingConditionView: UIView {
    
    var viewModel: MatchingConditionViewModel? {
        didSet {
            viewModel?.viewDelegate = self
            updateView()
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .grayish
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .grayish
        label.font = .systemFont(ofSize: 20)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        layer.cornerRadius = 12
        backgroundColor = .clear
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(statusIcon)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 28),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            
            statusIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28)
        ])
    }
    
    func updateView() {
        if let viewModel = viewModel {
            imageView.image = viewModel.getCurrentDisplayImage()
            titleLabel.text = viewModel.title
            statusIcon.image = viewModel.statusImage.0
            statusIcon.tintColor = viewModel.statusImage.1
        }
    }
}

extension MatchingConditionView: MatchingConditionViewDelegate {
    func statusUpdated() {
        Task { @MainActor in
            UIView.transition(with: self, duration: 0.2) {
                self.updateView()
            }
        }
    }
}
