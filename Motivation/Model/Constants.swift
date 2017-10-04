//
//  Constants.swift
//  Motivation
//
//  Created by Alex Winter on 28.09.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import Foundation
import UIKit

var textInWidget: String = ""

enum Constants {
    struct myColor {
        static let fullAlpha = UIColor(red: 80/255, green: 125/255, blue: 160/255, alpha: 1.0)
        static let halfAlpha = UIColor(red: 80/255, green: 125/255, blue: 160/255, alpha: 0.5)
    }
}

// Default values are 9:00 and 18:00. They get set in AppDelegate.
struct TimeFrame {
    static var start: Date = Date()
    static var end: Date = Date()
}

// Default values is true. It get's set in AppDelegate.
struct NotificationSound {
    static var individual: Bool = true
}

extension Notification.Name {
    static let reload = Notification.Name("Reload")
    static let timeFrameChanged = Notification.Name("TimeFrameChanged")
    static let openFromNotification = Notification.Name("notificationActionReceived")
    static let openFromWidget = Notification.Name("OpenFromWidget")
}

extension UserDefaults {
    enum Keys {
        static let IndividualNotificationSound = "IndividualNotificationSound"
        static let StartTime = "StartTime"
        static let EndTime = "EndTime"
        static let HasLaunchedOnce = "HasLaunchedOnce"
        static let NotificationsAlreadyScheduled = "NotificationsAlreadyScheduled"
        static let ExtensionText = "ExtensionText"
    }
}
