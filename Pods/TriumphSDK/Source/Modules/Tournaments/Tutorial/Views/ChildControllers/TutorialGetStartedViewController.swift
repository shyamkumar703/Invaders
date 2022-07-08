//
//  TutorialGetStartedViewController.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/26/22.
//

import Foundation
import UIKit
import TriumphCommon

class TutorialGetStartedViewController: TutorialController {
    
    var viewModel: TutorialGetStartedViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 21, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1)
        button.layer.doGlowAnimation(withColor: #colorLiteral(red: 1, green: 0.4078431373, blue: 0.137254902, alpha: 1))
        button.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.runConfetti()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nextButton.isUserInteractionEnabled = true
    }
    
    func setupView() {
        if let navigationController = self.navigationController as? BaseNavigationController {
            navigationController.hideRightTopNavButton()
        }
        
        view.backgroundColor = .lightDark
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(nextButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            imageView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 300),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16)
        ])
    }
    
    @objc func nextPage() {
        UIImpactFeedbackGenerator().impactOccurred()
        viewModel?.goToNextPage()
    }
}

extension TutorialGetStartedViewController: TutorialGetStartedViewModelViewDelegate {
    func updateView(viewModel: TutorialGetStartedViewModel?) {
        DispatchQueue.main.async { [self] in
            guard let viewModel = viewModel,
                  let imageName = viewModel.image,
                  let title = viewModel.title,
                  let buttonTitle = viewModel.buttonTitle else { return }
            
            imageView.image = UIImage(named: imageName)
            titleLabel.text = title
            nextButton.setTitle(buttonTitle, for: .normal)
        }
    }
}
