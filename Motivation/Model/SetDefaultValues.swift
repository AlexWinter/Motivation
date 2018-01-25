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

    if (defaults.bool(forKey: UserDefaults.Keys.HasLaunchedOnce)) {
        // App already launched
        NotificationSound.individual = defaults.bool(forKey: UserDefaults.Keys.IndividualNotificationSound)
        TimeFrame.start = (defaults.object(forKey: UserDefaults.Keys.StartTime) as? Date)!
        TimeFrame.end = (defaults.object(forKey: UserDefaults.Keys.EndTime) as? Date)!
        HighlightLastSlogan.isOn = defaults.bool(forKey: UserDefaults.Keys.HighlightLastSloganKey)
    } else {
        // This is the first launch ever
        // Set Notification Sound to individual = true
        defaults.set(true, forKey: UserDefaults.Keys.HasLaunchedOnce)
        defaults.set(true, forKey: UserDefaults.Keys.IndividualNotificationSound)
        defaults.set(true, forKey: UserDefaults.Keys.HighlightLastSloganKey)
        NotificationSound.individual = true
        HighlightLastSlogan.isOn = true
        
        // Set Time Frame for Notification to 9:00 to 18:00
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = dateFormatter.date(from: "09:00") {
            TimeFrame.start = date
        }
        if let date = dateFormatter.date(from: "18:00") {
            TimeFrame.end = date
        }
        
        defaults.set(TimeFrame.start, forKey: UserDefaults.Keys.StartTime)
        defaults.set(TimeFrame.end, forKey: UserDefaults.Keys.EndTime)
    }
}
