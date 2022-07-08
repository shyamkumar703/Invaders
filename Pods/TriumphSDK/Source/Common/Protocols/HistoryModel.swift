// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

public protocol HistoryModel: SelfIdentifiable {
    var date: Date { get }
    var title: String? { get }
    var description: String? { get }
}
