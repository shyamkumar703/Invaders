//
//  TutorialViewController.swift
//  TriumphSDK
//
//  Created by Shyam Kumar on 5/23/22.
//

import UIKit
import TriumphCommon

class TutorialPageViewController: UIPageViewController {
    
    var viewModel: TutorialViewControllerViewModel? {
        didSet {
            updateView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightDark
        NotificationCenter.default.addObserver(self, selector: #selector(enableUserInteraction), name: .enablePageControlInteraction, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let nc = navigationController as? BaseNavigationController {
            nc.hideRightTopNavButton()
            nc.setupLeftTopNavButton(type: .close)
        }
    }
    
    @objc func enableUserInteraction() {
        view.isUserInteractionEnabled = true
    }
    
    func updateView() {
        guard let viewModel = viewModel else {
            return
        }
        delegate = viewModel
        dataSource = viewModel
        setViewControllers([viewModel.getInitialVC()], direction: .forward, animated: true, completion: nil)
    }
}
