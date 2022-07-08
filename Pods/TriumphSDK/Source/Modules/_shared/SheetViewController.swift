//
//  SheetViewController.swift
//  TriumphSDK
//
//  Created by Maksim Kalik on 6/28/22.
//

import Foundation

class SheetViewController: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        if hasSetPointOrigin == false {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        guard translation.y >= 0 else { return }
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin.y + translation.y)
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin
                }
            }
        }
    }
}
