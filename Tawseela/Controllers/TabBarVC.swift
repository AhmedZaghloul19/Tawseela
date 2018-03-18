//
//  TabBarVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/16/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class TabBarVC: UITabBarController {
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("orders")
    private lazy var driversRef: DatabaseReference = Database.database().reference().child("drivers")

    private var channelRefHandle: DatabaseHandle?
    var orders :[Order] = []
    var requests:[Order] = []
    var deliveries:[Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.items![0].title = "places".localized()
        self.tabBar.items![1].title = "orders".localized()

        if CURRENT_USER?.user?.type == .Driver {
            self.tabBar.items![2].title = "notification".localized()
            self.tabBar.items![3].title = "delivery".localized()
            self.tabBar.items![4].title = "my_profile".localized()
        self.driversRef.child((CURRENT_USER?.mobile!)!).setValue(Messaging.messaging().fcmToken)
        }else{
            self.tabBar.items![2].title = "my_profile".localized()
        }
        observeOrders()
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK: Firebase related methods
    private func observeOrders() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded , with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            if let userPhone = channelData["user_phone"] as! String!, userPhone.count > 0 { // 3
                if userPhone == (CURRENT_USER?.mobile!)!{
                    let order = Order(data: snapshot.value as AnyObject)
                    order.id = snapshot.key
                    self.orders.append(order)
                }
            }
            
            if CURRENT_USER?.user?.type == .Driver {
                if let userPhone = channelData["driver_phone"] as! String!{ // 3
                    if userPhone == (CURRENT_USER?.mobile!)!{
                        let order = Order(data: snapshot.value as AnyObject)
                        order.id = snapshot.key
                        self.deliveries.append(order)
                    }
                    DispatchQueue.main.async {
                        self.tabBar.items![3].badgeValue = self.deliveries.count != 0 ? "\(self.deliveries.count)" : nil
                    }
                }
                
                if let st = channelData["state"] as! String!, st.count > 0 { // 3
                    let state = State(rawValue: st)
                    if state == .RequestInProgress{
                        let order = Order(data: snapshot.value as AnyObject)
                        order.id = snapshot.key
                        self.requests.append(order)
                    }
                    DispatchQueue.main.async {
                        self.tabBar.items![2].badgeValue = self.requests.count != 0 ? "\(self.requests.count)" : nil
                    }
                }
            }
            DispatchQueue.main.async {
                self.tabBar.items![1].badgeValue = self.orders.count != 0 ? "\(self.orders.count)" : nil
            }
        })
    }

}
