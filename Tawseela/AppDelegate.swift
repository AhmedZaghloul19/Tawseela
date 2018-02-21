//
//  AppDelegate.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/7/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps
import FirebaseMessaging
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,UNUserNotificationCenterDelegate, MessagingDelegate{

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        GMSPlacesClient.provideAPIKey(GOOGLE_PLACES_API_KEY)
        GMSServices.provideAPIKey(GOOGLE_PLACES_API_KEY)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = userAlreadyExist() ? (CURRENT_USER?.user?.type! == .Customer ? "RootCustomer" : "RootDriver" ): "LoginVC"
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        self.window?.rootViewController = controller
        
        registerForPushNotifications()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            self.getNotificationSettings()
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
//        let json: NSDictionary = convertToDictionary(text: userInfo["gcm.notification.object"] as! String)! as NSDictionary
//        let recievedNotification = AppNotification(data: json)
//
//        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let tabbar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "rootHome") as! UITabBarController
//        window?.rootViewController = tabbar
//        tabbar.selectedIndex = 2
//        let navVC = tabbar.viewControllers![2] as! UINavigationController
//        let notificationVC = navVC.viewControllers[0] as! NotificationsVC
//        notificationVC.selectedID = recievedNotification.object?.id!
//        notificationVC.checkNotificationAction(target: recievedNotification.target!, tapped: recievedNotification)
//        self.window?.makeKeyAndVisible()
//        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {        print(fcmToken)

    }
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
}

