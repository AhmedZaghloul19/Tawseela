//
//  BaseViewController.swift
//  RKAnjel
//
//  Created by Ahmed on 8/22/17.
//  Copyright © 2017 RKAnjel. All rights reserved.
//

import UIKit

/**
 Base View Controller For All Controllers of the app.
 ````
 @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
 @IBOutlet weak var menuButton: UIBarButtonItem!
 @IBOutlet weak var cartBtn:UIBarButtonItem!

 lazy var errorView = ConnectionErrorView()
 
 ````
 
 - activityIndicator: Outlet connected to an activity indicator when loading.
 - errorView: View for the connection error faults.
 
 ## Important Notes ##
 This controller is the base view controller For The APP.
 */

class BaseViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var cartButton: UIBarButtonItem!

    lazy var errorView = ConnectionErrorView()
    let notificationButton = SSBadgeButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.constructConnectionErrorView()
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        getData()
        if self.revealViewController() != nil && menuButton != nil{
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.sideMenuConfigration()
        }

        notificationButton.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        notificationButton.setImage(UIImage(named: "shopping-store-cart-")?.withRenderingMode(.alwaysTemplate), for: .normal)
        notificationButton.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        notificationButton.badge = CART_ORDERS.count != 0 ? "\(CART_ORDERS.count)" : nil
        self.navigationItem.leftBarButtonItems?.first?.customView = notificationButton
        
        NC.addObserver(self, selector: #selector(cartChanged), name: Notification.Name("cartChanged"), object: nil)
    }
    
    @IBAction func cartTapped(){
        self.performSegue(withIdentifier: "openCart", sender: self)
    }
    
    @objc func cartChanged() {
        notificationButton.badge = CART_ORDERS.count != 0 ? "\(CART_ORDERS.count)" : nil
    }
    
    func sideMenuConfigration(){
        revealViewController().rearViewController = nil
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        menuButton?.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        
    }
    func getData() {
        self.errorView.isHidden = true
        self.activityIndicator?.startAnimating()
    }
    
    func constructConnectionErrorView() {
        if !self.view.subviews.contains(errorView){
            errorView.frame = self.view.frame
            self.view.addSubview(errorView)
            self.errorView.tryAgainBtn.addTarget(self, action: #selector(reload), for: .touchUpInside)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CART_ORDERS.count != 0 ? notificationButton.playSwingAnimationWithoutZoomOut(WithDuration: 1, WithDelay: 2) : nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.view.setNeedsLayout()
        }
    }
}
