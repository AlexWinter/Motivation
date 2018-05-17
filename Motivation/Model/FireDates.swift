//
//  FireDates.swift
//  Motivation
//
//  Created by Alex Winter on 01.09.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import Foundation

extension Date {
    func calculateFireDate(daysAdding: Int) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = .current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())

        let (startHour, startMinute) = intFromTime(date: TimeFrame.start)
        let (endHour, endMinute) = intFromTime(date: TimeFrame.end)

        components.day = components.day! + daysAdding
        
        
        var tempCalculation = 0
        if (endHour - startHour > 0) {
            tempCalculation = Int(arc4random_uniform(UInt32(endHour - startHour)))
        }
        components.hour = startHour + tempCalculation

        if startHour == endHour {
            components.minute = startMinute + Int(arc4random_uniform(UInt32(endMinute)))
        } else if components.hour == startHour {
            components.minute = startMinute + Int(arc4random_uniform(UInt32(60)))
        } else if components.hour == endHour {
            components.minute = Int(arc4random_uniform(UInt32(endMinute)))
        } else {
            components.minute = 0 + Int(arc4random_uniform(UInt32(60)))
        }
        return Calendar.current.date(from: components)!
    }

    func intFromTime(date: Date) -> (Int, Int) {
        var calendar = Calendar.current
        calendar.timeZone = .current
        var components = calendar.dateComponents([.hour, .minute], from: date)

        return (Int(components.hour!), (Int(components.minute!)))
    }
}
