//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation

public struct NoDataModel {
    public init(title: String, subTitle: String, image: String) {
        self.title = title
        self.subTitle = subTitle
        self.image = image
    }
    
    public var title: String
    public var subTitle: String
    public var image: String
}
