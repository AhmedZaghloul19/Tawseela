//
//  NotificationsVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/17/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase

class NotificationsVC: BaseViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView:UITableView!
    private lazy var usersRef: DatabaseReference = Database.database().reference().child("users")
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("orders")
    private var channelRefHandle: DatabaseHandle?
    var orders :[Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func getData() {
        super.getData()
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
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            self.activityIndicator.startAnimating()
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            
            if let st = channelData["state"] as! String!, st.count > 0 { // 3
                let state = State(rawValue: st)
                if state == .RequestInProgress{
                    let order = Order(data: snapshot.value as AnyObject)
                    order.id = snapshot.key
                    self.usersRef.child(order.user_phone!).observeSingleEvent(of: .value, with: { (userSnapshot) in
                        let user = User(data: userSnapshot.value as AnyObject)
                        var userRatesSummation:Double = 0
                        for rate in user.user_rates {
                            userRatesSummation += rate.rate!
                        }
                        let avgUserRates = userRatesSummation / Double(user.user_rates.count)
                        user.usersRateAvg = avgUserRates > 0 ? avgUserRates : 5
                        order.requestedUser = user
                        self.orders.append(order)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })

                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
//                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.errorView.isHidden = false
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let order = sender as? Order , let vc = segue.destination as? RequestsDetailsVC{
            vc.order = order
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RatingCell
        cell.titleLabel.text = orders[indexPath.row].requestedUser?.name!
        cell.subtitleLabel.text = orders[indexPath.row].date!
        cell.ratingView.rating = (orders[indexPath.row].requestedUser?.usersRateAvg!)!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "RequestDetails", sender: orders[indexPath.row])
    }
}
