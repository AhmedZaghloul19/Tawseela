//
//  RatingCell.swift
//  Tawseela
//
//  Created by Ahmed Zaghloul on 2/9/18.
//  Copyright © 2018 XWady. All rights reserved.
//

import UIKit
import FloatRatingView

class RatingCell: UITableViewCell {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var subtitleLabel:UILabel!
    @IBOutlet weak var placeIcon:UIImageView!
    @IBOutlet weak var ratingView:FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
