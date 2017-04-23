//
//  AppDelegate.swift
//  Twitterr
//
//  Created by CK on 4/14/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit
import QuartzCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,CAAnimationDelegate {

    var window: UIWindow?
    var mask: CALayer?
    var imageView: UIImageView?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if User.me != nil {

            //Get Nav and Controller of Content. (Hamburger holders)
            
            //Get Nav and Controller of Menu.
            let menuNav = storyBoard.instantiateViewController(withIdentifier: "nav_menu") as! UINavigationController
            let controllersOfMenuNavigation = menuNav.viewControllers
            let menuController = controllersOfMenuNavigation.first as! MenuController
            
            let contentController = storyBoard.instantiateViewController(withIdentifier: "contentController") as! ContentController
            contentController.currentUser = User.me
            contentController.menuController = menuNav
            menuController.contentController = contentController
            window?.rootViewController = contentController
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil, queue: OperationQueue.main) { (Notification) in
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewControllerMain = mainStoryBoard.instantiateInitialViewController() //First Responder.
            self.window?.rootViewController = viewControllerMain
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        

    }

    //OAuth callbacks.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        TwitterApi.shared?.open(url: url)
        return true
    }
    
    
    func startLaunch() {
        let imageView = UIImageView(frame: self.window!.frame)
        imageView.image = UIImage(named: "twitterscreen")
        self.window!.addSubview(imageView)
        self.mask = CALayer()
        self.mask!.contents = #imageLiteral(resourceName: "twitter-logo-final").cgImage
        self.mask!.contentsGravity = kCAGravityResizeAspect
        self.mask!.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.mask!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.mask!.position = CGPoint(x: imageView.frame.size.width/2, y: imageView.frame.size.height/2)
        
        // Starting from Xcode7, iOS9 requires all UIWindow must have a rootViewController
        let emptyView = UIViewController()
        self.window?.rootViewController = emptyView
        
        imageView.layer.mask = mask
        self.imageView = imageView
        
        animateMask()
        
        // Override point for customization after application launch.
        self.window!.backgroundColor = UIColor(red: 70/255, green: 154/255, blue: 233/255, alpha: 1)
        self.window!.makeKeyAndVisible()
        UIApplication.shared.isStatusBarHidden = true
    }
    
    
    func animateMask() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 3
        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = mask!.bounds
        let secondBounds = CGRect(x: 0, y: 0, width: 90, height: 90)
        let finalBounds = CGRect(x: 0, y: 0, width: 1500, height: 1500)
        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.3, 1]
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        self.mask!.add(keyFrameAnimation, forKey: "bounds")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.imageView!.layer.mask = nil //remove mask when animation completes

    }
  
}

