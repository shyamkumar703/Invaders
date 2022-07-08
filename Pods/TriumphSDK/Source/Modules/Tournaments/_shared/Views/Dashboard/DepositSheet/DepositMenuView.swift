//
//  DepositMenuView.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/4/22.
//

import Foundation
import UIKit
import TriumphCommon

class DepositMenuViewModel {
    var depositOptions: [DepositAmountViewModelImplementation]
    var selectedView: DepositAmountView?
    
    init(options: [DepositDefinitionResponse]) {
        self.depositOptions = options
            .sorted(by: { $0.depositAmount < $1.depositAmount })
            .map({ DepositAmountViewModelImplementation(
                depositAmount: $0.depositAmount,
                tokenAmount: $0.tokens,
                isBestValue: $0.isBestValue ?? false,
                isSelected: $0.isBestValue ?? false
        )})
    }
}

class DepositMenuView: UIView {
    
    var viewModel: DepositMenuViewModel? {
        didSet {
            updateView()
        }
    }
    
    lazy var outerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
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
        addSubview(outerStack)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(amountSelected),
            name: .depositAmountSelected,
            object: nil
        )
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            outerStack.topAnchor.constraint(equalTo: topAnchor),
            outerStack.rightAnchor.constraint(equalTo: rightAnchor),
            outerStack.leftAnchor.constraint(equalTo: leftAnchor),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func horizontalStackFactory(models: [DepositAmountViewModelImplementation]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        models.forEach {
            let view = DepositAmountView()
            view.viewModel = $0
            if $0.isBestValue {
                viewModel?.selectedView = view
            }
            stack.addArrangedSubview(view)
        }
        return stack
    }
    
    // INFO: - We expect exactly 4 deposit definitions at all times.
    func updateView() {
        guard let viewModel = viewModel else { return }
        if viewModel.depositOptions.count == 4 {
            outerStack.addArrangedSubview(
                horizontalStackFactory(
                    models: [
                        viewModel.depositOptions[0],
                        viewModel.depositOptions[1]
                    ]
                )
            )
            outerStack.addArrangedSubview(
                horizontalStackFactory(
                    models: [
                        viewModel.depositOptions[2],
                        viewModel.depositOptions[3]
                    ]
                )
            )
        } else {
            outerStack.addArrangedSubview(
                horizontalStackFactory(
                    models: [
                        DepositAmountViewModelImplementation(depositAmount: 500, tokenAmount: nil, isBestValue: false),
                        DepositAmountViewModelImplementation(depositAmount: 1000, tokenAmount: 100, isBestValue: false)
                    ]
                )
            )
            outerStack.addArrangedSubview(
                horizontalStackFactory(
                    models: [
                        DepositAmountViewModelImplementation(depositAmount: 1500, tokenAmount: 175, isBestValue: false),
                        DepositAmountViewModelImplementation(depositAmount: 2000, tokenAmount: 250, isBestValue: true, isSelected: true)
                    ]
                )
            )
        }
    }
    
    @objc func amountSelected(_ notification: NSNotification) {
        if let view = notification.userInfo?["view"] as? DepositAmountView,
           let currSelectedView = viewModel?.selectedView {
            viewModel?.selectedView = view
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    currSelectedView.deselect()
                    view.select()
                },
                completion: nil
            )
        }
    }
}
