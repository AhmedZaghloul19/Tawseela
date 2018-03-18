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
import Kingfisher
import PopupDialog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,UNUserNotificationCenterDelegate, MessagingDelegate{

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // 200 MB
        ImageCache.default.maxDiskCacheSize = UInt(200 * 1024 * 1024)
        // 3 days
        ImageCache.default.maxCachePeriodInSecond = TimeInterval(60 * 60 * 24 * 3)
        
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
        
//        let json: NSDictionary = convertToDictionary(text: userInfo["google.c.a.c_l"] as! String)! as NSDictionary
        let recievedNotification = AppNotification(data: userInfo as AnyObject)
        
        switch recievedNotification.kind! {
        case .driverRate:
            if recievedNotification.id ?? "" != "" {
                let storyboard  = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "RatingPopVC") as! RatingPopVC
                vc.ratingForCustomer = false
                vc.ID = recievedNotification.id ?? ""
                let popup = PopupDialog(viewController: vc, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 340, gestureDismissal: false, hideStatusBar: false, completion: nil)
                DispatchQueue.main.async {
                    self.window?.rootViewController?.present(popup, animated: true, completion: nil)
                }
            }
        default:
            break
        }
        
        

//        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let identifier = userAlreadyExist() ? (CURRENT_USER?.user?.type! == .Customer ? "RootCustomerTabBar" : "RootDriverTabBar" ): "LoginVC"
//        let tabbar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: identifier) as! UITabBarController
//
//        let navVC = tabbar.viewControllers![1] as! UINavigationController
//        let ordersVC = navVC.viewControllers[0] as! OrdersVC
//
//        if recievedNotification.kind == NotificationType.driverRate {
//            ordersVC.checkForRatingDriverWith(ID: recievedNotification.id ?? "")
//        }
        self.window?.makeKeyAndVisible()
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {        print(fcmToken)

    }
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
}

