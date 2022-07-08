//
//  ModalPresentationController.swift
//  TriumphSDK
//
//  Created by Maksim Kalik on 6/28/22.
//

import Foundation

class ModalPresentationController: UIPresentationController {
    
    var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    var fractionOfHeight: CGFloat = 0.5
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismiss))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.roundCorners([.topLeft, .topRight], radius: 12)
    }
    
    override func presentationTransitionWillBegin() {
        self.backgroundView.alpha = 0
        self.containerView?.addSubview(backgroundView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0.7
        }, completion: { _ in })
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0
        }, completion: { _ in
            self.backgroundView.removeFromSuperview()
        })
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        backgroundView.frame = containerView!.bounds
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let presentingView = containerView else { return CGRect.zero }
        let height = presentingView.frame.height * fractionOfHeight
        return CGRect(
            x: 0,
            y: presentingView.frame.height * (1 - fractionOfHeight),
            width: presentingView.frame.width,
            height: height
        )
    }
    
    @objc func dismiss() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
