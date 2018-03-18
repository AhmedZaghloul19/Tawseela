//
//  OrdersVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/9/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase
import PopupDialog                            

class OrdersVC: BaseViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView:UITableView!
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("orders")
    private var channelRefHandle: DatabaseHandle?
    var orders :[Order] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "orders".localized()
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

            if let userPhone = channelData["user_phone"] as! String!, userPhone.count > 0 { // 3
                if userPhone == (CURRENT_USER?.mobile!)!{
                    let order = Order(data: snapshot.value as AnyObject)
                    order.id = snapshot.key
                    self.orders.append(order)
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let order = sender as? Order {
            if order.state == .RequestInProgress {
                if let vc = segue.destination as? OrderRequestsVC {
                    vc.orderID = order.id!
                }
            }else if order.state == .Done {
                if let vc = segue.destination as? RequestsDetailsVC {
                    vc.order = order
                }
            }else{
                if let vc = segue.destination as? RequestProgressVC {
                    vc.order = order
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = orders[indexPath.row].state!.rawValue
        cell.detailTextLabel?.text = orders[indexPath.row].date!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if orders[indexPath.row].state == .RequestInProgress {
            self.performSegue(withIdentifier: "showRequests", sender: orders[indexPath.row])
        }else if orders[indexPath.row].state == .Done {
            self.performSegue(withIdentifier: "OrderDetails", sender: orders[indexPath.row])
        }else{
            self.performSegue(withIdentifier: "OrderProgress", sender: orders[indexPath.row])
        }
    }
    
    func checkForRatingDriverWith(ID:String) {
        self.navigationController?.tabBarController?.selectedIndex = 1
        if ID != "" {
            let storyboard  = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RatingPopVC") as! RatingPopVC
            vc.ratingForCustomer = false
            vc.ID = ID
            let popup = PopupDialog(viewController: vc, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 340, gestureDismissal: false, hideStatusBar: false, completion: nil)
            self.present(popup, animated: true, completion: nil)
        }
    }
}
