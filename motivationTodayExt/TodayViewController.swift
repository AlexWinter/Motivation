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

        var newText: String = getLastSlogan()
        if (newText != "") {
//            textLabel.text = "Letzter Spruch \n" + newText
            textLabel.text = newText
            completionHandler(NCUpdateResult.newData)
            return
        } else {
            newText = getRandomSlogan()
            if (newText != "") {
//                textLabel.text = "Zufälliger Spruch \n" + newText
                textLabel.text = newText
                completionHandler(NCUpdateResult.newData)
                return
            }
        }
    }

    func getLastSlogan() -> String {
        var indexOfA: Int = 0
        
        let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")
        if let data1 = defaults?.value(forKey: "widgetTimes") as? Data {
            if let arr: [Date] = NSKeyedUnarchiver.unarchiveObject(with: data1) as? [Date] {
                if (arr.count == 0) {
                    return ""
                }

                if let closestDate = arr.sorted().first(where: {$0.timeIntervalSinceNow < 0}) {
//                    print(closestDate.description(with: .current))
                    indexOfA = arr.index(of: closestDate)!
                }
                
                if (indexOfA == 0) {
                    return ""
                }
                
                if let data2 = defaults?.value(forKey: "widgetData") as? Data {
                    if let arr2 = NSKeyedUnarchiver.unarchiveObject(with: data2) as? [String] {
                        return arr2[indexOfA]
                    }
                }
            }
        }
        return "Fehler"
    }

    func getRandomSlogan() -> String {
        let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")
        if let data2 = defaults?.value(forKey: "widgetData") as? NSData {
            if let arr = NSKeyedUnarchiver.unarchiveObject(with: data2 as Data) as? [String] {
//                textLabel.text = String(arr[Int(arc4random_uniform(UInt32(arr.count)))])
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
