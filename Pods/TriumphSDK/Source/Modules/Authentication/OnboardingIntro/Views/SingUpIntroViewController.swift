// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class SingUpIntroViewController<ViewModel: SignUpIntroViewModel>: StepViewController {

    var viewModel: ViewModel?
    private var contentContainerBottomConstraint: NSLayoutConstraint?
    private var timer: Timer?
    private var rowsCount: Int = 1

    private lazy var contentContainerView = UIView()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution  = .fillEqually
        return stackView
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR
        imageView.sizeToFit()
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 170, width: UIScreen.main.bounds.size.width - 40, height: 60))
        label.textColor = .white
        label.numberOfLines = .zero
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 23, weight: .light)
        return label
    }()

    override func viewDidLoad() {
        setupLogo()
        setupTitleLabel()
        setupContentContainerView()
        setupStackView()
        setupContinueButton()

        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLeftTopNavButton(type: .close)
        showTopNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentContainerBottomConstraint?.constant = -bottomContentView.frame.height - 10
    }
    
    @objc func showRow() {
        if rowsCount >= stackView.arrangedSubviews.count {
            timer?.invalidate()
            timer = nil
            return
        }
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            self.stackView.arrangedSubviews[self.rowsCount].alpha = 1
        }
        rowsCount += 1
    }
}

// MARK: - Setup

private extension SingUpIntroViewController {
    private func setupContentContainerView() {
        view.addSubview(contentContainerView)
        setupContentContainerViewConstrains()
    }
    
    private func setupStackView() {
        viewModel?.items.enumerated().forEach {
            let itemView = SignUpIntroItemView(icon: $0.element.icon, title: $0.element.title)
            itemView.alpha = 0
            stackView.addArrangedSubview(itemView)
        }

        contentContainerView.addSubview(stackView)
        setupStackViewConstrains()
        startAnimation()
    }

    private func setupLogo() {
        view.addSubview(logoImageView)
        setupLogoConstrains()
    }
    
    private func setupTitleLabel() {
        titleLabel.attributedText = viewModel?.title
        view.addSubview(titleLabel)
    }
    
    private func setupContinueButton() {
        continueButton.setTitle(viewModel?.continueButtonTitle, for: .normal)
        continueButton.onPress { [weak self] in
            guard let self = self else { return }
            self.viewModel?.continueButtonPressed()
        }
    }
}

// MARK: - Animation

private extension SingUpIntroViewController {
    private func startAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.stackView.arrangedSubviews.first?.alpha = 1
            }
        }
        guard self.timer == nil else { return }
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(showRow),
            userInfo: nil,
            repeats: true
        )
        guard let timer = self.timer else { return }
        RunLoop.main.add(timer, forMode: .common)
    }
}

// MARK: - Constrains

private extension SingUpIntroViewController {

    func setupContentContainerViewConstrains() {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        self.contentContainerBottomConstraint = NSLayoutConstraint(
            item: contentContainerView,
            attribute: .bottom,
            relatedBy: .greaterThanOrEqual,
            toItem: view,
            attribute: .bottom,
            multiplier: 1,
            constant: -58
        )
        
        guard let stackViewBottomConstraint = self.contentContainerBottomConstraint else { return }
        view.addConstraint(stackViewBottomConstraint)
    }

    func setupStackViewConstrains() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalTo: contentContainerView.heightAnchor, multiplier: 2.3/3)
        ])
        
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            stackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: 15).isActive = true
        } else {
            stackView.centerYAnchor.constraint(
                equalTo: contentContainerView.centerYAnchor,
                constant: -10
            ).isActive = true
        }
    }

    func setupLogoConstrains() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 70)
        ])
    }
}
