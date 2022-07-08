// Copyright © TriumphSDK. All rights reserved.

import UIKit

class MissionTableViewCell: UITableViewCell {
    
    var missionView: MissionView? {
        didSet {
            setupView()
            setupConstraints()
        }
    }
    
    weak var viewDelegate: MissionsViewDelegate?
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        guard let missionView = missionView else {
            return
        }
        missionView.viewModel?.delegate = viewDelegate
        backgroundColor = .clear
        missionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(missionView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
    }
    
    func setupConstraints() {
        guard let missionView = missionView else {
            return
        }

        NSLayoutConstraint.activate([
            missionView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            missionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            missionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            missionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        ])
    }
    
    override func prepareForReuse() {
        missionView?.removeFromSuperview()
    }
    
    @objc func didTap() {
        guard let viewModel = missionView?.viewModel else { return }
        viewDelegate?.respondToTap(action: viewModel.missionAction, model: viewModel.model)
    }
}
