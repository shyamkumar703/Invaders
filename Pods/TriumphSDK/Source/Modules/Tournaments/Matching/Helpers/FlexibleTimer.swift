// Copyright © TriumphSDK. All rights reserved.

import Foundation

class RepeatingTimerElement {
    var interval: TimeInterval
    var numberOfRepeats: Int
    var onFire: () -> Void
    var onFinish: ((RepeatingTimerElement) -> Void)? = nil
    var id = UUID()
    
    init(interval: TimeInterval, numberOfRepeats: Int, onFire: @escaping () -> Void) {
        self.interval = interval
        self.numberOfRepeats = numberOfRepeats
        self.onFire = onFire
    }
    
    private var currentNumberOfRepeats = 0
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if self.currentNumberOfRepeats == self.numberOfRepeats {
                if let onFinish = self.onFinish {
                    onFinish(self)
                }
                timer.invalidate()
            } else {
                self.onFire()
                self.currentNumberOfRepeats += 1
            }
        }
    }
    
    func invalidate() {
        timer?.invalidate()
    }
}

class FlexibleTimer {
    private var timerElements: [RepeatingTimerElement] = []
    
    init(_ elements: RepeatingTimerElement...) {
        elements.forEach { $0.onFinish = onElementFinish }
        self.timerElements = elements
        timerElements.first?.start()
    }
    
    private func onElementFinish(_ element: RepeatingTimerElement) {
        pop(element: element)
        timerElements.first?.start()
    }
    
    private func pop(element: RepeatingTimerElement) {
        timerElements = timerElements.filter { $0.id != element.id }
    }
    
    func invalidate() {
        timerElements.forEach { $0.invalidate() }
    }
}
