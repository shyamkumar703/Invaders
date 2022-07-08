// Copyright © TriumphSDK. All rights reserved.

import Foundation

enum TextFieldInfoMessageType {
    case error(String?)
    case success(String?)
    case info(String?)
    case empty
}

enum TextFieldContentType: CaseIterable {
    case givenName, familyName, username, referral
    
    var placeholder: String {
        switch self {
        case .givenName:
            return "signup_lbl_givenname"
        case .familyName:
            return "signup_lbl_lastname"
        case .username:
            return "signup_lbl_username"
        case .referral:
            return "signup_lbl_referral"
        }
    }
}

struct TextFieldContent: Equatable {
    var type: TextFieldContentType
    var text: String?
    private var localization: Localization
    
    init(type: TextFieldContentType, localization: Localization) {
        self.type = type
        self.localization = localization
    }
    
    var placeholder: String {
        localization.localizedString(type.placeholder)
    }
    
    static func == (lhs: TextFieldContent, rhs: TextFieldContent) -> Bool {
        lhs.type == rhs.type
    }
}
