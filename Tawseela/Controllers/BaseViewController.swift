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

    lazy var errorView = ConnectionErrorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.constructConnectionErrorView()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        getData()
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.sideMenuConfigration()
        }else{
            let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(backTapped))
            leftGesture.direction = .left
            self.view.addGestureRecognizer(leftGesture)
        }
        
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
    }
}
