//
//  TweetsController.swift
//  Twitterr
//
//  Created by CK on 4/14/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit
import AFNetworking
import ICSPullToRefresh
import MBProgressHUD

protocol RefreshAndLoadProtocol  {
    func refreshEnded()
    func infiniteScroll()
}

enum TweetsSource:Int{
    case HOME = 1 ;case MENTIONS = 2; case SEARCH = 3
}

class TweetsController: UIViewController {

    
    @IBOutlet weak var hamburger: UIBarButtonItem!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet weak var tweetsTable: UITableView!
    
    var tweets:[Tweet]?
    var reply:Tweet?
    var parameters:[String:Any?] = ["count": 20]
    var user:User?
    var source:TweetsSource?
    var profileTweet:Tweet?
    var isSearch:Bool = false
    var searchTag:String?
    var titleTag:String?
    
    //MARK : ViewController methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        if(source == nil) {
            source = TweetsSource.HOME
        }
        initializeTweetsTable()
        Style.styleNav(viewController: self)
        observeReplies()
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: false)
        
        //new add long press to add accounts.
        pressed = false
      
      
    }
    
    
    func addOrDeleteAccounts(forOperation:String){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:forOperation), object: nil, queue: OperationQueue.main) { (Notification) in
            self.getTweets(parameters: self.parameters as [String : AnyObject], progress: false,isMore: false)
        }
    }
    var pressed:Bool = false
    func didLongPress(sender: UILongPressGestureRecognizer) {
        if(!pressed) {
            self.performSegue(withIdentifier: "showUserAccounts", sender: self)
            pressed = true
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        pressed = false
        addOrDeleteAccounts(forOperation: UserAccount.userAccountAdded)
        addOrDeleteAccounts(forOperation: UserAccount.userAccountRemoved)
        addOrDeleteAccounts(forOperation: UserAccount.userAccountSwitched)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
        gesture.minimumPressDuration = 0.5
        self.navigationController?.navigationBar.addGestureRecognizer(gesture)
        tweetsTable.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            //refresh control height is 60.
            self.tweetsTable.contentInset = UIEdgeInsetsMake( y-60, 0, 0, 0)
        }
    }
    
    var revealed = false
    
    @IBAction func showMenu(_ sender: Any) {
        //Get Nav and Controller of Content. (Hamburger holders)
        if(isSearch) {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            let contentController = self.navigationController?.parent as! ContentController
            if(!revealed){
                contentController.revealMenu()
                revealed = true
            }
            else {
                contentController.collapseMenu()
                revealed = false
            }
        }
        
        
//        let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let contentController = mainStoryBoard.instantiateViewController(withIdentifier: "contentController") as! ContentController
//        //Get Nav and Controller of Menu.
//        let menuNav = mainStoryBoard.instantiateViewController(withIdentifier: "nav_menu") as! UINavigationController
//        let controllersOfMenuNavigation = menuNav.viewControllers
//        let menuController = controllersOfMenuNavigation.first as! MenuController
//        
//        //Assign menu to content and vc vs
//        menuController.contentController = contentController
//        contentController.menuController = menuNav
//        contentController.menuRevealed = true
//        self
//        present(contentController, animated: true, completion: nil)
    }

    @IBAction func onLogout(_ sender: Any) {
        TwitterApi.shared?.logout()
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "tweetDetail") {
            let detailController = segue.destination as! TweetDetailController
            let indexPath = sender as! IndexPath
            detailController.tweet = tweets?[(indexPath.row)]
        }
        if (segue.identifier == "retweetFromTable") {
            let tweetController = segue.destination as! TweetController
            tweetController.replyTo = reply
            tweetController.delegate = self
        }
        
        if (segue.identifier == "profileSegue") {
//            let gesture = sender as! UITapGestureRecognizer
//            let rowIndex = gesture.view?.tag
            let tweet = profileTweet //tweets?[rowIndex!]
            let profileNav = segue.destination as! UINavigationController
            let profileController = profileNav.viewControllers.first as! ProfileViewController
            profileController.user = tweet?.user
        }
        
        
        if (segue.identifier == "showUserAccounts") {
            print("Navigating to Accounts Page")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK : Tweet Changes and Action

    
    func observeReplies() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Tweet.userDidRetweeted), object: nil, queue: OperationQueue.main) { (Notification) in
            if let userInfo  = Notification.userInfo {
                let tweet = userInfo["tweet"] as! Tweet
                self.tweets?.insert(tweet, at: 0)
                self.tweetsTable.reloadData()
            }
        }
    }
    @IBAction func onViewProfile(_ sender: Any) {
        
        let gesture = sender as! UITapGestureRecognizer
        self.performSegue(withIdentifier: "profileSegue", sender: gesture)
        
    }
    
    func refreshTweets() {
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: false)
    }
    
    func moreTweets() {
        parameters["max_id"] = Tweet.lastTweetId!
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: true)
    }
    
    func getTweets(parameters: [String:AnyObject],progress:Bool ,isMore:Bool) {
        var newparams = parameters
        if(isSearch) {
            newparams["q"] =  searchTag as AnyObject
            source = TweetsSource.SEARCH
            if let tagg = searchTag ,let ttag = titleTag {
                self.navigationItem.titleView = nil
                self.navigationItem.title = "\(ttag)\(tagg)"
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
                self.navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "back")
//                    = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(popController))
                
            }
        }
        if(progress){
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        Tweet.timeline(source: source! ,parameters: newparams as [String : AnyObject], success: { (newtweets) in
            if(isMore){
                //Twitter api gives - max_id inclusive in more.
                var newFilterTweets = newtweets
                newFilterTweets.remove(at: 0)
                self.tweets = self.tweets! + (newFilterTweets)
            }else {
                self.tweets = newtweets
            }
            self.tweetsTable.reloadData()
            if(progress) {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            self.tweetsTable.infiniteScrollingView?.stopAnimating()
            
        }, failure: { (error) in
            print("error \(error.localizedDescription)")
            self.tweetsTable.infiniteScrollingView?.stopAnimating()
            
        })
    }
    
    func popController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
  }


//MARK : Tweets Table

extension TweetsController : UITableViewDelegate ,UITableViewDataSource {
    
    func initializeTweetsTable() {
        tweetsTable.delegate = self
        tweetsTable.dataSource = self
        tweetsTable.rowHeight = UITableViewAutomaticDimension
        tweetsTable.estimatedRowHeight = 100
        tweetsTable.addPullToRefreshHandler {
            self.refreshEnded()
        }
        tweetsTable.addInfiniteScrollingWithHandler {
            self.infiniteScroll()
        }
        let nib =  UINib(nibName: "TweetCell", bundle: nil)
        self.tweetsTable.register(nib, forCellReuseIdentifier: "ReusableTweetCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let  tweetCell = tableView.dequeueReusableCell(withIdentifier: "ReusableTweetCell") as! ReusableTweetCell
        let tweet = tweets?[indexPath.row]
        tweetCell.tweet = tweet
//        tweetCell.delegate = self
        return tweetCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "tweetDetail", sender: indexPath)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentTweets = tweets {
            return currentTweets.count
        }
        return 0
    }
}


//MARK : Reload and infinite scroll.

extension TweetsController:RefreshAndLoadProtocol {
    
    func refreshEnded() {
        DispatchQueue.global(qos: .userInitiated).async{
            sleep(1)
            self.refreshTweets()
            DispatchQueue.main.async { [unowned self] in
                self.tweetsTable.pullToRefreshView?.stopAnimating()
            }
        }
    }
    
    func infiniteScroll() {
        DispatchQueue.global(qos: .userInitiated).async {
            sleep(1)
            self.moreTweets()
            DispatchQueue.main.async { [unowned self] in
                self.tweetsTable.pullToRefreshView?.stopAnimating()
            }
        }
    }
    

}


extension TweetsController : TweetProtocol , NewTweetProtocol {

    func urlTap(url: URL?) {
        //to wk webview
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let bnav = storyboard.instantiateViewController(withIdentifier: "wkwebnav") as! UINavigationController
        let brw = bnav.viewControllers.first as! BrowserViewController
        brw.url = url
        self.present(bnav, animated: true, completion: nil)

    }
    
    func mentionsTap(mention: String?) {
        // to onmentisearch api
        // to hashTag search
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tc = storyboard.instantiateViewController(withIdentifier: "tweetsController") as! TweetsController
        tc.isSearch = true
        tc.searchTag = mention
        tc.titleTag = "@"
        self.navigationController?.pushViewController(tc, animated: true)

    }
    
    func hashTagTap(tag: String?) {
        // to hashTag search
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tc = storyboard.instantiateViewController(withIdentifier: "tweetsController") as! TweetsController
        tc.isSearch = true
        tc.searchTag = tag
        tc.titleTag = "#"
        self.navigationController?.pushViewController(tc, animated: true)
    }
    func onReplyOfTweet(tweet: Tweet) {
        reply = tweet
        self.performSegue(withIdentifier: "retweetFromTable", sender: self)
    }
    
    func onReplyOrNewTweet(tweet: Tweet) {
        tweets?.insert(tweet, at: 0)
        self.tweetsTable.reloadData()
        reply = nil
    }
    
    func performProfileSegue(tweet:Tweet) {
        profileTweet = tweet
        self.performSegue(withIdentifier: "profileSegue", sender: self)
    }
    
    func onCancel() {
        reply = nil
    }
}
    


