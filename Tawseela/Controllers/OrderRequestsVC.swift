//
//  OrderRequestsVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/13/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class OrderRequestsVC: BaseViewController ,UITableViewDelegate,UITableViewDataSource,RequestDelegate{
    
    @IBOutlet weak var tableView:UITableView!
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("orders")
    private lazy var usersRef: DatabaseReference = Database.database().reference().child("users")
    
    private var channelRefHandle: DatabaseHandle?
    var driver_offers : [Request] = []
    var orderID:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func getData() {
        super.getData()
        self.activityIndicator.stopAnimating()
        observeOrders()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RequestProgressVC ,let request = sender as? Request{
            let order = Order(data: ["driver_phone":request.user_phone] as AnyObject)
            order.user_phone = request.user_phone!
            vc.order = order
            vc.phone = request.user_phone!
            vc.newChat = true
        }
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
        channelRefHandle = channelRef.child(orderID).child("driver_offers").observe(.childAdded, with: { (snapshot) -> Void in // 1
            self.activityIndicator.startAnimating()
            self.usersRef.child(snapshot.key).observeSingleEvent(of: .value, with: { (userSnapshot) in
                let user = User(data: userSnapshot.value as AnyObject)
                var userRatesSummation:Double = 0
                for rate in user.user_rates {
                    userRatesSummation += rate.rate!
                }
                let avgUserRates = userRatesSummation / Double(user.user_rates.count)

                var driverRatesSummation:Double = 0
                for rate in user.driver_rates {
                    driverRatesSummation += rate.rate!
                }
                let avgdriverRates = driverRatesSummation / Double(user.user_rates.count)

                let req = Request(user_phone: snapshot.key, value: snapshot.value as? String,user:user,user_rate:avgUserRates > 0 ? avgUserRates : 5,driver_rate: avgdriverRates > 0 ? avgdriverRates : 5)
                self.driver_offers.append(req)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    func didConfirmedOn(request: Request) {
        //else if let vc = segue.destination as? RequestProgressVC {
//        vc.order = order
//    }
        let alert = UIAlertController(title: "Confirm Request", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
        self.channelRef.child(self.orderID!).child("driver_phone").setValue(request.user_phone!)
        self.channelRef.child(self.orderID!).child("state").setValue(State.Delivering.rawValue)
        self.channelRef.child(self.orderID!).child("pay").setValue("no")
        self.channelRef.child(self.orderID!).child("price").setValue(request.value!, withCompletionBlock:{ (error, _) in
            if (error == nil){
                self.performSegue(withIdentifier: "OrderProgress", sender: request)
            }else{
                DispatchQueue.main.async {
                    self.errorView.isHidden = false
                }
            }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return driver_offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RatingCell
        cell.titleLabel.text = driver_offers[indexPath.row].user?.name!
        cell.subtitleLabel.text = "Delivery Price : " + driver_offers[indexPath.row].value! + "£"
        cell.ratingView.rating = driver_offers[indexPath.row].driver_rate!
        let url = URL(string: (driver_offers[indexPath.row].user?.image!)!)
        cell.placeIcon.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_avatarmdpi"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
        }, completionHandler: { image, error, cacheType, imageURL in
        })
        cell.request = driver_offers[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    @IBAction func cancelOrder(){
        self.channelRef.child(orderID!).removeValue()
        self.backTapped(nil)
    }
    
}

