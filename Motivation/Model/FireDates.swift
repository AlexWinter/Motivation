//
//  FireDates.swift
//  Motivation
//
//  Created by Alex Winter on 01.09.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import Foundation

func calculateFireDate(daysAdding: Int) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = .current
    var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())

    components.day = components.day! + daysAdding
    components.hour = 9 + Int(arc4random_uniform(8))
    components.minute = 0 + Int(arc4random_uniform(60))

    return Calendar.current.date(from: components)!
}
