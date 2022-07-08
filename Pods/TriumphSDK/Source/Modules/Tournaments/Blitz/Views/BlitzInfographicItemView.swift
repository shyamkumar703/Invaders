// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class BlitzInfographicItemView: UIView {
    
    private let labelsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution  = .fillEqually
        return view
    }()

    private let dashedLineView: DashedLineView = {
        let view = DashedLineView()
        view.dashColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return view
    }()

    private let viewModel: BlitzInfographicItemViewModel
    
    init(viewModel: BlitzInfographicItemViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupCommon()
        setupLabelsStackView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Setup

private extension BlitzInfographicItemView {
    func setupCommon() {
        
    }
    
    func setupLabelsStackView() {
        let scoreView: BlitzInfographicElementView
        let prizeView: BlitzInfographicElementView
        labelsStackView.spacing = 100
        
        switch viewModel.type {
        case .unit:
            scoreView = BlitzInfographicElementView(title: viewModel.score, type: .unit)
            prizeView = BlitzInfographicElementView(title: viewModel.prize, type: .unit)
        case .title:
            scoreView = BlitzInfographicElementView(title: viewModel.score, type: .title)
            prizeView = BlitzInfographicElementView(title: viewModel.prize, type: .title)
        case .result:
            scoreView = BlitzInfographicElementView(title: viewModel.score, type: .withTriangle(.left))
            prizeView = BlitzInfographicElementView(title: viewModel.prize, type: .withTriangle(.right))
            labelsStackView.addSubview(dashedLineView)
            setupDashedLineViewConstrains()
        }
        
        labelsStackView.addArrangedSubview(scoreView)
        labelsStackView.addArrangedSubview(prizeView)

        addSubview(labelsStackView)
        setupLabelsStackViewConstrains()
    }
}

// MARK: - Constrains

private extension BlitzInfographicItemView {
    func setupLabelsStackViewConstrains() {
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        switch viewModel.type {
        case .title:
            labelsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        default:
            labelsStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    func setupDashedLineViewConstrains() {
        dashedLineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dashedLineView.heightAnchor.constraint(equalToConstant: 1),
            dashedLineView.centerYAnchor.constraint(equalTo: labelsStackView.centerYAnchor),
            dashedLineView.centerXAnchor.constraint(equalTo: labelsStackView.centerXAnchor),
            dashedLineView.widthAnchor.constraint(equalToConstant: 155)
        ])
    }
}
