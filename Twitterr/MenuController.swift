//
//  MenuController.swift
//  Twitterr
//
//  Created by CK on 4/21/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit

class MenuController: UIViewController ,UITableViewDelegate ,UITableViewDataSource {
    @IBOutlet weak var menuTable: UITableView!
    var contentController:ContentController!
    var otherMenus:[Menu] = [Menu( title: "Home",image: #imageLiteral(resourceName: "home")),
                             Menu( title: "Profile",image: #imageLiteral(resourceName: "profile")),
                             Menu( title: "Mentions",image: #imageLiteral(resourceName: "mentions")) ,
                             Menu( title: "Signout",image: #imageLiteral(resourceName: "signout"))]
    
    var profile: UIViewController!
    var home: UIViewController!
    var mentions: UIViewController!
    
    var childControllers:[UIViewController] = []
    
  
    @IBOutlet weak var hamburger: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTable.delegate = self
        menuTable.dataSource = self
        menuTable.estimatedRowHeight = 50
        menuTable.rowHeight = UITableViewAutomaticDimension
        viewLayoutSubControllers()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:UserAccount.userAccountAdded), object: nil, queue: OperationQueue.main) { (Notification) in
            self.menuTable.reloadData()
        }

        addOrDeleteAccounts(forOperation: UserAccount.userAccountAdded)
        addOrDeleteAccounts(forOperation: UserAccount.userAccountSwitched)
        addOrDeleteAccounts(forOperation: UserAccount.userAccountRemoved)
    }

        // Do any additional setup after loading the view.
    
    func addOrDeleteAccounts(forOperation:String){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:forOperation), object: nil, queue: OperationQueue.main) { (Notification) in
            self.menuTable.reloadData()
        }
    }

    
    
    func viewLayoutSubControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        profile = storyboard.instantiateViewController(withIdentifier:"profileNavigation") as! UINavigationController
        home = storyboard.instantiateViewController(withIdentifier: "tweetsNavigation") as! UINavigationController
        mentions = storyboard.instantiateViewController(withIdentifier: "tweetsNavigation") as! UINavigationController
        childControllers = [profile, home, mentions]
        contentController.currrent = home
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCollapse(_ sender: Any) {
        contentController.collapseMenu()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( section == 0) {
            return 1
        }
        return otherMenus.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profilemenucell") as! ProfileMenuCell
            cell.currentUser = User.me
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "othermenucell") as! OtherMenuCell
            cell.menuItem = otherMenus[indexPath.row]
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if(indexPath.row != 3) {
                let menu = otherMenus[indexPath.row]
                contentController.layoutAndShowContent(ofController: menu.controller! , menu: menu)
            }else {
                TwitterApi.shared?.logout()
            }
        }
    }
    
    override func viewDidLayoutSubviews(){
        menuTable.frame = CGRect(x: menuTable.frame.origin.x, y: menuTable.frame.origin.y, width: menuTable.frame.size.width, height: menuTable.contentSize.height + 60)
        menuTable.reloadData()
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
