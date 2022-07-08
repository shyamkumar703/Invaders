// The MIT License (MIT)
// Copyright © 2021 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

enum Images {
    
    static func particles_icon(for particles: SPConfettiParticle) -> UIImage {
        switch particles {
        case .arc:
            return UIImage(named: "arc") ?? UIImage()
        case .heart:
            return UIImage(named: "heart") ?? UIImage()
        case .circle:
            return UIImage(named: "circle") ?? UIImage()
        case .polygon:
            return UIImage(named: "polygon") ?? UIImage()
        case .star:
            return UIImage(named: "star") ?? UIImage()
        case .triangle:
            return UIImage(named: "triangle") ?? UIImage()
        case .triumph:
            return UIImage(named: "logo") ?? UIImage()
        case .custom(let image):
            return image
        }
    }
    
    // MARK: - Internal
    
    static var bundle: Bundle {
        
        // If installed via SPM, will be available bundle .module.
        
        #if SPCONFETTI_SPM
        return .module
        #else
        
        // If installed via Cocoapods, should use bundle from podspec.
        
        let path = Bundle(for: SPConfetti.self).path(forResource: "SPConfetti", ofType: "bundle") ?? ""
        let bundle = Bundle(path: path) ?? Bundle.main
        return bundle
        #endif
    }
}
