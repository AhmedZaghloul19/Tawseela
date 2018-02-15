//
//  ConnectionError.swift
//  CafeSupreme
//
//  Created by Ahmed on 10/23/17.
//  Copyright © 2017 RKAnjel. All rights reserved.
//

import UIKit

class ConnectionErrorView: UIView {

    @IBOutlet weak var tryAgainBtn:UIButton!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("ConnectionErrorView", owner: self, options: [:])
        addSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
    
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
    }

}
