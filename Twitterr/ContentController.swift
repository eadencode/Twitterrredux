//
//  ContentController.swift
//  Twitterr
//
//  Created by CK on 4/21/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit

class ContentController: UIViewController {

    @IBOutlet weak var contentHolder: UIView!
    @IBOutlet weak var menuHolder: UIView!
    @IBOutlet weak var contentTop: NSLayoutConstraint!
    @IBOutlet weak var contentLeft: NSLayoutConstraint!
    @IBOutlet weak var contentRight: NSLayoutConstraint!
    
    
    var menuController:UIViewController!
    var currrent:UIViewController?
    
    var viewControllerWidth: CGFloat!
    

    var currentUser: User!
    var beginningMargin: CGFloat!
    var trailingMargin: CGFloat!
    var menuRevealed = false
    

    override func viewDidLoad() {
        //menu
       layoutMenu()
        
        //home
        if let currentContent = currrent  {
            print("No content")
            layoutAndShowContent(ofController: currentContent,menu: nil)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            currrent = storyboard.instantiateViewController(withIdentifier: "tweetsNavigation") as! UINavigationController //home
            layoutAndShowContent(ofController: currrent!,menu: nil)
        }
    }
    
    func layoutMenu() {
        self.view.layoutIfNeeded()
        showController(controller: menuController!, inContentVew: menuHolder, ofController: self)
       
    }
    
    func layoutAndShowContent(ofController:UIViewController, menu:Menu?)  {
        view.layoutIfNeeded()
        if(currrent != nil) {
            hideController(controller: currrent!)
        }
        currrent = ofController
        if let menuSelected = menu {
            if(menuSelected.source != nil ){
                let navController  = currrent as! UINavigationController
                let tweetsController = navController.viewControllers.first as! TweetsController
                tweetsController.source = menuSelected.source
//                currrent = tweetsController
            }
        }
        showController(controller: currrent!, inContentVew: contentHolder, ofController: self)
        
        UIView.animate(withDuration: 0.3) {
            self.contentLeft.constant = 0
            self.contentRight.constant = 0
            self.view.layoutIfNeeded()
        }

        menuRevealed = false
    }
    
    
    
    
    //MARK : Hide and show content.
    
    func showController(controller:UIViewController ,inContentVew:UIView , ofController: UIViewController)  {
        ofController.view.layoutIfNeeded()
        ofController.addChildViewController(controller)
        controller.view.frame = inContentVew.bounds
        inContentVew.addSubview(controller.view)
        controller.didMove(toParentViewController: ofController)

    }
    
    func hideController(controller:UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.didMove(toParentViewController: nil)
    }
    
    
    func revealMenu() {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.contentLeft.constant = 150
            self.contentRight.constant = -150
            self.menuRevealed = true
            self.view.layoutIfNeeded()
        })
    }
    
    
    
    
    func collapseMenu() {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.contentLeft.constant = 0
            self.contentRight.constant = 0
            self.menuRevealed = false
            self.view.layoutIfNeeded()
        })
    }
    
    
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        // two cases pan can happen. (1) pan right to reveal menu , (2) pan left to hide menu. Record in began /change(add translation) leading constraint of content view.

        
        let panRight = velocity.x > 0 && !menuRevealed
        let panLeft = velocity.x < 0 && menuRevealed
        
        switch sender.state {
            case .began :
                if( (panRight || panLeft))  {
                    beginningMargin = contentLeft.constant
                }
            case .changed :
                if( (panRight || panLeft))  {
                    contentLeft.constant = beginningMargin + translation.x
                    contentRight.constant = -(beginningMargin + translation.x)
                }
            case .ended :
                //animate lockin on pan right - to some width remaining from view controllers view.
                //animate 0 on pan left.
                UIView.animate(withDuration: 0.3) {
                    if(panRight) {
                        self.menuRevealed = true
                        self.contentLeft.constant = self.view.frame.width/2
                        self.contentRight.constant = -self.contentLeft.constant//self.view.frame.width/2
                    }else
                     {
                        self.menuRevealed = false
                        self.contentLeft.constant = 0
                        self.contentRight.constant = 0
                    }
                    self.view.layoutIfNeeded()
                }
            default:
              print("No pan")
        }

    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
