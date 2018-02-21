//
//  RatesVC.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/9/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import Firebase

class RatesVC: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView:UITableView!

    private lazy var ratesRef: DatabaseReference = Database.database().reference().child("users")
    private var channelRefHandle: DatabaseHandle?
    var rates :[Rate] = []
    var ratesType = "user_rate"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 80
    }
    
    
    deinit {
        if let refHandle = channelRefHandle {
            ratesRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func getData() {
        super.getData()
        channelRefHandle = self.ratesRef.child((CURRENT_USER?.mobile!)!).child(ratesType).observe(.value, with: { (snap) in
            self.activityIndicator.startAnimating()
            for rateChild in snap.children {
                let snp = rateChild as! DataSnapshot
                let rate = Rate(data: snp.value as AnyObject)
                rate.date = snap.key
                self.rates.append(rate)
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        })

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RatingCell
        
        cell.titleLabel.text = rates[indexPath.row].phone!
        cell.subtitleLabel.text = rates[indexPath.row].review!
        cell.ratingView.rating = (rates[indexPath.row].rate!)
        
        return cell
    }
    
}
