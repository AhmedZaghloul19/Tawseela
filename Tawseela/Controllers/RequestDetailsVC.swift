//
//  RequestDetailsVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/19/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class RequestsDetailsVC: BaseViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var placeTitleLabel:UILabel!
    @IBOutlet weak var placeSubtitleLabel:UILabel!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var offerTextfield:UITextField!
    @IBOutlet weak var confirmBtn:UIButton!

    private lazy var channelRef: DatabaseReference = Database.database().reference().child("orders")

    var order :Order!
    var orderDetails :[OrderDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100

        self.placeTitleLabel.text = self.order.del_address!
        self.placeSubtitleLabel.text = self.order.user_phone!
        
        if self.offerTextfield == nil {
            self.confirmBtn.setTitle("Delivery Price: \(self.order.price!) LE", for: .normal) 
        }
    }
    
    override func getData() {
        super.getData()
        
        self.channelRef.child(self.order.id!).child("order_details").observeSingleEvent(of: .value, with: { (snap) in
            self.activityIndicator.startAnimating()
            for detail in snap.children {
                let snp = detail as! DataSnapshot
                let det = OrderDetails(data: snp.value as AnyObject)
                self.orderDetails.append(det)
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        })

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RatingCell
        cell.titleLabel.text = orderDetails[indexPath.row].name!
        cell.subtitleLabel.text = orderDetails[indexPath.row].address!
        cell.secondSubtitleLabel.text = orderDetails[indexPath.row].details!
        
        return cell
    }
    
    @IBAction func confirmBtnTapped() {
        if !(offerTextfield.text?.isEmpty)! {
            self.channelRef.child(self.order.id!).child("driver_offers").child((CURRENT_USER?.mobile!)!).setValue(self.offerTextfield.text!, withCompletionBlock: { (error, ref) in
                if error == nil {
                    self.showAlertWithTitle(title: "Success", message: "Offer Set Successfully")
                }
            })
        }
    }
    
    @IBAction func getDirectionsTapped(_ sender: Any) {
        let regionDistance:CLLocationDistance = 1000
        print("long:\((self.order?.del_lng!)!)")
        print("lat:\((self.order?.del_lat!)!)")
        let coordinates = CLLocationCoordinate2DMake(CLLocationDegrees((self.order?.del_lat!)!),CLLocationDegrees((self.order?.del_lng!)!))
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = ((self.order?.del_address!)!)
        mapItem.openInMaps(launchOptions: options)
    }
    
}

