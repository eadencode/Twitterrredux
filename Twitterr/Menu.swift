//
//  Menu.swift
//  Twitterr
//
//  Created by CK on 4/22/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation
import UIKit

let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
class Menu: NSObject {
    
    var index:Int?
    var menuIcon:UIImage?
    var menuTitle:String?
    var controller:UIViewController?
    var source:TweetsSource?
    
    init(title:String , image:UIImage) {
        menuIcon = image
        menuTitle = title

        switch menuTitle! {
            
            case "Home" :
                index = 0
                controller = storyboard.instantiateViewController(withIdentifier: "tweetsNavigation") as! UINavigationController
                source = TweetsSource.HOME
            case "Profile" :
                index = 1
                controller = storyboard.instantiateViewController(withIdentifier:"profileNavigation") as! UINavigationController
            case "Mentions" :
                index = 2
                controller = storyboard.instantiateViewController(withIdentifier: "tweetsNavigation") as! UINavigationController
                source = TweetsSource.MENTIONS
            case "Signout" :
                index = 3
            default :
                index = 0
                controller = storyboard.instantiateViewController(withIdentifier: "tweetsNavigation") as! UINavigationController
        }
    }
    
    
}
