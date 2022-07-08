// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class CashoutViewController: StepViewController {
    
    private var viewModel: CashoutViewModel
    
    init(viewModel: CashoutViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var balanceTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 80, weight: .bold)
        textField.textColor = .white
        textField.tintColor = .green
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    private var balanceInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .center    
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution  = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private var balanceInfoText: NSAttributedString {
        get async {
            let withdrawalLimit = viewModel.balanceDisclaimerWithdrawalTokens
            let withdrawalTokens = await viewModel.balanceDisclaimerWithdrawalLimits
            let withdrawalCash = await viewModel.balanceDisclaimerWithdrawalCash
 
            let string = NSMutableAttributedString()
            string.append(NSAttributedString(string: withdrawalLimit))
            
            if let tokenImage = UIImage(commonNamed: "token")?.withTintColor(.white) {
                let tokenAttachment = NSTextAttachment()
                tokenAttachment.bounds = CGRect(x: 0, y: -3, width: tokenImage.size.width, height: tokenImage.size.height)
                tokenAttachment.image = UIImage(commonNamed: "token")?.withTintColor(.white)
                string.append(NSAttributedString(string: " "))
                string.append(NSAttributedString(attachment: tokenAttachment))
            }
            string.append(NSAttributedString(string: withdrawalTokens))

            string.append(NSAttributedString(string: withdrawalCash))
            return string.withCustomFormat(lineSpacing: 3, paragraphSpacing: 6, alignemnt: .center)
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        super.viewDidLoad()

        setupBalanceTextField()
        setupBalanceInfoLabel()
        setupContinueButton()
        viewModel.viewDelegate = self
        setupStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTopNavButton(type: .back)
        viewModel.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear()
    }
}

// MARK: - Setup

private extension CashoutViewController {
    func setupStackView() {
        viewModel.items.forEach {
            let itemView = IconWithTitleView(icon: $0.icon, title: $0.title)
            stackView.addArrangedSubview(itemView)
        }
        
        view.addSubview(stackView)
        setupStackViewConstrains()
    }
    
    func setupBalanceTextField() {
        view.addSubview(balanceTextField)
        Task { @MainActor [weak self] in
            balanceTextField.placeholder = await self?.viewModel.balanceTextPlaceholder
            balanceTextField.text = await self?.viewModel.balanceText
        }
        setupBalanceTextFieldConstrains()
    }
    
    func setupBalanceInfoLabel() {
        view.addSubview(balanceInfoLabel)
        Task { @MainActor [weak self] in
            balanceInfoLabel.attributedText = await self?.balanceInfoText
        }
        setupBalanceInfoLabelConstrains()
    }

    func setupContinueButton() {
        continueButton.setTitle(viewModel.continueButtonTitle, for: .normal)

        continueButton.onPress { [weak self] in
            guard let self = self else { return }
            self.viewModel.continueButtonPressed()
        }
    }
}

extension CashoutViewController: CashoutViewModelViewDelegate {
    func cashoutCashBalanceDidUpdate() {
        Task { @MainActor [weak self] in
            self?.balanceTextField.text = await viewModel.balanceText
            self?.balanceInfoLabel.attributedText = await balanceInfoText
        }
    }
}

// MARK: - Constrains

private extension CashoutViewController {
    func setupBalanceTextFieldConstrains() {
        NSLayoutConstraint.activate([
            balanceTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            balanceTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            balanceTextField.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupBalanceInfoLabelConstrains() {
        NSLayoutConstraint.activate([
            balanceInfoLabel.topAnchor.constraint(equalTo: balanceTextField.bottomAnchor),
            balanceInfoLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            balanceInfoLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
    }
    
    func setupStackViewConstrains() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: balanceInfoLabel.bottomAnchor, constant: 40),
            stackView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20)
        ])
    }
}
