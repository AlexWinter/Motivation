//
//  NotificationManager.swift
//  Motivation
//
//  Created by Alex Winter on 24.08.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    let center = UNUserNotificationCenter.current()

    func requestSendingNotifications() {
        center.delegate = self

        center.getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                })
                break
            case .authorized:
                break
            case .denied:
                print("Application Not Allowed to Display Notifications")
                break
            }
        }
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            //actions definition
            let action1 = UNNotificationAction(identifier: "action1", title: "Anzeigen", options: [.foreground])
            let action2 = UNNotificationAction(identifier: "action2", title: "Ignorieren", options: [.destructive])
            let category = UNNotificationCategory(identifier: "actionCategory", actions: [action1,action2], intentIdentifiers: [], options: [])
            
            self.center.setNotificationCategories([category])
            completionHandler(success)
        }
    }
    
    func scheduleNotification(with title: String, text: String, date: Date ) {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Hier der Spruch für heute:"
        notificationContent.subtitle = title
        notificationContent.body = text
        notificationContent.sound = UNNotificationSound(named: "DiDiDiDiDi.m4a")
        notificationContent.categoryIdentifier = "actionCategory"
        notificationContent.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
        notificationContent.userInfo = ["title":title]
        
        // Add Trigger
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date) , repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "motivation_local_notification" + title, content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        center.add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }

    func testLocalNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "TEST"
        notificationContent.subtitle = "Test"
        notificationContent.body = "Das ist ein Test"
        if NotificationSound.individual {
            notificationContent.sound = UNNotificationSound(named: "DiDiDiDiDi.m4a")
            notificationContent.body = "Individueller Sound"
        } else {
            notificationContent.sound = UNNotificationSound.default()
            notificationContent.body = "Standard Sound"
        }
        notificationContent.categoryIdentifier = "actionCategory"
        notificationContent.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
        notificationContent.userInfo = ["title":"Gestaltgebet"]
        
        // Add Trigger
//        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date) , repeats: false)
        let notificationTrigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 3, repeats: false)
    
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "motivation_local_notification" + "Gestaltgebet", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        center.add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // For handling tap and user actions
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "action1":
            NotificationCenter.default.post(name: .openFromNotification, object: nil, userInfo: userInfo)
        case "action2":
            print("Ignorieren Tapped")
        default:
            break
        }
        completionHandler()
    }
    
    func reScheduleAllNotificationsWithTheNewSound() {
        let arrayOfNotifications: [UNNotificationRequest] = []

        center.getPendingNotificationRequests(completionHandler: { (notifications) in
            for notification in notifications{
                let content = UNMutableNotificationContent()
                content.title = notification.content.title
                content.subtitle = notification.content.subtitle
                content.body = notification.content.body
                if NotificationSound.individual {
                    content.sound = UNNotificationSound(named: "DiDiDiDiDi.m4a")
                } else {
                    content.sound = UNNotificationSound.default()
                }

                content.userInfo = notification.content.userInfo
                content.categoryIdentifier = notification.content.categoryIdentifier

            }
        })

        for notification in arrayOfNotifications {
            center.add(notification, withCompletionHandler: nil)
        }
    }
}
