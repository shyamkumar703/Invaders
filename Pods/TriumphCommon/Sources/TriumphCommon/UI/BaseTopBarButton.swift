// Copyright © TriumphSDK. All rights reserved.

import UIKit

public enum BaseTopBarButtonType: String {
    case close = "xmark.circle.fill"
    case back = "lessthan.circle.fill"
    case info = "info.circle.fill"
    case question = "questionmark.circle.fill"
    case report = "exclamationmark.circle.fill"
    
    var icon: String {
        self.rawValue
    }
    
}

open class BaseTopBarButton: UIButton {
    
    public var type: BaseTopBarButtonType = .back {
        didSet {
            if type == .report{
                setStyle()
            } else {
                setIcon()
            }
            
            
        }
    }
    
    public lazy var widthConstraint = widthAnchor.constraint(equalToConstant: 36)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
        setIcon()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension BaseTopBarButton {
    func setupCommon() {
        imageView?.contentMode = .scaleAspectFit
        
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
        tintColor = .ironDark
    }
    
    func setIcon() {
        widthConstraint.isActive = true
        if #available(iOS 15.0, *) {
           configuration = nil
        } else {
            // Fallback on earlier versions
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        setAttributedTitle(nil, for: .normal)
        
        let image = UIImage(systemName: type.icon)
        backgroundColor = .clear
        setImage(image, for: .normal)
        self.layer.cornerRadius = 0
    }
    
    func setStyle() {
        widthConstraint.isActive = false
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        setAttributedTitle(NSAttributedString(string: " Report issue ", attributes: attributes), for: .normal)
        
        backgroundColor = .ironDark
        self.layer.cornerRadius = 18
        setImage(nil, for: .normal)
        
        if #available(iOS 15.0, *) {
            configuration = .plain()
            configuration?.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 5,
                bottom: 0,
                trailing: 5
            )
        } else {
            // Fallback on earlier versions
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
    }
}
