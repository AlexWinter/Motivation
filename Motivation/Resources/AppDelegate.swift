//
//  AppDelegate.swift
//  Motivation
//
//  Created by Alex Winter on 22.08.17.
//  Copyright © 2017 Alex Winter. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var notificationManager : NotificationManager!
    var data = [Slogan]()
    var headlineInNotification: String = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let defaults = UserDefaults.standard
        if (defaults.bool(forKey: UserDefaults.Keys.HasLaunchedOnce)) {
            print("Not First Launch")
        } else {
            print("First Launch")

            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
            let initialViewController = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        notificationManager = NotificationManager()
        setValuesforFirstLaunch()

        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 28.0)!
            ]
        }
        openedFromExtension()
        return true
    }

    func openedFromExtension() {
        let defaults = UserDefaults(suiteName: "group.com.alexwinter.motivation")
        
        if (defaults?.value(forKey: UserDefaults.Keys.ExtensionText)) == nil {
            textInWidget = ""
        } else {
            textInWidget = defaults?.value(forKey: UserDefaults.Keys.ExtensionText) as! String
            defaults?.set(nil, forKey: UserDefaults.Keys.ExtensionText)
            NotificationCenter.default.post(name: .openFromWidget, object: nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "action1":
            openSloganFromNotification(userInfo: response)
        case "action2":
            print("Ignorieren Tapped")
        default:
            // User tapped directly on the Notification
            openSloganFromNotification(userInfo: response)
            break
        }
        completionHandler()
    }
    
    func openSloganFromNotification(userInfo:UNNotificationResponse) {
        if let notificationText:String = userInfo.notification.request.content.userInfo["title"] as! String? {
            headlineInNotification = notificationText
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        openedFromExtension()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
