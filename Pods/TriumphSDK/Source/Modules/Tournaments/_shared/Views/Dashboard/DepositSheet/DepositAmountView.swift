//
//  DepositAmountView.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/4/22.
//

import Foundation
import UIKit

protocol DepositAmountViewModel {
    var depositAmount: Int { get }
    var tokenAmount: Int? { get }
    var isBestValue: Bool { get }
    var isSelected: Bool { get set }
    func amountSelected(view: DepositAmountView)
}

class DepositAmountViewModelImplementation: DepositAmountViewModel {
    var depositAmount: Int
    var tokenAmount: Int?
    var isBestValue: Bool
    var isSelected: Bool = false
    
    init(depositAmount: Int, tokenAmount: Int?, isBestValue: Bool, isSelected: Bool = false) {
        self.depositAmount = depositAmount
        self.tokenAmount = tokenAmount
        self.isBestValue = isBestValue
        self.isSelected = isSelected
    }
    
    func amountSelected(view: DepositAmountView) {
        isSelected = true
        NotificationCenter.default.post(
            name: .depositAmountSelected,
            object: nil,
            userInfo: [
                "amountSelected": depositAmount,
                "view": view
            ]
        )
    }
}

class DepositAmountView: UIView {
    
    var viewModel: DepositAmountViewModel? {
        didSet {
            updateView()
        }
    }
    
    lazy var innerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
//        view.layer.borderColor = UIColor.orandish.cgColor
//        view.layer.borderWidth = 2
        
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionSelected))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        
        stack.addArrangedSubview(depositAmountLabel)
        stack.addArrangedSubview(tokenAmountLabel)
        return stack
    }()
    
    lazy var depositAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    lazy var tokenAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        innerView.layer.applyGradient(of: TriumphSDK.colors.TRIUMPH_GRADIENT_COLORS, atAngle: 45)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
//        backgroundColor = .clear
        innerView.layer.cornerRadius = 8
        addSubview(innerView)
        innerView.addSubview(stack)
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: innerView.topAnchor, constant: 8),
            stack.leftAnchor.constraint(equalTo: innerView.leftAnchor, constant: 8),
            stack.rightAnchor.constraint(equalTo: innerView.rightAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: innerView.bottomAnchor, constant: -8),

            innerView.topAnchor.constraint(equalTo: topAnchor),
            innerView.leftAnchor.constraint(equalTo: leftAnchor),
            innerView.rightAnchor.constraint(equalTo: rightAnchor),
            innerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            innerView.heightAnchor.constraint(equalToConstant: 88)
        ])
    }
    
    func updateView() {
        guard let viewModel = viewModel else {
            return
        }
        depositAmountLabel.text = viewModel.depositAmount.formatCurrency()
        
//        if viewModel.isBestValue {
//            innerView.layer.doGlowAnimation(withColor: #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1))
//        }
        
        updateTokens()
        
        depositAmountLabel.textColor = viewModel.isSelected ? .white : .orandish
        tokenAmountLabel.textColor = viewModel.isSelected ? .white : .orandish
        innerView.backgroundColor = viewModel.isSelected ? .orandish : .white
    }
    
    @objc func optionSelected() {
        UIImpactFeedbackGenerator().impactOccurred()
        viewModel?.amountSelected(view: self)
    }
    
    func select() {
        innerView.backgroundColor = .orandish
        depositAmountLabel.textColor = .white
        updateTokens()
    }
    
    func updateTokens() {
        guard let viewModel = viewModel else {
            return
        }
        if let tokens = viewModel.tokenAmount {
            tokenAmountLabel.textColor = viewModel.isSelected ? .white : .orandish
            let text = NSMutableAttributedString(string: "+ \(tokens) ")
            text.append(NSMutableAttributedString.token(with: .headline, tintColor: viewModel.isSelected ? .white : .orandish))
            tokenAmountLabel.attributedText = text
        }
        
        depositAmountLabel.textColor = viewModel.isSelected ? .white : .orandish
        tokenAmountLabel.textColor = viewModel.isSelected ? .white : .orandish
        innerView.backgroundColor = viewModel.isSelected ? .orandish : .white
    }
    
    func deselect() {
        viewModel?.isSelected = false
        innerView.backgroundColor = .white
        depositAmountLabel.textColor = .orandish
        updateTokens()
    }
}
