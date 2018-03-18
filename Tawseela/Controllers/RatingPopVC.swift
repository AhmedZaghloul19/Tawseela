//
//  RatingPopVC.swift
//  Alamofire
//
//  Created by Ahmed Zaghloul on 12/11/17.
//

import UIKit
import FloatRatingView
import Firebase
import JSQMessagesViewController

protocol RatingDelegate :class{
    func didEndRating()
}

class RatingPopVC: UIViewController {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var commentTextfield:JSQMessagesComposerTextView!
    @IBOutlet weak var confirmBtn:UIButton!
    @IBOutlet weak var ratingView:FloatRatingView!
    var ID :String!
    var ratingForCustomer = true
    weak var delegate :RatingDelegate?
    
    private lazy var ordersRef: DatabaseReference = Database.database().reference().child("users")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "rate".localized()
        self.confirmBtn.setTitle("confirm".localized(), for: .normal)
        self.commentTextfield.placeHolder = "write_msg_chat".localized()
        self.ratingView.type = .floatRatings
    }
    
    @IBAction func submitTapped(_ sender: Any) {
        let rateRef = ordersRef.child(ID).child(ratingForCustomer ? "user_rate" : "driver_rate").child(Date().getStringFromDate())
       
        let rateItem:[String:Any] = [
            "phone": (CURRENT_USER?.mobile!)!,
            "rate": ratingView.rating,
            "review": commentTextfield.text!,
            ]
        
        rateRef.setValue(rateItem) { (error, _) in
            if error == nil {
                self.dismiss(animated: true, completion: {
                    self.delegate?.didEndRating()
                })
            }
        }
    }
}
