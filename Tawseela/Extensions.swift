//
//  Extensions.swift
//  RKAnjel
//
//  Created by Ahmed Zaghloul .
//  Copyright © 2017 Ahmed Zaghloul. All rights reserved.
//

import UIKit
import CoreLocation
import Localize_Swift

let URL_IMAGE_PREFIX = "http://haseboty.com/Tawseela/"
let SERVICE_URL_PREFIX = "http://haseboty.com/Tawseela/"
let ACCOUNT_ID = 1
var GOOGLE_PLACES_API_KEY = "AIzaSyCTV_ohoqCYjpSfjtbt5WNbt0SsRAFrlek"
let NC = NotificationCenter.default

var CURRENT_USER:UserRecord? {
    didSet{
        debugPrint("Set")
    }
}
var currentCoordinate:CLLocationCoordinate2D!
var CART_ORDERS:[OrderDetails] = [] {
    didSet{
        debugPrint("Order Set")
        saveOrders()
        NC.post(name: Notification.Name("cartChanged"), object: nil)
    }
}

let appColor = UIColor(red: 238/255, green: 8/255, blue: 78/255, alpha: 1.0)

enum Gender:Int{
    case Male = 0
    case Female = 1
}

enum State:String{
    case RequestInProgress = "جاري الطلب"
    case Done = "تم التوصيل"
    case Delivering = "جاري التوصيل"
    case Other
}

enum NotificationType :String{
    case newOrder = "new_order";
    case newOffer = "new_offer";
    case userConfirmed = "offer_confirmed";
    case driverRate = "order_done";
    case newMessage = "new_msg";
    case pay = "pay";
}

enum Role:String{
    case Driver = "driver"
    case Customer = "user"
    case Other
}

let userData  = UserDefaults.standard

extension NSMutableURLRequest{
    func setBodyConfigrationWithMethod(method:String){
        self.httpMethod = method
        self.setValue("application/json",forHTTPHeaderField:"Accept")
//        self.setValue("application/json",forHTTPHeaderField:"Content-Type")
//        self.setValue("utf-8", forHTTPHeaderField: "charset")
    }
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

extension UITableView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.tableFooterView = UIView()
    }
}

func cacheUserData() {
    userData.set((CURRENT_USER?.mobile!)!, forKey: "mobile")
    userData.set((CURRENT_USER?.user?.name!)!, forKey: "name")
    userData.set((CURRENT_USER?.user?.image!)!, forKey: "image")
    userData.set((CURRENT_USER?.user?.token!)!, forKey: "token")
    userData.set((CURRENT_USER?.user?.type?.rawValue)!, forKey: "role")
}

func saveOrders(){
    let placesData = try! JSONEncoder().encode(CART_ORDERS)
    userData.set(placesData, forKey: "cart_orders")
}

func getOrders() -> [OrderDetails]?{
    let ordersData = userData.data(forKey: "cart_orders")
    let ordersArray = try! JSONDecoder().decode([OrderDetails].self, from: ordersData!)
    return ordersArray
}

func userAlreadyExist() -> Bool{
    
    if let _ = userData.value(forKey: "cart_orders") {
        if let cart = getOrders() {
            CART_ORDERS = cart
        }
    }

    if let mobile = userData.value(forKey: "mobile") as? String {
        CURRENT_USER = UserRecord()
        CURRENT_USER?.mobile = mobile
        CURRENT_USER?.user = User(id: "", name: userData.string(forKey: "name")!, image: userData.string(forKey: "image")!, token: userData.string(forKey: "token")!, type: Role(rawValue: userData.string(forKey: "role")!)!)
        return true
    }
    
    return false
}


extension UIView{
    
    func dropShadow(scale: Bool = true) {
        DispatchQueue.main.async {
            self.layer.masksToBounds = false
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.3
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.layer.shadowRadius = 1.5
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        }
    }

    func performConstraintsWithFormat(format:String,views:UIView...) {
        
        var viewsDic = [String:UIView]()
        
        for (index,view) in views.enumerated(){
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDic["v\(index)"] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDic))
        
    }
    
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}

func randomNumber(range: ClosedRange<Int> = 1...6) -> Int {
    let min = range.lowerBound
    let max = range.upperBound
    return Int(arc4random_uniform(UInt32(1 + max - min))) + min
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func reload(){
        self.viewDidLoad()
    }
    
    @IBAction func backTapped(_ sender: Any?) {
        if let _  = self.navigationController?.popViewController(animated: true){
            
        }
    }
}

enum VendingMachineError:Error {
    case valueNotFounds
}

extension Date{
    func getStringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy, HH:mm:ss"
        return formatter.string(from: self as Date)
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension NSDictionary {
    func getValueForKey<T>(key:String,callback:T)  -> T{
        guard let value  = self[key] as? T else{
            return callback}
        return value
    }
    func getValueForKey<T>(key:String) throws -> T{
        guard let value  = self[key] as? T else{throw VendingMachineError.valueNotFounds}
        return value
    }
}

extension UIViewController{
    func showAlertWithTitle(title:String?,message:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showFailedAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Failed", message: "Couldn't Get Your Data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { (action) in
                self.viewDidLoad()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                self.view.isUserInteractionEnabled = false
                self.backTapped(nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showNoData(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Sorry", message: "There's no data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension Localize{
    
    open class func isCurrentLanguageArabic() -> Bool{
        return Localize.currentLanguage() == "ar"
    }
    open class func isCurrentLanguageEnglish() -> Bool{
        return Localize.currentLanguage() == "en"
    }
    open class func setEnglishCurrentLanguage() {
        Localize.setCurrentLanguage("en")
    }
    open class func setArabicCurrentLanguage() {
        Localize.setCurrentLanguage("ar")
    }
    open class func getCurrentLanguage() -> AppLanguage{
        if  Localize.isCurrentLanguageEnglish(){
            return AppLanguage(rawValue: "en")!
        }
        return AppLanguage(rawValue: "ar")!
    }
    
}

extension UIImage {
    var jpeg: Data? {
        return UIImageJPEGRepresentation(self, 0.5)
    }
    var png: Data? {
        return UIImagePNGRepresentation(self)
    }
}

enum AppErrorCode:Int {
    case Success = 0
    case MobileAlreadyExists = 1
    case EmailAlreadyExists = 2
    case DatabaseConnectionError = 3
    case AccounIsNotActive = 4
    case WrongCobinationOfPasswordOrUsername = 5
    case YouMustDetermineAccountType = 6
    case UserDoesnotExist = 7
    case CodeDoesnotMatch = 8
    case unauthorized = 9
    case errorSendingSms = 10
    case requestAlreadyExists = 11
    case requestDoesnotExist = 12
    case ValidationError = 400
    case NotFound = 204
    case Down = 404    
}

public enum AppLanguage:String {
    case arabic = "ar"
    case english = "en"
}
