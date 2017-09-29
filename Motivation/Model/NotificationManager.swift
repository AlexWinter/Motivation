//
//  NotificationManager.swift
//  Motivation
//
//  Created by Alex Winter on 24.08.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit
import UserNotifications

var pendingNotificationNames:String = ""
var pendingNotificationDates:String = ""

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    let center = UNUserNotificationCenter.current()

    func requestSendingNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            //actions definition
            let action1 = UNNotificationAction(identifier: "action1", title: "Anzeigen", options: [.foreground])
            let action2 = UNNotificationAction(identifier: "action2", title: "Ignorieren", options: [.destructive])
            let category = UNNotificationCategory(identifier: "actionCategory", actions: [action1,action2], intentIdentifiers: [], options: [])
            
            UNUserNotificationCenter.current().setNotificationCategories([category])

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
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }

    func testLocalNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "TEST"
        notificationContent.subtitle = "Gestaltgebet"
        notificationContent.body = "Das ist ein Test"
//        notificationContent.sound = UNNotificationSound(named: "DiDiDiDiDi.m4a")
        notificationContent.sound = UNNotificationSound.default()
        notificationContent.categoryIdentifier = "actionCategory"
        notificationContent.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
        notificationContent.userInfo = ["title":"Gestaltgebet"]
        
        // Add Trigger
//        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date) , repeats: false)
        let notificationTrigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 3, repeats: false)
    
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "motivation_local_notification" + "Gestaltgebet", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationActionReceived"), object: nil, userInfo: userInfo)
        case "action2":
            print("Ignorieren Tapped")
        default:
            break
        }
        completionHandler()
    }
}
