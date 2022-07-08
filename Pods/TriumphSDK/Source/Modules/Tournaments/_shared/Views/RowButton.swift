// Copyright © TriumphSDK. All rights reserved.

import UIKit
import TriumphCommon

final class RowButton: UIButton {
    
    var title: String? {
        didSet {
            setupTitle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        layer.applyGradient(of: TriumphSDK.colors.TRIUMPH_GRADIENT_COLORS, atAngle: 45)
    }
    
    func setFlexibleTitle(_ string: FlexibleString?) {
        guard let string = string else { return }
        switch string {
        case .string(let text):
            self.title = text
        case .attributedString(let attributedString):
            setAttributedTitle(attributedString, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            titleLabel?.addCharacterSpacing(kernValue: -0.4)
        }
    }
}

// MARK: - Setup

private extension RowButton {
    func setupCommon() {
        tintColor = .white
        backgroundColor = TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func setupTitle() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.rounded(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.white
        ]
        
        setAttributedTitle(NSAttributedString(string: title ?? "", attributes: titleAttributes), for: .normal)
        
    }
}
