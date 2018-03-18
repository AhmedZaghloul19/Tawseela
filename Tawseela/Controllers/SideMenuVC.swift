//
//  SideMenuVC.swift
//  Tawseela
//
//  Created by Ahmed on 8/20/17.
//  Copyright © 2017 RKAnjel. All rights reserved.
//

import UIKit
import Kingfisher
import MessageUI
import Localize_Swift

class SideMenuVC: UITableViewController ,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userTitleLabel: UILabel!
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var visitusLabel: UILabel!
    @IBOutlet weak var complaintsLabel: UILabel!
    @IBOutlet weak var jointeamLabel: UILabel!
    
    override func viewDidLoad() {
        revealViewController().rearViewRevealWidth = 250
        revealViewController().rightViewRevealWidth = 250
        clearsSelectionOnViewWillAppear = true
        
        logoutLabel.text = "logout".localized()
        languageLabel.text = "language".localized()
        visitusLabel.text = "vistUs".localized()
        complaintsLabel.text = "shakawa".localized()
        jointeamLabel.text = "joinUs".localized()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setData()
    }
    
    func setData(){
        self.userTitleLabel.text = "\((CURRENT_USER?.user?.name!)!)"
        let url = URL(string: SERVICE_URL_PREFIX + (CURRENT_USER?.user?.image!)!)
        self.userImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "ic_avatarmdpi"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
        }, completionHandler: { image, error, cacheType, imageURL in
            DispatchQueue.main.async {
                self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0://join team
            self.sendEmail()
        case 1://complaints
            self.openSafariWithSuffix(link: "https://www.facebook.com/messages/t/BanhaRestaurants")
        case 2://visit us
            self.openSafariWithSuffix(link: "https://www.facebook.com/BanhaRestaurants/?ref=bookmarks")
        case 3://language
            let alert = UIAlertController(title: "language".localized(), message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "English", style: .default, handler: { (action) in
                Localize.setCurrentLanguage("en")
                self.gotoHome()
            }))
            alert.addAction(UIAlertAction(title: "عربي", style: .default, handler: { (action) in
                Localize.setCurrentLanguage("ar")
                self.gotoHome()
            }))
            
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        default://logout
            break;
        }
    }
    
    func gotoHome() {
        let iden = (CURRENT_USER?.user?.type! == .Customer ? "RootCustomer" : "RootDriver" )
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iden)
        self.present(vc, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier != "logout"{
            return true
        }else{
            userData.removeObject(forKey: "mobile")
            userData.removeObject(forKey: "cart_orders")
            return true
        }
    }
    
    func share(sender:UIView){
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let textToShare = "تطبيق اعتمدني :\nاعتمدني للأخبار و المواضيع التعليمية عن التربية الفنية."
        print(textToShare)
        if let myWebsite = URL(string: "http://itunes.apple.com/app/1323514111") {
            
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList,.copyToPasteboard,.message,.mail,.postToFacebook,.postToFlickr,.postToTwitter,.postToVimeo]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    func openSafariWithSuffix(link:String) {
        if let requestUrl = URL(string: link) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(requestUrl, options: [:], completionHandler: { (error) in
                    
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func sendEmail() {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            self.showAlertWithTitle(title: "Sorry", message: "Mail services are not available")
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["ahmed.el.snosey@gmail.com"])
        composeVC.setSubject("joinUs".localized())
        composeVC.setMessageBody("مطلوب :\n صوره بطاقه + \nصوره رخصه القياده +\n صوره رخصه العربيه او الموتسيكل + \nصوره العربيه او الموتسيكل", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
