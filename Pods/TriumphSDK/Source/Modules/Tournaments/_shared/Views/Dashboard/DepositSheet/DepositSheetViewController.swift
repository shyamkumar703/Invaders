//
//  DepositSheetViewController.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/4/22.
//

import Foundation
import UIKit
import TriumphCommon

class DepositSheetViewModel {
    var isFirstDepositAfterReferral: Bool
    var referrerFirstName: String?
    var depositDefinitions: [DepositDefinitionResponse] = []
    var coordinator: TournamentsCoordinator?
    lazy var currentAmountSelected: Int? = {
        return depositDefinitions.filter { $0.isBestValue == true }.first?.depositAmount
    }()
    
    init(isFirstDepositAfterReferral: Bool, referrerFirstName: String?, depositDefinitions: [DepositDefinitionResponse], coordinator: TournamentsCoordinator) {
        self.isFirstDepositAfterReferral = isFirstDepositAfterReferral
        self.referrerFirstName = referrerFirstName
        self.depositDefinitions = depositDefinitions
        self.coordinator = coordinator
    }
    
    func showTokenInfo() {
        coordinator?.showTokenInfo()
    }
}

class DepositSheetViewController: SheetViewController {
    
    var viewModel: DepositSheetViewModel? {
        didSet {
            updateView()
        }
    }
    
    lazy var handle: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGrayish
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .left
        label.text = "Add Cash"
        return label
    }()
    
    lazy var depositMenuView: DepositMenuView = {
        let view = DepositMenuView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var addCashButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add $20", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addCashButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orandish
        return button
    }()
    
    lazy var logoStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 28
        stack.addArrangedSubview(logoStackFactory(imageName: "visa"))
        stack.addArrangedSubview(logoStackFactory(imageName: "applepay"))
        stack.addArrangedSubview(logoStackFactory(imageName: "mastercard"))
        return stack
    }()
//    lazy var descriptionStack: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .horizontal
//        stack.distribution = .equalSpacing
//        stack.alignment = .center
//
//        stack.addArrangedSubview(tokensDescriptionLabel)
//        stack.addArrangedSubview(tokenSwiftMessageButton)
//        return stack
//    }()
//
//    lazy var tokensDescriptionLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .white
//        label.numberOfLines = 0
//        label.font = .systemFont(ofSize: 24, weight: .regular)
//        label.textAlignment = .left
//
//        let tokenString = 1.formatTokens(size: .title1)
//        let descrString = NSAttributedString(string: " = \(1.formatCurrency())")
//
//        tokenString.append(descrString)
//
//        label.attributedText = tokenString
//
//        return label
//    }()
//
    lazy var tokenSwiftMessageButton: UIButton = {
        let button = UIButton()
        button.tintColor = .darkGrayish

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 17, weight: .regular),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        let attrString = NSMutableAttributedString(string: "What are tokens?", attributes: attributes)
        button.setAttributedTitle(attrString, for: .normal)
        button.addTarget(self, action: #selector(showTokenSwiftMessage), for: .touchUpInside)
        button.titleLabel?.textAlignment = .right
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
//
//    lazy var availableRewardsLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .systemFont(ofSize: 24, weight: .regular)
//        label.textAlignment = .center
//        label.text = "Rewards Available"
//        return label
//    }()
//
//    lazy var availableRewardView: AvailableRewardView = {
//        let view = AvailableRewardView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 8
//        return view
//    }()
//
//    lazy var depositInfoView: DepositInfoView = {
//        let view = DepositInfoView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.cornerRadius = 8
//        return view
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .depositAmountSelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .respondToReferralFromDepositSheet, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func logoStackFactory(imageName: String) -> UIImageView {
        let view = UIImageView()
        view.image = UIImage(named: imageName)
        view.contentMode = .scaleAspectFit
        return view
    }
    
    func setupView() {
        view.backgroundColor = .lead
        
        view.addSubview(handle)
        view.addSubview(titleLabel)
        view.addSubview(tokenSwiftMessageButton)
        view.addSubview(depositMenuView)
        view.addSubview(addCashButton)
        view.addSubview(logoStack)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(amountSelected),
            name: .depositAmountSelected,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(respondToReferralFromDepositSheet),
            name: .respondToReferralFromDepositSheet,
            object: nil
        )
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            handle.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            handle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handle.heightAnchor.constraint(equalToConstant: 4),
            handle.widthAnchor.constraint(equalToConstant: 36),
            
            titleLabel.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            
            tokenSwiftMessageButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            tokenSwiftMessageButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            depositMenuView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            depositMenuView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            depositMenuView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            addCashButton.topAnchor.constraint(equalTo: depositMenuView.bottomAnchor, constant: 20),
            addCashButton.leftAnchor.constraint(equalTo: depositMenuView.leftAnchor),
            addCashButton.rightAnchor.constraint(equalTo: depositMenuView.rightAnchor),
            addCashButton.heightAnchor.constraint(equalToConstant: 52),
            
            logoStack.topAnchor.constraint(equalTo: addCashButton.bottomAnchor, constant: 20),
            logoStack.heightAnchor.constraint(equalToConstant: 32),
            logoStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoStack.widthAnchor.constraint(equalToConstant: 240)
        ])
    }
    
    func updateView() {
        guard let viewModel = viewModel else {
            return
        }
        
        depositMenuView.viewModel = DepositMenuViewModel(options: viewModel.depositDefinitions)
    }
    
    @objc func amountSelected(_ notification: NSNotification) {
        if let amountSelected = notification.userInfo?["amountSelected"] as? Int {
            
            // If we are selecting an option that is already selected,
            // just show apple pay. 
            if amountSelected == viewModel?.currentAmountSelected {
                addCashButtonTapped()
                return
            }
            
            viewModel?.currentAmountSelected = amountSelected
            addCashButton.setTitle("Add \(amountSelected.formatCurrency())", for: .normal)
        }
    }
    
    @objc func respondToReferralFromDepositSheet() {
        UIImpactFeedbackGenerator().impactOccurred()
        dismiss(animated: true) {
            self.viewModel?.coordinator?.respondTo(action: .makeReferral, model: nil)
        }
    }
    
    @objc func showTokenSwiftMessage() {
        UIImpactFeedbackGenerator().impactOccurred()
        viewModel?.showTokenInfo()
    }
    
    @objc func addCashButtonTapped() {
        dismiss(animated: true)
        if let amountSelected = viewModel?.currentAmountSelected {
            NotificationCenter.default.post(
                name: .showApplePay,
                object: nil,
                userInfo: ["amount": Double(amountSelected) / 100.0]
            )
        }
    }
}
