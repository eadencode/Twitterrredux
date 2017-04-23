//
//  UserAccountCell.swift
//  Twitterr
//
//  Created by CK on 4/23/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit
import Blurry


class UserAccountCell: UITableViewCell {
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastLoggedIn: UILabel!
    @IBOutlet weak var backGround: UIImageView!

    
    var userAccount:UserAccount! {
        didSet {
            if let user = userAccount.user {
                userImage.setImageWith(user.profileImageURL!)
                userScreenName.text = user.screenName
                userName.text = user.name
                backGround.setImageWith(user.profileBannerURL!)
                UIView.animate(withDuration: 0.1, animations: {
                    
                    let newImage = self.backGround.image?.blurryImage(blurRadius: 2)        // Initialization code
                    self.backGround.image = newImage
                })
               

            }
            self.userImage.layer.cornerRadius = 25
            lastLoggedIn.text = userAccount.lastLoggedIn
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
           }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}
