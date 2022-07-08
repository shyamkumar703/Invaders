// Copyright © TriumphSDK. All rights reserved.

import Foundation
import TriumphCommon

protocol BlitzInfographicViewModelDelegate: AnyObject {
    func blitzInfographicRunConfetti()
}

protocol BlitzInfographicViewModelViewDelegate: AnyObject {
    func blitzInfographicViewModelDidUpdate()
}

protocol BlitzInfographicViewModel {
    var delegate: BlitzInfographicViewModelDelegate? { get set }
    var viewDelegate: BlitzInfographicViewModelViewDelegate? { get set }
    var items: [BlitzInfographicItemViewModel] { get }
    var selectedAmount: Double { get set }

    func setBlitzDelegate()
    func updateContent(with selectedAmount: Double)
}

// MARK: - Impl.

final class BlitzInfographicViewModelImplementation: BlitzInfographicViewModel {
    
    weak var delegate: BlitzInfographicViewModelDelegate?
    weak var viewDelegate: BlitzInfographicViewModelViewDelegate?
    private var dependencies: AllDependencies
    var selectedAmount: Double {
        didSet {
            viewDelegate?.blitzInfographicViewModelDidUpdate()
        }
    }
    private var state: BlitzState
    private var prize: Double = 0
    
    init(dependencies: AllDependencies, selectedAmount: Double, state: BlitzState) {
        self.dependencies = dependencies
        self.selectedAmount = selectedAmount
        self.state = state
        dependencies.game.blitzDelegate = self
    }

    private var headers: [BlitzInfographicItemViewModel] {
        [
            BlitzInfographicItemModel(score: "Score", prize: "Prize", type: .title)
        ].compactMap {
            BlitzInfographicItemViewModelImplementation(model: $0, dependencies: dependencies)
        }
    }

    private var lineLocation: Double {
        switch state {
        case .finish:
            if GameManager.blitzBuyIn == selectedAmount {
                return GameManager.getBlitzPayoutForScoreDouble(totalScore: dependencies.game.score)
            } else {
                return selectedAmount
            }
        case .start:
            return selectedAmount
        case .history(let game):
            let winnings = game?.blitzConfig?.payout ?? 0
            let amount = Double(game?.blitzConfig?.tournamentDefinition?.entryPrice ?? 1)
            if amount == (selectedAmount * 100) {
                return winnings / 100
            } else {
                return selectedAmount
            }
        }
    }
    
    private func getMod(from scores: [Double : Double]) -> Int {
        let mod: Int = scores.keys.count / 9
        return mod == 0 ? 1 : mod
    }
 
    private var content: [BlitzInfographicItemViewModel] {
        var scoresSet: Set<[Double: Double]> = []

        for unit in Dummy.Blitz.scoreMultipliers {
            if let addition = interpolateForMultiplier(point: unit) {
                if addition.keys.first != dependencies.game.score {
                    scoresSet.insert(addition)
                }
            }
        }
        if lineLocation == selectedAmount {
            if let addition = interpolateForMultiplier() {
                scoresSet.insert(addition)
            }
        } else {
            if !Dummy.Blitz.scoreMultipliers.contains(lineLocation / selectedAmount) {
                if let addition = interpolateForMultiplier(point: lineLocation, line: true) {
                    scoresSet.insert(addition)
                }
            }
        }

        return scoresSet
            .enumerated()
            .compactMap { _, element in
                var prize = element.first?.value ?? 0
                let type: BlitzInfographicItemType = prepareInfographicItemType(prize: prize)
                let score: String = prepareScore(element.first?.key ?? 0)
                let model = BlitzInfographicItemModel(score: score, prize: String(format: "$%.02f", prize), type: type)
                return BlitzInfographicItemViewModelImplementation(model: model, dependencies: dependencies)
            }
            .sorted { $0.prize.compare($1.prize, options: .numeric) == .orderedDescending }
    }
    
    private func prepareInfographicItemType(prize: Double) -> BlitzInfographicItemType {
        if prize == lineLocation {
            self.prize = prize
            return .result
        } else {
            return .unit
        }
    }
    
    /*
     We cannot use dependences.gameInfo.format here, dependencies are initialized statically and score precision
     could be set at any time by the consumer.
     */
    private func prepareScore(_ score: Double) -> String {
        String(format: TriumphSDK.scoreDecimalPoints.format, score)
    }
    
    /// Interpolates for a given multiplier to find the associated score. We have a dict [score: multiplier] and this essentially finds a score
    /// for a given multiplier (point).
    private func interpolateForMultiplier(point: Double = 1.0, line: Bool = false) -> [Double: Double]? {
        var pointForCalculation = point
        if line {
            pointForCalculation /= selectedAmount
        }
        var multiplierAmount = selectedAmount
        
        if line == true {
            multiplierAmount = 1
        }
        
        let scores = dependencies.game.getBlitzScoreArray()
        let scoresSorted = scores?.sorted(by: {$0.key < $1.key})

        let entryAbove = scoresSorted?.first(where: { $0.value >= pointForCalculation })
        let entryBelow = scoresSorted?.last(where: { $0.value <= pointForCalculation })

        guard let entryBelow = entryBelow else {
            return [0 : pointForCalculation * multiplierAmount]
        }

        guard let entryAbove = entryAbove else {
            return [ entryBelow.key.roundToNPlaces(n: dependencies.appInfo.scoreType.rawValue) : lineLocation * multiplierAmount]
        }

        let scoreAbove = entryAbove.key
        let scoreBelow = entryBelow.key
        let multiplierAbove = entryAbove.value
        let multiplierBelow = entryBelow.value
        
        if multiplierAbove == multiplierBelow {
            return [entryBelow.key.roundToNPlaces(n: dependencies.appInfo.scoreType.rawValue) : point * multiplierAmount]
        }

        let multiplier = Double(scoreAbove - scoreBelow) / (multiplierAbove - multiplierBelow)
        let closedFormSoloutionAtPoint = multiplier * (pointForCalculation - multiplierBelow) + Double(scoreBelow)
        let roundedScore = closedFormSoloutionAtPoint.roundToNPlaces(n: dependencies.appInfo.scoreType.rawValue)
        return [roundedScore : point * multiplierAmount]
    }
    
    var items: [BlitzInfographicItemViewModel] {
        headers + content
    }
    
    func updateContent(with selectedAmount: Double) {
        self.selectedAmount = selectedAmount
        viewDelegate?.blitzInfographicViewModelDidUpdate()
    }

    func setBlitzDelegate() {
        dependencies.game.blitzDelegate = self
    }
}

// MARK: - BlitzGameManagerDelegate

extension BlitzInfographicViewModelImplementation: BlitzGameManagerDelegate {
    func newBlitzDataLoaded() {
        viewDelegate?.blitzInfographicViewModelDidUpdate()
    }
    
    func blitzSubmitDidFinish() {
        if prize > selectedAmount {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.blitzInfographicRunConfetti()
            }
        }
    }
}
