//
//  TutorialController.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 6/7/22.
//

import UIKit

class TutorialController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: .enablePageControlInteraction, object: nil)
    }
}
