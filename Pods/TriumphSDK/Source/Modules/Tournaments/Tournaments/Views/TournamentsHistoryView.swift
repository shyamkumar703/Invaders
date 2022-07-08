// Copyright © TriumphSDK. All rights reserved.

import UIKit

final class TournamentsHistoryView: UIView {
    
    var headerText: String? {
        didSet {
            headerLabelView.text = headerText
        }
    }

    let headerLabelView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .grayish
        return label
    }()
    
    let listView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        
        setupCommon()
        setupHeaderLabelView()
        setupListView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension TournamentsHistoryView {

    func setupCommon() {
        headerLabelView.text = "10.12.21"
    }
    
    func setupHeaderLabelView() {
        addSubview(headerLabelView)
        setupHeaderLabelViewConstrains()
    }
    
    func setupListView() {
        [true, true, true, true].forEach { _ in
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .green
            listView.addArrangedSubview(view)
            view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        addSubview(listView)
        setupListViewConstrains()
    }
    
}

// MARK: - Constrains

private extension TournamentsHistoryView {
    func setupHeaderLabelViewConstrains() {
        headerLabelView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabelView.topAnchor.constraint(equalTo: topAnchor),
            headerLabelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerLabelView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setupListViewConstrains() {
        listView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: headerLabelView.bottomAnchor, constant: 10),
            listView.leadingAnchor.constraint(equalTo: leadingAnchor),
            listView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
