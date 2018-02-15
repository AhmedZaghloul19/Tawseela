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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GMSPlacesClient.provideAPIKey(GOOGLE_PLACES_API_KEY)
        GMSServices.provideAPIKey(GOOGLE_PLACES_API_KEY)
//        GMSServices.provideAPIKey("AIzaSyB6RXiyFyFljpeVl1SO1Vw1Ro0oazNBTBE")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = userAlreadyExist() ? "RootCustomer" : "LoginVC"
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        self.window?.rootViewController = controller
        
        return true
    }
}

