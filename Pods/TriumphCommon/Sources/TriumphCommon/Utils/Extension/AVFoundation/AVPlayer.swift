// Copyright © TriumphSDK. All rights reserved.

import AVFoundation

public extension AVPlayer {
    internal convenience init?(named: String, withExtension: String = "mp4") {
        let bundle = TriumphCommon.bundle
        guard let videoPath = bundle.url(forResource: named, withExtension: withExtension) else { return nil }
        self.init(url: videoPath)
    }
    
    convenience init?(commonNamed: String, withExtension: String = "mp4") {
        self.init(named: commonNamed, withExtension: withExtension)
    }
}

public extension AVPlayerItem {
    internal convenience init?(named: String, withExtension: String = "mp4") {
        let bundle = TriumphCommon.bundle
        guard let videoPath = bundle.url(forResource: named, withExtension: withExtension) else { return nil }
        self.init(url: videoPath)
    }
    
    convenience init?(commonNamed: String, withExtension: String = "mp4") {
        self.init(named: commonNamed, withExtension: withExtension)
    }
}
