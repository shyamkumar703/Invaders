// Copyright © TriumphSDK. All rights reserved.

import Foundation
import CoreHaptics

protocol Confetti {
    func runConfettiFromView(view: UIView, completion: @escaping () -> Void, time: Double)
}

final class ConfettiService: Confetti {
    
    private var dependencies: AllDependencies
    private let successHaptics = UINotificationFeedbackGenerator()
    
    init(dependencies: AllDependencies) {
        SPConfettiConfiguration.particlesConfig.colors.append(TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR)
        self.dependencies = dependencies
    }
    private var engine: CHHapticEngine?

    func runConfettiFromView(view: UIView, completion: @escaping () -> Void, time: Double) {
        DispatchQueue.main.async {
            SPConfetti.startAnimatingFromView(view: view, .fullWidthToDown, particles: [ .triumph, .star])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            SPConfetti.stopAnimating()
            self.successHaptics.notificationOccurred(.success)
            completion()
        })
    }
}
