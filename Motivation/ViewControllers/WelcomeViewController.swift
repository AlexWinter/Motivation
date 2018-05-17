//
//  WelcomeViewController.swift
//  Motivation
//
//  Created by Alex Winter on 06.02.18.
//  Copyright © 2018 Alex Winter. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var go: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        go.layer.cornerRadius = 8
    }

    @IBAction func startApp(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
}
