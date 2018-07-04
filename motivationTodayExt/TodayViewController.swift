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
        var newText: String = getLastSloganAlternative()
        if (newText != "") {
            textLabel.text = newText
            completionHandler(NCUpdateResult.newData)
            return
        } else {
            newText = getRandomSlogan()
            if (newText != "") {
                textLabel.text = newText
                completionHandler(NCUpdateResult.newData)
                return
            }
        }
    }
    
    func getLastSloganAlternative() -> String {
        var indexOfA: Int = 0

        let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")
        if let data1 = defaults?.value(forKey: "widgetTimes") as? Data {
            if let arr = NSKeyedUnarchiver.unarchiveObject(with: data1 as Data) as? [Date] {
                let now = Date()
                var distance: Double = 48 * 60 * 60
                var temp: Double = 0
                
                for timeStamp in arr {
                    temp = now.timeIntervalSince(timeStamp)
                    if (temp > 0 && temp < distance) {
                        distance = temp
                        indexOfA = arr.index(of: timeStamp)!
                    }
                }
            }
        }
        if (indexOfA != 0) {
            let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")
            if let data2 = defaults?.value(forKey: "widgetData") as? NSData {
                if let arr = NSKeyedUnarchiver.unarchiveObject(with: data2 as Data) as? [String] {
                    return String(arr[indexOfA])
                }
            }
        }
        return ""
    }

    func getRandomSlogan() -> String {
        let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")
        if let data2 = defaults?.value(forKey: "widgetData") as? NSData {
            if let arr = NSKeyedUnarchiver.unarchiveObject(with: data2 as Data) as? [String] {
                return String(arr[Int(arc4random_uniform(UInt32(arr.count)))])
            }
        }
        return ""
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
