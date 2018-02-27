//
//  CartVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/10/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlacePicker
import Firebase

class CartVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView:UITableView!
    
    var destinationCoordinate:CLLocationCoordinate2D!{
        didSet{
            self.getAddressFromLocation(center: self.destinationCoordinate)
        }
    }
    var destinationAddress:String = ""
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("orders")

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CART_ORDERS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = CART_ORDERS[indexPath.row].name!
        cell.detailTextLabel?.text = CART_ORDERS[indexPath.row].details!
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = CART_ORDERS[indexPath.row].details!
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                CART_ORDERS[indexPath.row].details! = alert.textFields!.first!.text!
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            CART_ORDERS.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        
        return [deleteAction, editAction]
    }
    
    @IBAction func doneTapped(){
        if CART_ORDERS.count != 0 {
            if destinationCoordinate == nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "", message: "Set your pickup location first", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.pickPlace()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{
                let newOrderContent:[String : Any] = [
                    "date": Date().getStringFromDate(),
                    "del_address": destinationAddress,
                    "del_lat":destinationCoordinate.latitude,
                    "del_lng":destinationCoordinate.longitude,
                    "state": "جاري الطلب",
                    "user_phone": (CURRENT_USER?.mobile!)!,
                    ]
                let newOrderRef = self.channelRef.childByAutoId()
                newOrderRef.setValue(newOrderContent)
                
                for order in CART_ORDERS {
                    let orderDetailsContent:[String:Any] = ["address":order.address!,
                        "details":order.details!,
                        "lat":order.lat!,
                        "lng":order.lng!,
                        "name":order.name!,
                        ]
                    newOrderRef.child("order_details").childByAutoId().setValue(orderDetailsContent)
                }
                CART_ORDERS.removeAll()
                userData.removeObject(forKey: "cart_orders")
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Your Order Request has been sent successfully", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.backTapped(nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }

            }
        }
    }
    
    @IBAction func pickPlace() {
        if currentCoordinate != nil {
            var coor = destinationCoordinate
            if destinationCoordinate == nil {
                coor = currentCoordinate
            }
            let center = CLLocationCoordinate2D(latitude: (coor?.latitude)! , longitude: (coor?.longitude)! )
            let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
            let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let config = GMSPlacePickerConfig(viewport: viewport)
            
            let placePicker = GMSPlacePicker(config: config)
            
            placePicker.pickPlace(callback: {(place, error) -> Void in
                if let error = error {
                    print("Pick Place error: \(error.localizedDescription)")
                    return
                }
                
                if let place = place {
                    self.destinationCoordinate = place.coordinate
                } else {
                    print("No place selected")
                    
                }
            })
        }
    }
    
    func getAddressFromLocation(center:CLLocationCoordinate2D){
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        let ceo: CLGeocoder = CLGeocoder()
        var addressString = ""
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality!
                    }
                    self.destinationAddress = (addressString)
                }
        })
    }
}
