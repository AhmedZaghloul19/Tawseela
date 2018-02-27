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

class RequestProgressVC: BaseViewController {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subtitleLabel:UILabel!
    @IBOutlet weak var driverImageView:UIImageView!
    @IBOutlet weak var ratingView:FloatRatingView!
    
    private lazy var usersRef: DatabaseReference = Database.database().reference().child("users")
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

        self.subtitleLabel.text = "Delivery Price: \(self.order.price!) LE"
    }
    
    override func getData() {
        super.getData()
        
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

}
