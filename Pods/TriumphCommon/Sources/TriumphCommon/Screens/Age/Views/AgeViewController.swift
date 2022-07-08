// Copyright © TriumphSDK. All rights reserved.

import UIKit

public final class AgeViewController<ViewModel: AgeViewModel>: StepViewController, BirthdayViewModelDelegate {

    public var viewModel: ViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "calendar.badge.clock")
        imageView.sizeToFit()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightSilver
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 110, width: UIScreen.main.bounds.size.width - 40, height: 60))
        label.textColor = .white
        label.numberOfLines = .zero
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 23, weight: .light)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 140, width: UIScreen.main.bounds.size.width - 40, height: 60))
        label.textColor = .lightSilver
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        return label
    }()
  
    private lazy var birthdayDateSelector: BirthdayView = {
        let view = BirthdayView()
        view.model?.viewModelDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public override func viewDidLoad() {
        setupTapToDismiss()
        setupScrollView()
        setupIconImageView()
        setupTitleLabel()
        setupSubTitleLabel()
        setupContinueButton()
        setupBirthdayView()
        
        super.viewDidLoad()
        setupBottomDisclaimerView(with: viewModel?.appleNotSponsorDisclaimer)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel?.viewWillAppear()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        birthdayDateSelector.enableKeyboard()
    }
    
    internal func datePickerChanged(date: Date) {
        viewModel?.datePickerDidChange(date)
    }
    
    func birthdayViewDidResign() {
        viewModel?.continueButtonPressed()
    }
    
    @objc func dismissFirstResponder() {
        birthdayDateSelector.dismissFirstResponder()
    }
}

// MARK: - Setup

private extension AgeViewController {
    
    func setupTapToDismiss() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissFirstResponder))
        contentView.addGestureRecognizer(gestureRecognizer)
    }
    
    func setupBirthdayView() {
        contentView.addSubview(birthdayDateSelector)
        setupBirthdayViewConstraints()
    }

    func setupIconImageView() {
        contentView.addSubview(iconImageView)
        setupIconImageViewConstrains()
    }
    
    func setupTitleLabel() {
        titleLabel.text = viewModel?.title
        contentView.addSubview(titleLabel)
    }
    
    func setupSubTitleLabel() {
        subTitleLabel.text = viewModel?.subTitle
        contentView.addSubview(subTitleLabel)
    }
    
    func setupContinueButton() {
        continueButton.setTitle(viewModel?.continueButtonTitle, for: .normal)
        continueButton.onPress { [weak self] in
            guard let self = self else { return }
//            self.viewModel?.continueButtonPressed()
            self.birthdayViewDidResign()
        }
    }
}

// MARK: - AgeViewModelViewDelegate

extension AgeViewController: AgeViewModelViewDelegate {
    public func continueButtonIsEnabled(_ isEnabled: Bool) {
        continueButton.isEnabled = isEnabled
    }
}

// MARK: - Constrains

extension AgeViewController {
    
    func setupIconImageViewConstrains() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 70)
        ])
    }
    
    func setupBirthdayViewConstraints() {
        NSLayoutConstraint.activate([
            birthdayDateSelector.widthAnchor.constraint(equalToConstant: titleLabel.intrinsicContentSize.width + 50),
            birthdayDateSelector.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            birthdayDateSelector.heightAnchor.constraint(equalToConstant: 85),
            birthdayDateSelector.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 20)
        ])
    }
}
