//
//  SideMenuVC.swift
//  Tawseela
//
//  Created by Ahmed on 8/20/17.
//  Copyright © 2017 RKAnjel. All rights reserved.
//

import UIKit
import Kingfisher

class SideMenuVC: UITableViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userTitleLabel: UILabel!
    
    override func viewDidLoad() {
        revealViewController().rearViewRevealWidth = 250
        revealViewController().rightViewRevealWidth = 250
        clearsSelectionOnViewWillAppear = true
        
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
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 4 {
//            self.share(sender: tableView)
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            
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

}
