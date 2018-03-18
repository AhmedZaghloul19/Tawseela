//
//  RequestProgressVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/20/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import FloatRatingView
import Firebase
import Kingfisher
import PopupDialog

class RequestProgressVC: BaseViewController ,RatingDelegate{

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subtitleLabel:UILabel!
    @IBOutlet weak var reviewBtn:UIButton!
    @IBOutlet weak var doneBtn:UIBarButtonItem!

    @IBOutlet weak var callBtn:UIButton!
    @IBOutlet weak var driverImageView:UIImageView!
    @IBOutlet weak var ratingView:FloatRatingView!
    
    private lazy var usersRef: DatabaseReference = Database.database().reference().child("users")
    private lazy var ordersRef: DatabaseReference = Database.database().reference().child("orders")

    var order :Order!
    var driver:User? {
        didSet{
            self.performSegue(withIdentifier: "ShowChat", sender: nil)
        }
    }
    
    var phone:String!
    var newChat:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.doneBtn?.title = "done".localized()
        self.callBtn.setTitle("call".localized(), for: .normal)
        self.reviewBtn.setTitle("reviewOrderChat".localized(), for: .normal)
        self.subtitleLabel.text = "price".localized() + "\(self.order.price!) LE"
    }
    
    override func getData() {
        super.getData()
        if phone == nil {
            self.navigationItem.rightBarButtonItem = nil
        }
        self.usersRef.child(phone != nil ? ((phone == "" ? order.driver_phone! : phone)) : order.driver_phone!).observeSingleEvent(of: .value, with: { (userSnapshot) in
            let user = User(data: userSnapshot.value as AnyObject)
           
            var driverRatesSummation:Double = 0
            for rate in user.driver_rates {
                driverRatesSummation += rate.rate!
            }
            let avgdriverRates = driverRatesSummation / Double(user.user_rates.count)
            self.driver = User(data: userSnapshot.value as AnyObject)
            
            let url = URL(string: URL_IMAGE_PREFIX + (self.driver?.image!)!)
            self.driverImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_avatarmdpi"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
            }, completionHandler: { image, error, cacheType, imageURL in
                self.driverImageView.layer.cornerRadius = self.driverImageView.frame.height / 2
            })
            
            DispatchQueue.main.async {
                self.titleLabel.text = self.driver?.name!
                self.ratingView.rating = avgdriverRates > 0 ? avgdriverRates : 5
                self.activityIndicator.stopAnimating()
            }
            
        })

    }

    @IBAction func callTapped()  {
        if let url = URL(string: "tel://"+self.order.driver_phone!), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatViewController, segue.identifier == "ShowChat"{
            vc.orderID = self.order.id!
            vc.receiverName = self.driver?.name!
            vc.newChat = self.newChat
            vc.driver_phone = self.order.driver_phone
        }else if let vc = segue.destination as? RequestsDetailsVC {
            vc.order = order
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return self.driver != nil
    }
    
    @IBAction func deliveredTapped(){
        ordersRef.child(self.order.id!).child("state").setValue(State.Done.rawValue);
        ordersRef.child(self.order.id!).child("pay").setValue("no") { (error, _) in
            if error == nil {
                let storyboard  = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "RatingPopVC") as! RatingPopVC
                vc.delegate = self
                vc.ID = self.order.user_phone!
                let popup = PopupDialog(viewController: vc, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 340, gestureDismissal: false, hideStatusBar: false, completion: nil)
                self.present(popup, animated: true, completion: nil)

            }
        }
    }
    
    func didEndRating() {
        self.gotoHome()
    }
    
    func gotoHome() {
        let iden = (CURRENT_USER?.user?.type! == .Customer ? "RootCustomer" : "RootDriver" )
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iden)
        self.present(vc, animated: true, completion: nil)
    }
}
