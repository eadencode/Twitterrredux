//
//  LoginController.swift
//  Twitterr
//
//  Created by CK on 4/14/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var login: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        login.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        TwitterApi.shared?.login(newUser: false, success: {
            self.performSegue(withIdentifier: "postLogin", sender: nil)
        }, failure: { (error) in
            print("Login Error : \(error.localizedDescription)")
        })

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        //ck: important to instantiate nav controller of content controller. Not direct view controller. You get exception of push segue belonging to same nav of vcs , if directly done to vc.

        if(segue.identifier == "postLogin") {
            
            //Get Nav and Controller of Content. (Hamburger holders)
            let contentController = segue.destination as! ContentController
            
            //Get Nav and Controller of Menu.
            let menuNav = mainStoryBoard.instantiateViewController(withIdentifier: "nav_menu") as! UINavigationController
            let controllersOfMenuNavigation = menuNav.viewControllers
            let menuController = controllersOfMenuNavigation.first as! MenuController
            
            //Assign menu to content and vc vs
            menuController.contentController = contentController
            contentController.menuController = menuNav
            contentController.currentUser = User.me

        }

    }
 

}
