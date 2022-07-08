//  Copyright © 2021 Triumph Lab Inc. All rights reserved.

import Foundation

public struct HostConfig: Response {
    public var minimumWithdraw: Int
    public var weeklyWithdrawableLimitGlobal: Int
    
    public init(
        minimumWithdraw: Int,
        weeklyWithdrawableLimitGlobal: Int
    ) {
        self.minimumWithdraw = minimumWithdraw
        self.weeklyWithdrawableLimitGlobal = weeklyWithdrawableLimitGlobal
    }
}
