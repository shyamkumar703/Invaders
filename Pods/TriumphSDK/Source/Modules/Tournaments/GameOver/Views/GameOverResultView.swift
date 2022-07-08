// Copyright © TriumphSDK. All rights reserved.

import UIKit
import CoreHaptics

final class GameOverResultView: UIStackView {

    private var engine: CHHapticEngine?

    var viewModel: GameOverResultViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupCommon()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension GameOverResultView {
    func setupCommon() {
        axis = .horizontal
        distribution  = .fillEqually
        spacing = 16
    }

    func setupBars(with result: [GameOverResultItemViewModel?]) {
        result.forEach {
            let view = GameOverResultItemView($0)
            view.animationDuration = viewModel?.animationDuration
            addArrangedSubview(view)
        }
    }
}

// MARK: - Vibration

extension GameOverResultView {

    func intensity(strideValue: Double) -> Float {
        return 1
    }
    
    func performVibration() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
                
        for element in stride(from: 0, to: viewModel?.animationDuration?.value ?? 3.0, by: 0.01) {
            let intensity = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: intensity(strideValue: element)
            )
            let sharpness = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: Float(element)
            )
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: element
            )
            events.append(event)
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            // FIXME: Handle this catch
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

// MARK: - GameOverResultViewModelViewDelegate

extension GameOverResultView: GameOverResultViewModelViewDelegate {
    func gameOverWithResult(result: [GameOverResultItemViewModel?]) {
        
        if arrangedSubviews.isEmpty == false {
            removeAllArrangedSubviews()
        }

        setupBars(with: result)

        if viewModel?.isAllowPrerformVibration == true {
            performVibration()
        }
    }
}
