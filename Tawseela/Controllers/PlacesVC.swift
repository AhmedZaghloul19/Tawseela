//
//  PlacesVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/8/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import CoreLocation
import GooglePlacePicker

class PlacesVC: BaseViewController ,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var placesTypeBtn:UIButton!
    var orderDetailsTextfield:UITextField!
    
    let blackView = UIView()
    let picker = UIPickerView()
    let toolBar = UIToolbar()
    
    lazy var placesClient: GMSPlacesClient = GMSPlacesClient.shared()
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("types")
    
    private lazy var ordersRef: DatabaseReference = Database.database().reference().child("orders")
    
    var places :[Place] = []
    var row = 0
    var placeKey = "restaurant"
    var googlePlaces:[GooglePlacesItem] = []
    var locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placesTypeBtn.setTitle("restaurant", for: .normal)
        getCurrentPlace()
        placesPickerConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func getData() {
        super.getData()
        channelRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let place = Place(key: snap.key, value: snap.value as? String,selected:false)
                self.places.append(place)
            }
            self.placesTypeBtn.setTitle(self.places[0].key!, for: .normal)
//            self.getGooglePlaces()
            self.showPicker()

        }
    }
    
    func getGooglePlaces() {
        if currentCoordinate != nil {
            RequestManager.defaultManager.getPlacesFromGoogle(long:currentCoordinate.longitude , lat:currentCoordinate.latitude , WithType: self.placeKey, compilition: { (error, googlePlaces) in
                if !error{
                    DispatchQueue.main.async {//33.8670522,151.1957362
                        self.googlePlaces = googlePlaces!
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.errorView.isHidden = false
                    }
                }
        })
    }
    }
    
    func getCurrentPlace() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        if CLLocationManager.locationServicesEnabled()
//        {
//
            let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if status == CLAuthorizationStatus.notDetermined
            {
                locationManager.requestWhenInUseAuthorization()
            }else{
                
            }
        locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingLocation()
        currentCoordinate = locationManager.location?.coordinate
//        self.getGooglePlaces()
//        } else {
//            
//            print("locationServices disabled")
//            return
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googlePlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RatingCell
        cell.titleLabel.text = googlePlaces[indexPath.row].name!
        let url = URL(string: (googlePlaces[indexPath.row].icon)!)
        cell.placeIcon.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_avatarmdpi"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
        }, completionHandler: { image, error, cacheType, imageURL in
        })
        return cell
    }
    
    
    fileprivate func enterOrderData(_ place: GooglePlacesItem) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Set Order", message: "Enter The Order Details", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textfield) in
                self.orderDetailsTextfield = textfield
            })
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if self.orderDetailsTextfield.text! != ""{
                    let order = OrderDetails()
                    order.address = place.vicinity!
                    order.details = self.orderDetailsTextfield.text!
                    order.lat = place.lat!
                    order.lng = place.lng!
                    order.name = place.name!
                    CART_ORDERS.append(order)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        enterOrderData(self.googlePlaces[indexPath.row])
    }
    
    @IBAction func placeSelectionTapped(_ sender: UIButton) {
        showPicker()
    }
}

extension PlacesVC : UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return (places.count)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return places[row].key
    }
    
    func placesPickerConfiguration() {
        picker.delegate   = self
        picker.dataSource = self
        
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .blue
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "   Select", style: .done, target: self, action: #selector(PlacesVC.selectPlace(sender:)))
        
        toolBar.setItems([doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
    }
    
    @IBAction func selectPlace(sender:UITextField) {
        row = picker.selectedRow(inComponent: 0)
        placeKey = places[row].value!
        dismissBlackView()
        self.getGooglePlaces()
        self.placesTypeBtn.setTitle(places[row].key, for: .normal)
    }
    
    func showPicker(){
        if let window = UIApplication.shared.keyWindow{
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissBlackView)))
            //
            window.addSubview(blackView)
            window.addSubview(picker)
            window.addSubview(toolBar)
            
            let y = window.frame.height - 200
            
            picker.frame = CGRect(x: 0, y: self.view.frame.height + toolBar.frame.height, width: self.view.frame.width, height: 200)
            toolBar.frame.origin.y = picker.frame.origin.y - toolBar.frame.height
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.picker
                    .frame = CGRect(x: 0,y: y,width: self.view.frame.width,height: self.picker.frame.height )
                self.toolBar.frame.origin.y = self.picker.frame.origin.y - self.toolBar.frame.height
            }, completion: nil)
        }
    }
    
    @IBAction func dismissBlackView(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.picker.frame = CGRect(x: 0,y: self.blackView.frame.height,width: self.blackView.frame.width,height: 200)
            self.toolBar.frame.origin.y = self.picker.frame.origin.y - self.toolBar.frame.height
            self.blackView.alpha = 0
            self.picker.removeFromSuperview()
            self.toolBar.removeFromSuperview()
        },completion: nil)
    }
    
    @IBAction func pickPlace(_ sender: UIButton) {
        if currentCoordinate != nil {
            let center = CLLocationCoordinate2D(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
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
                    let orderPlace:GooglePlacesItem = GooglePlacesItem(id: "", icon: "", name: place.name, lat: Float(place.coordinate.latitude), lng: Float(place.coordinate.longitude), vicinity: place.formattedAddress ?? "")
                    self.enterOrderData(orderPlace)
                } else {
                    print("No place selected")

                }
            })
        }
    }
}

extension PlacesVC:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentCoordinate = locations.last?.coordinate
    }
}
