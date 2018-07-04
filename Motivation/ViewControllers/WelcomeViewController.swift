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
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var headlineTextView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        go.layer.cornerRadius = 8
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bodyTextView.contentOffset = CGPoint.zero

        bodyTextView.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)
        go.titleLabel?.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Avenir Next", size: 16)!)

        bodyTextView.adjustsFontForContentSizeCategory = true
        go.titleLabel?.adjustsFontForContentSizeCategory = true
    }

    @IBAction func startApp(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
}
