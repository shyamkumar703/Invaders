// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentsDashboardCell: UICollectionViewCell {

    var viewModel: TournamentsDashboardViewModel? {
        didSet {
            dashboardView.viewModel = viewModel
        }
    }
    private let dashboardView = DashboardView(.tournaments)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDashboardView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension TournamentsDashboardCell {
    func setupDashboardView() {
        addSubview(dashboardView)
        setupDashboardViewConstrains()
    }
}

// MARK: - Constrains

private extension TournamentsDashboardCell {
    func setupDashboardViewConstrains() {
        dashboardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dashboardView.topAnchor.constraint(equalTo: topAnchor),
            dashboardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dashboardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dashboardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}
