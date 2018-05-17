//
//  TippsViewController.swift
//  Motivation
//
//  Created by Alex Winter on 30.03.18.
//  Copyright © 2018 Alex Winter. All rights reserved.
//

import UIKit

class TippsViewController: UIViewController {

    @IBOutlet weak var go: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        go.layer.cornerRadius = 8
    }

    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
