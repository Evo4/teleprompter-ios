//
//  SplitVC.swift
//  teleprompter-ios
//
//  https://sispo.co
//  Created for Robert Savage, Pronunciator, LLC
//  Copyright © 2018 Sispo. All rights reserved.
//

import UIKit

class SplitVC: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .allVisible
        let masterVC = UINavigationController(rootViewController: MasterVC())
        viewControllers = [masterVC]
    }
}

