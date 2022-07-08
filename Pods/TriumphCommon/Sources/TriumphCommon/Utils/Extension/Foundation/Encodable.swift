//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation

public extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (
            try? JSONSerialization.jsonObject(
                with: data,
                options: .allowFragments
            )
        ).flatMap { $0 as? [String: Any] }
    }
    
    var data: Data? {
        try? JSONEncoder().encode(self)
    }
}
