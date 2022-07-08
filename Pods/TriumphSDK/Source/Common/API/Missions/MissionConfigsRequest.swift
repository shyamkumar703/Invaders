//
//  MissionConfigsRequest.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 2/28/22.
//

import Foundation
import TriumphCommon

struct MissionConfigsRequest: IdentifiableOutputRequest {
    typealias Output = MissionConfig
    var path: String
    
    init() {
        self.path = "missions"
    }
}
