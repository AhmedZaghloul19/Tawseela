//
//  RatingCell.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/9/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import FloatRatingView

protocol RequestDelegate {
    func didConfirmedOn(request:Request)
}

class RatingCell: UITableViewCell {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subtitleLabel:UILabel!
    @IBOutlet weak var secondSubtitleLabel:UILabel!
    @IBOutlet weak var placeIcon:UIImageView!
    @IBOutlet weak var ratingView:FloatRatingView!
    @IBOutlet weak var confirmBtn:UIButton!
    
    var delegate:RequestDelegate?
    var request:Request!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.confirmBtn?.setTitle("confirm".localized(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func confirmRequestTapped() {
        self.delegate?.didConfirmedOn(request: self.request)
    }
}
