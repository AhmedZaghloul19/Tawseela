//
//  LoginVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/7/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase
import SwiftValidator

class LoginVC: BaseViewController ,ValidationDelegate{

    @IBOutlet weak var mobileTextfield:UITextField!
    var usernameTextfield:UITextField!
    var codeTextfield:UITextField!
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("users")
    private var channelRefHandle: DatabaseHandle?
    var users :[UserRecord] = []
    
    let validator = Validator()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    validator.registerField(mobileTextfield,errorLabel: nil, rules: [PhoneNumberRule()])
        
    }
    
    override func getData() {
        self.errorView.isHidden = true
    }
    
    func checkUser(phone:String)  {
        self.activityIndicator.startAnimating()
        channelRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(phone){
                let user = UserRecord(data: snapshot.childSnapshot(forPath: phone).value as AnyObject)
                user.mobile = phone
                DispatchQueue.main.async {
                    CURRENT_USER = user
                    cacheUserData()
                    let firbaseToken = Messaging.messaging().fcmToken
                    self.channelRef.child(phone).child("token").setValue(firbaseToken)
                    self.performSegue(withIdentifier: "CustomerRoot", sender: nil)
                    return
                }
            }else{
                self.enterUsernameStage()
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func enterUsernameStage() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "New Customer", message: "Enter Your Name", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textfield) in
                self.usernameTextfield = textfield
            })
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if self.usernameTextfield.text! != ""{
                    self.verificationCodeStage()
                }else{
                    self.enterUsernameStage()
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func verificationCodeStage() {
        let code = arc4random_uniform(10000)
        print("Code : \(code)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Verification Code", message: "Enter Verification Code", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textfield) in
                self.codeTextfield = textfield
            })
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                if self.codeTextfield.text! != ""{
                    if self.codeTextfield.text! == "\(code)" {
                        self.channelRef.child(self.mobileTextfield.text!).child("type").setValue("user")
                    self.channelRef.child(self.mobileTextfield.text!).child("name").setValue(self.usernameTextfield.text!)

                        let firbaseToken = Messaging.messaging().fcmToken
                    self.channelRef.child(self.mobileTextfield.text!).child("token").setValue(firbaseToken)
                        CURRENT_USER = UserRecord()
                        CURRENT_USER?.mobile = self.mobileTextfield.text!
                        CURRENT_USER?.user = User(id: "", name: self.usernameTextfield.text!, image: "", token: firbaseToken!, type: .Customer)
                        cacheUserData()
                        self.performSegue(withIdentifier: "CustomerRoot", sender: nil)

                    }else{
                        self.verificationCodeStage()
                    }
                }else{
                    self.verificationCodeStage()
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func validationSuccessful() {
        self.activityIndicator.startAnimating()
        self.checkUser(phone: mobileTextfield.text!)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        self.showAlertWithTitle(title: "Failed", message: "Not Valid Phone Number")
    }
    
//    deinit {
//        if let refHandle = channelRefHandle {
//            channelRef.removeObserver(withHandle: refHandle)
//        }
//    }
    
    // MARK: Firebase related methods
//    private func observeUsers() {
//        // Use the observe method to listen for new
//        // channels being written to the Firebase DB
//        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
//            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
//            let id = snapshot.key
//            if let name = channelData["name"] as! String!, name.count > 0 { // 3
//                self.channels.append(Channel(id: id, name: name))
//                self.tableView.reloadData()
//            } else {
//                print("Error! Could not decode channel data")
//            }
//        })
//    }

    @IBAction func loginDidTouch(_ sender: AnyObject) {
        validator.validate(self)
    }

}
