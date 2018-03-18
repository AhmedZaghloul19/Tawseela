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
    
    @IBOutlet var embededViewBottomLayoutConstraint: NSLayoutConstraint?

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
        tableView.estimatedRowHeight = 60
        self.hideKeyboardWhenTappedAround()
        
        if order.del_address! != ""{
            self.placeTitleLabel.text = self.order.del_address!
        }else{
            self.placeTitleLabel.text = self.order.requestedUser?.name!
        }
        self.placeSubtitleLabel.text = self.order.user_phone!
        
        if self.offerTextfield == nil {
            self.confirmBtn.setTitle("Delivery Price: \(self.order.price!) LE", for: .normal) 
        }else{
            self.confirmBtn.setTitle("confirm".localized(), for: .normal)
        }
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardNotification(notification:)),name: NSNotification.Name.UIKeyboardWillChangeFrame,object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.embededViewBottomLayoutConstraint?.constant = 0.0
            } else {
                self.embededViewBottomLayoutConstraint?.constant = ((endFrame?.size.height) ?? 0.0) * -1
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemCoordinate = CLLocationCoordinate2D(latitude: Double(orderDetails[indexPath.row].lat ?? 0), longitude: Double(orderDetails[indexPath.row].lng ?? 0))
        
        self.getDirectionsTo(coordinates: itemCoordinate)
    }
    
    @IBAction func confirmBtnTapped() {
        if !(offerTextfield.text?.isEmpty)! {
            self.channelRef.child(self.order.id!).child("driver_offers").child((CURRENT_USER?.mobile!)!).setValue(self.offerTextfield.text!, withCompletionBlock: { (error, ref) in
                if error == nil {
                    let alert = UIAlertController(title: nil, message: "driver_offer_sent".localized(), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                        self.backTapped(nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }else{
            self.showAlertWithTitle(title: nil, message: "warnning_empty_price".localized())
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
    
    func getDirectionsTo(coordinates:CLLocationCoordinate2D) {
        let regionDistance:CLLocationDistance = 1000

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

