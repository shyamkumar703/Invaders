// Copyright © TriumphSDK. All rights reserved.

import UIKit

class SupportBaseCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCommon() {
        selectionStyle = .none
        setupBackground()
    }
}

// MARK: - Setup

private extension SupportBaseCell {
    func setupBackground() {
        backgroundColor = .lead
        
        // Background when selected
        let bgColorView = UIView()
        bgColorView.backgroundColor = .lead
        selectedBackgroundView = bgColorView

    }
}
