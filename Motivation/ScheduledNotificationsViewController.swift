//
//  ScheduledNotificationsViewController.swift
//  Motivation
//
//  Created by Alex Winter on 22.09.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit

class ScheduledNotificationsViewController: UIViewController {

    var slogans = [Slogan]()

    @IBOutlet weak var textview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textview.text = ""

        if let loadedData = loadData() {
            slogans += loadedData
        }
        
        slogans = slogans.sorted(by: { $0.fireDay.compare($1.fireDay) == .orderedAscending })
        
        for saying in slogans {
            let calendar = Calendar.current
            
            let day = calendar.component(.day, from: saying.fireDay)
            let month = calendar.component(.month, from: saying.fireDay)
            let year = calendar.component(.year, from: saying.fireDay)
            let hour = calendar.component(.hour, from: saying.fireDay)
            let minutes = calendar.component(.minute, from: saying.fireDay)

            textview.text = textview.text + "\(String(format: "%02d", day)).\(String(format: "%02d", month)).\(year) \(String(format: "%02d", hour)):\(String(format: "%02d", minutes))   " + saying.headline + "\n"
        }
    }
    
    func loadData() -> [Slogan]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Slogan.ArchiveURL.path) as? [Slogan]
    }
    
    override func viewDidLayoutSubviews() {
        self.textview.setContentOffset(.zero, animated: false)
    }
}
