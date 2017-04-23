//
//  Style.swift
//  Twitterr
//
//  Created by CK on 4/16/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation
import UIKit

class Style {

    
    class func styleNav(viewController:UIViewController) {
        viewController.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "twitter"))

    }
    
    class func styleTwitterAttributedLabel(label:ActiveLabel) {
        label.numberOfLines = 0
        label.lineSpacing = 4
        label.sizeToFit()
        label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
        label.hashtagColor = UIColor(rgb: 0x4099FF)
        label.mentionColor = UIColor(rgb: 0x4099FF)
        label.URLColor = UIColor(rgb: 0x4099FF)
        label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
    }
    
    
    class func styleTwitterAttributedLabelForCell(label:ActiveLabel) {
        label.numberOfLines = 0
        label.lineSpacing = 1
        label.hashtagColor = UIColor(rgb: 0x4099FF)
        label.mentionColor = UIColor(rgb: 0x4099FF)
        label.URLColor = UIColor(rgb: 0x4099FF)
        label.URLSelectedColor = UIColor(red: 82.0/255, green: 190.0/255, blue: 41.0/255, alpha: 1)
    }
    
}
