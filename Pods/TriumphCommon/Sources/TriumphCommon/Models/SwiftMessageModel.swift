// Copyright © TriumphSDK. All rights reserved.

import UIKit

public struct SwiftMessageModel {
    public enum SwiftMessageType {
        case error
        case statusLine
    }
    
    public var title: FlexibleString
    public var message: FlexibleString
    public var type: SwiftMessageType?
    public var emoji: FlexibleString?
    public var action: ((UIButton) -> Void)?
    
    public init(
        title: FlexibleString,
        message: FlexibleString,
        type: SwiftMessageModel.SwiftMessageType? = nil,
        emoji: FlexibleString? = nil,
        action: ((UIButton) -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.emoji = emoji
        self.action = action
    }
}
