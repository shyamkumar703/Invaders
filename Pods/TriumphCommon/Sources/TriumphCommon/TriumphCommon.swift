// Copyright © TriumphSDK. All rights reserved.

import Foundation

private class BundleFinder {}

public class TriumphCommon {
    /// Returns the resource bundle associated with the current Swift module.
    public static var bundle: Bundle = {
        let bundleName = "TriumphCommon_TriumphCommon"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named TriumphCommon_TriumphCommon")
    }()
    
    /// Configure SDK with your own colors useing TriumphColors object
    /// (By default the color will be orange)
    public static var colors: TriumphColors = TriumphColors()
}
