//
//  SetDefaultValues.swift
//  Motivation
//
//  Created by Alex Winter on 29.09.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import Foundation

func setValuesforFirstLaunch() {
    let defaults = UserDefaults.standard
    
    if (defaults.bool(forKey: "hasLaunchedOnce")) {
        // App already launched
//        alreadyLaunchedApp = true
        
        NotificationSound.individual = defaults.bool(forKey: "individualNotificationSound")
        TimeFrame.start = (defaults.object(forKey: "StartTime") as? Date)!
        TimeFrame.end = (defaults.object(forKey: "EndTime") as? Date)!
        
    } else {
//        alreadyLaunchedApp = false
        // This is the first launch ever
        // Set Notification Sound to individual = true
        defaults.set(true, forKey: "hasLaunchedOnce")
        defaults.set(true, forKey: "individualNotificationSound")
        NotificationSound.individual = true
        
        // Set Time Frame for Notification to 9:00 to 18:00
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = dateFormatter.date(from: "09:00") {
            TimeFrame.start = date
        }
        if let date = dateFormatter.date(from: "18:00") {
            TimeFrame.end = date
        }
        
        defaults.set(TimeFrame.start, forKey: "StartTime")
        defaults.set(TimeFrame.end, forKey: "EndTime")
    }
}
