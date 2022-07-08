// Copyright © TriumphSDK. All rights reserved.

import UIKit

class DashboardContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lead
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
