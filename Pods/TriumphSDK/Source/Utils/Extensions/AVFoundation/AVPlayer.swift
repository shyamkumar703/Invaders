// Copyright © TriumphSDK. All rights reserved.

import AVFoundation

extension AVPlayer {
    convenience init?(named: String, withExtension: String = "mp4") {
        guard let bundle = TriumphSDK.bundle else { return nil }
        guard let videoPath = bundle.url(forResource: named, withExtension: withExtension) else { return nil }
        self.init(url: videoPath)
    }
}

extension AVPlayerItem {
    convenience init?(named: String, withExtension: String = "mp4") {
        guard let bundle = TriumphSDK.bundle else { return nil }
        guard let videoPath = bundle.url(forResource: named, withExtension: withExtension) else { return nil }
        self.init(url: videoPath)
    }
}
