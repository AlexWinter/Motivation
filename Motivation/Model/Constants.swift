//
//  Constants.swift
//  Motivation
//
//  Created by Alex Winter on 28.09.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import Foundation
import UIKit

enum Constants {
    struct myColor {
        static let fullAlpha = UIColor(red: 80/255, green: 125/255, blue: 160/255, alpha: 1.0)
        static let halfAlpha = UIColor(red: 80/255, green: 125/255, blue: 160/255, alpha: 0.5)
    }
}

struct TimeFrame {
    static var start: Date = Date()
    static var end: Date = Date()
}

extension Notification.Name {
    static let reload = Notification.Name("reload")
}
