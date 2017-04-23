//
//  ProfileMenuCell.swift
//  Twitterr
//
//  Created by CK on 4/21/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit

class ProfileMenuCell: UITableViewCell {

    @IBOutlet weak var screenImage: UIImageView!
    @IBOutlet weak var screenId: UILabel!
    @IBOutlet weak var screenName: UILabel!
    
    var currentUser:User! {
        didSet {
            if let user = currentUser {
                screenImage.setImageWith((user.profileImageURL)!)
                screenImage.layer.cornerRadius = 5
                screenImage.layer.borderColor = UIColor.white.cgColor
                screenImage.layer.borderWidth = 2
                screenName.text = user.name
                screenId.text = user.screenName
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
