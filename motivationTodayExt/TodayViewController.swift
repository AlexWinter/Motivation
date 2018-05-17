//
//  TodayViewController.swift
//  motivationTodayExt
//
//  Created by Alex Winter on 05.09.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var textLabel: UILabel!
    var slogans: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
// If an error is encountered, use NCUpdateResult.Failed
// If there's no update required, use NCUpdateResult.NoData
// If there's an update, use NCUpdateResult.NewData
        
        let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")

        if let data2 = defaults?.value(forKey: "widgetData") as? NSData {
            if let arr = NSKeyedUnarchiver.unarchiveObject(with: data2 as Data) as? [String] {
                textLabel.text = String(arr[Int(arc4random_uniform(UInt32(arr.count)))])
                completionHandler(NCUpdateResult.newData)
            } else {
                completionHandler(NCUpdateResult.noData)
            }
        }
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 200) : maxSize
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")
        defaults?.set(textLabel.text, forKey: "ExtensionText")

        let myAppUrl = URL(string: "main-screen:")!
        extensionContext?.open(myAppUrl, completionHandler: { (success) in
            if (!success) {
                print("error: failed to open app from Today Extension")
            }
        })
    }
}
