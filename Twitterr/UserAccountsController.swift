//
//  UserAccountsController.swift
//  Twitterr
//
//  Created by CK on 4/23/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit

class UserAccountsController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
      
    @IBOutlet weak var userAccountsTable: UITableView!
    var userAccounts = [UserAccount]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userAccountsTable.delegate = self
        userAccountsTable.dataSource = self
        userAccounts = (TwitterApi.shared?.registeredAccounts)!
//        userAccountsTable.reloadData()
        // Do any additional setup after loading the view.
        addOrDeleteAccounts(forOperation: UserAccount.userAccountAdded)
        addOrDeleteAccounts(forOperation: UserAccount.userAccountRemoved)
    }

    func addOrDeleteAccounts(forOperation:String){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:forOperation), object: nil, queue: OperationQueue.main) { (Notification) in
            self.userAccounts = (TwitterApi.shared?.registeredAccounts)!
            self.userAccountsTable.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        sleep(1)
        userAccountsTable.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addUserAccount(_ sender: Any) {
        TwitterApi.shared?.login(newUser: true, success: { 
            print("added succesfully")
            
        }, failure: { (error) in
            print("failed login")
        })
        
    }

    @IBAction func cancelUserAccount(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "userAccountCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! UserAccountCell
        cell.userAccount = userAccounts[indexPath.row]
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(swipeGesture)

        return cell
    }
    
    
    func didPan(sender: UIPanGestureRecognizer)  {
       if sender.state == .ended {
            let cell = sender.view as! UITableViewCell
            let indexPath = userAccountsTable.indexPath(for: cell)
            let userAccountToDelete = userAccounts[(indexPath?.row)!]
            TwitterApi.shared?.removeAccount(userAccount: userAccountToDelete)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userAccount = userAccounts[indexPath.row]
        TwitterApi.shared?.switchAccount(userAccount: userAccount)
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
