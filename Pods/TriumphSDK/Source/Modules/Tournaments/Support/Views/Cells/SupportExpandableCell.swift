// Copyright © TriumphSDK. All rights reserved.

import UIKit

enum SupportExpandableCellState {
    case open, close
}

final class SupportExpandableCell: SupportBaseCell {
    
    private var detailsBottomConstraint: NSLayoutConstraint?

    lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayish
        label.numberOfLines = .zero
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private lazy var headerView = SupportExpandableHeaderView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupCommon() {
        super.setupCommon()

        addSubview(headerView)
        addSubview(detailsLabel)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: detailsLabel.topAnchor),
            
            detailsLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            detailsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
        
        self.detailsBottomConstraint = NSLayoutConstraint(
            item: detailsLabel,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        guard let bottomConstraint = self.detailsBottomConstraint else { return }
        addConstraint(bottomConstraint)
    }
    
    func configure(viewModel: SupportCellViewModel?) {
        guard let title = viewModel?.title else { return }
        let isExpanded = viewModel?.isExpanded ?? false
        detailsLabel.text = viewModel?.text
        headerView.configure(title: title, isExpaned: isExpanded)

        detailsBottomConstraint?.constant = isExpanded ? -30 : 0
    }
}
