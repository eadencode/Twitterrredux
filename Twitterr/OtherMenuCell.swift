//
//  OtherMenuCell.swift
//  Twitterr
//
//  Created by CK on 4/21/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit

class OtherMenuCell: UITableViewCell {
    @IBOutlet weak var labelIcon: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    var menuItem:Menu! {
        
        didSet {
            labelIcon.image = menuItem.menuIcon
            labelName.text = menuItem.menuTitle
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
