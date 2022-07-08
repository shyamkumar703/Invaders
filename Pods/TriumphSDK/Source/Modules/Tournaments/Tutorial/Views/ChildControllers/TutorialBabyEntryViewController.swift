//
//  TutorialBabyEntryViewController.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/26/22.
//

import Foundation
import UIKit
import TriumphCommon

class TutorialBabyEntryViewController: TutorialController {
    
    var viewModel: TutorialBabyEntryViewModel? {
        didSet {
            viewModel?.viewDelegate = self
            babyCell.delegate = viewModel
        }
    }
    
    lazy var progressView = ProgressHUD()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var textStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 32
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(babyCell)
        return stack
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var babyCell: TutorialBabyCell = {
        let cell = TutorialBabyCell()
        cell.layer.doGlowAnimation(withColor: .white, from: 2, to: 8)
        cell.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressView.center = view.center
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        finishLoad()
    }
    
    func setupView() {
        if let navigationController = self.navigationController as? BaseNavigationController {
            navigationController.hideRightTopNavButton()
        }
        
        view.backgroundColor = .lightDark
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(babyCell)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
            imageView.bottomAnchor.constraint(equalTo: babyCell.topAnchor, constant: -20),
            
            babyCell.heightAnchor.constraint(equalToConstant: 84),
            babyCell.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            babyCell.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            babyCell.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
        ])
    }
    
    @objc func nextPage() {
        UIImpactFeedbackGenerator().impactOccurred()
        viewModel?.goToNextPage()
    }
}

extension TutorialBabyEntryViewController: TutorialBabyEntryViewModelViewDelegate {
    func updateView(viewModel: TutorialBabyEntryViewModel) {
        DispatchQueue.main.async { [self] in
            guard let title = viewModel.title else { return }
            
            if let image = viewModel.image {
                imageView.image = UIImage(named: image)
            }
            titleLabel.text = title
        }
    }
    
    func startLoad() {
        Task { @MainActor [weak self] in
            self?.view.addSubview(progressView)
            self?.progressView.start()
        }
    }
    
    func finishLoad() {
        Task { @MainActor [weak self] in
            self?.progressView.stop()
            self?.progressView.removeFromSuperview()
        }
    }
}
