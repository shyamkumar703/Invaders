// Copyright © TriumphSDK. All rights reserved.

import UIKit

open class StepViewController: BaseViewController {
    
    public lazy var continueButton = PrimaryButton()
    public lazy var bottomContentView = UIView()
    
    private var bottomContentViewBottomConstraint: NSLayoutConstraint?
    private var bottomButtonBottomConstrains: NSLayoutConstraint?
    private lazy var bottomPadding: CGFloat = {
        let window = UIApplication.shared.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }()
    
    private lazy var bottomDisclaimerView = BottomDisclaimerView()

    public var bottomButtonConstraint: CGFloat = -20
    public var bottomContentViewHeightConstant: CGFloat = 58
    public var bottomContentViewHeightConstraint: NSLayoutConstraint?
    public var isContinueButtonFollowKeyboardSuggestionBar: Bool = false
    public var isBottomContentFollowKeyboard: Bool = true
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomContentView()
        setupContinueButton()
        setupCommon()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        bottomContentView.layer.applyGradient(
            of: [.black.withAlphaComponent(0), .black],
            atAngle: 450
        )
        
        bottomContentViewHeightConstraint?.constant = view.safeAreaInsets.bottom + bottomContentViewHeightConstant
    }
    
    public func setupBottomDisclaimerView(with disclaimerText: NSAttributedString?) {
        bottomDisclaimerView.disclaimerText = disclaimerText
        bottomDisclaimerView.isEditable = false
        view.addSubview(bottomDisclaimerView)
        setupBottomDisclaimerViewConstrains()
    }
}

// MARK: - Setup

private extension StepViewController {
    func setupCommon() {
        view.backgroundColor = .black
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
    }

    func setupBottomContentView() {
        view.addSubview(bottomContentView)
        bottomContentView.backgroundColor = .clear
        setupBottomContentViewConstrains()
    }
    
    func setupContinueButton() {
        view.addSubview(continueButton)
        setupContinueButtonConstrains()
    }
}

// MARK: - Keyboard Events

extension StepViewController {
    public override func keyboardWillAppear() {
        if isBottomContentFollowKeyboard == false { return }
        if isKeyboardingForceKeep == true { return }
        bottomContentViewBottomConstraint?.constant -= keyboardHeight - 40
        bottomButtonBottomConstrains?.constant -= keyboardHeight - bottomPadding

        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
    
    public override func keyboardDidAppear() {
        if isBottomContentFollowKeyboard == false { return }
        if isKeyboardingForceKeep == true { return }
        if isContinueButtonFollowKeyboardSuggestionBar == false { return }

        bottomContentViewBottomConstraint?.constant -= keyboardBarHeight
        bottomButtonBottomConstrains?.constant -= keyboardBarHeight

        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
    
    public override func keyboardWillDisappear() {
        if isBottomContentFollowKeyboard == false { return }
        bottomContentViewBottomConstraint?.constant = 0
        bottomButtonBottomConstrains?.constant = -20
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Constrains

private extension StepViewController {
    
    func setupBottomContentViewConstrains() {
        bottomContentView.translatesAutoresizingMaskIntoConstraints = false

        bottomContentViewBottomConstraint = prepareBottomConstraint(
            item: bottomContentView,
            toItem: view,
            constant: 0
        )
        
        bottomContentViewHeightConstraint = NSLayoutConstraint(
            item: bottomContentView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: bottomContentViewHeightConstant
        )

        guard let bottomConstraint = bottomContentViewBottomConstraint,
              let heightConstraint = bottomContentViewHeightConstraint else { return }
        view.addConstraint(bottomConstraint)
        view.addConstraint(heightConstraint)

        NSLayoutConstraint.activate([
            bottomContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupContinueButtonConstrains() {
        continueButton.translatesAutoresizingMaskIntoConstraints = false

        bottomButtonBottomConstrains = prepareBottomConstraint(
            item: continueButton,
            toItem: view.safeAreaLayoutGuide,
            constant: bottomButtonConstraint
        )
        
        guard let bottomConstraint = bottomButtonBottomConstrains else { return }
        view.addConstraint(bottomConstraint)
        
        NSLayoutConstraint.activate([
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.widthAnchor.constraint(equalToConstant: 300),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func prepareBottomConstraint(item: UIView, toItem: AnyObject, constant: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: item,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: toItem,
            attribute: .bottom,
            multiplier: 1,
            constant: constant
        )
    }
    
    func setupBottomDisclaimerViewConstrains() {
        bottomDisclaimerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomDisclaimerView.leadingAnchor.constraint(equalTo: bottomContentView.leadingAnchor, constant: 20),
            bottomDisclaimerView.trailingAnchor.constraint(equalTo: bottomContentView.trailingAnchor, constant: -20),
            bottomDisclaimerView.heightAnchor.constraint(equalToConstant: 74),
            bottomDisclaimerView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -5)
        ])
    }
}
