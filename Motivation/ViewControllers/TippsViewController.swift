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
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var headlineLabel: UILabel!
    
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

    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
