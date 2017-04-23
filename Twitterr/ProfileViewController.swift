//
//  ProfileViewController.swift
//  Twitterr
//
//  Created by CK on 4/20/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit
import MBProgressHUD

let offset_HeaderStop:CGFloat = 30.0
let offset_B_LabelHeader:CGFloat = 15.0
let distance_W_LabelHeader:CGFloat = 35.0


class ProfileViewController: UIViewController ,NewTweetProtocol {
    
    @IBOutlet weak var tweetsTable: UITableView!
    @IBOutlet weak var avatarg: UIImageView!
    @IBOutlet weak var imageHeaderView: UIImageView!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var numOfFollowers: UILabel!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var urlwebsite: UILabel!
    @IBOutlet weak var numFollowing: UILabel!
    @IBOutlet weak var linkicon: UIImageView!
    @IBOutlet weak var locicon: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var uiPage: UIPageControl!

    var tweets:[Tweet]? = nil
    var reply:Tweet?
    var parameters:[String:Any?] = ["count": 20]
    var user:User?
    
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var view2: UIView!
    
    @IBOutlet weak var view1: UIView!

    var _avatarImageSize:CGFloat = 70
    var _avatarImageCompressedSize:CGFloat = 44
    
    var _customTitleView:UIView?
    var tableViewHeader : UIView?

    @IBOutlet weak var leadingView2: NSLayoutConstraint!
    @IBOutlet weak var trailingView2: NSLayoutConstraint!
  
    override func viewDidLoad() {
        super.viewDidLoad()
//        layoutNavBar()
    
        if(user == nil){
            user = User.me
        }
        tweetsTable.delegate = self
        tweetsTable.dataSource = self
        tableViewHeader = tweetsTable.tableHeaderView
        initializeTweetsTable()
        Style.styleNav(viewController: self)
        
        if let loc = user?.location {
            location.text = loc
            location.isHidden = false
        }else{
            location.isHidden = true
        }
        
        if let link = user?.url {
            urlwebsite.isHidden = false
            urlwebsite.text = link
        }else{
            urlwebsite.isHidden = true
        }
        if let desc = user?.descriptionText {
            userDescription.text = "\" \(desc) \" "
        }
        userHandle.text = user?.name
        if let screenName = user?.screenName {
        userScreenName.text = screenName
        }
        numFollowing.text = user?.followingCount == 0 ? "0" : suffixNumber(amount: Double((user?.followingCount)!))
        numOfFollowers.text = user?.followersCount == 0 ? "0" : suffixNumber(amount: Double((user?.followersCount)!))
        
        if let bannerURL = user?.profileBannerURL {
            //debugPrint("user banner url is \(bannerURL)")
            imageHeaderView.setImageWith(bannerURL)
        } else {
            imageHeaderView.backgroundColor = UIColor.black
        }
        
        if let profileURL = user?.profileImageURL {
            avatarg.setImageWith(profileURL, placeholderImage: #imageLiteral(resourceName: "twitter"))
        } else {
            avatarg.image = #imageLiteral(resourceName: "twitter")
        }
        
        avatarg.layer.cornerRadius = 5.0
        avatarg.layer.borderColor = UIColor.white.cgColor
        avatarg.layer.borderWidth = 3.0
        avatarg.clipsToBounds = true
        avatarg.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        scrollView.contentSize = CGSize(width: view1.bounds.size.width * 2, height: view1.bounds.size.height)
        scrollView.isPagingEnabled = true
        
        observeReplies()
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: false)
    }
    
    

    
    func suffixNumber(amount:Double) -> String {
        let sign = ((amount < 0) ? "-" : "" )
        let num = fabs(amount)
        if (num < 1000.0){
            return "\(sign)\(num)"
        }
        let exp:Int = Int(log10(num) / 3.0 ) //log10(1000));
        let units:[String] = ["K","M","G","T","P","E"]
        let roundedNum:Int = Int(round(10 * num / pow(1000.0,Double(exp))) / 10)
        return "\(roundedNum)\(units[exp-1])";
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tweetsTable.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            //refresh control height is 60.
            self.tweetsTable.contentInset = UIEdgeInsetsMake( y-65, 0, 0, 0)
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }

    


    
    @IBAction func onPageChanged(_ sender: Any) {
        let pc = sender as! UIPageControl
        let offset = scrollView.bounds.width * CGFloat(pc.currentPage)
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
    
    func observeReplies() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Tweet.userDidRetweeted), object: nil, queue: OperationQueue.main) { (Notification) in
            if let userInfo  = Notification.userInfo {
                let tweet = userInfo["tweet"] as! Tweet
                self.tweets?.insert(tweet, at: 0)
                self.tweetsTable.reloadData()
            }
        }
    }

    @IBAction func onCancelX(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func refreshTweets() {
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: false)
    }

    func moreTweets() {
        parameters["max_id"] = Tweet.lastTweetId!
        getTweets(parameters: parameters as [String : AnyObject], progress: false,isMore: true)
    }

    func getTweets(parameters: [String:AnyObject],progress:Bool ,isMore:Bool) {
        if(progress){
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        let parameters: [String: Any] = [TK.filter.userId: (user?.id)!, TK.filter.includeRetweets: 1]
        Tweet.timeline(parameters: parameters as [String : AnyObject], success: { (newtweets) in
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

}


//MARK : Tweets Table

extension ProfileViewController : UITableViewDelegate ,UITableViewDataSource {
    
    func initializeTweetsTable() {
        tweetsTable.delegate = self
        tweetsTable.dataSource = self
        tweetsTable.rowHeight = UITableViewAutomaticDimension
        tweetsTable.estimatedRowHeight = 200
        tweetsTable.addPullToRefreshHandler {
            self.refreshEnded()
        }
        tweetsTable.addInfiniteScrollingWithHandler {
            self.infiniteScroll()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        if offset < 0 {
            let headerScaleFactor:CGFloat = -(offset) / imageHeaderView.bounds.height
            let headerSizevariation = ((imageHeaderView.bounds.height * (1.0 + headerScaleFactor)) - imageHeaderView.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            imageHeaderView.layer.transform = headerTransform
            UIView.animate(withDuration: 1, animations: {
                self.imageHeaderView.alpha = 1
                self.navigationItem.titleView = self.customTitleView()
                self.navigationItem.titleView?.layer.zPosition = 2
                self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(60, for: UIBarMetrics.default)

            })
        }
        else {
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            self.navigationItem.titleView?.layer.transform = labelTransform
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarg.bounds.height / 1.4 // Slow down the animation
//            let avatarSizeVariation = ((avatarg.bounds.height * (1.0 + avatarScaleFactor)) - avatarg.bounds.height) / 2.0
            avatarTransform =  CATransform3DTranslate(avatarTransform, 0, max(-offset_HeaderStop, -offset), 0)//CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            UIView.animate(withDuration: 1, animations: { 
                self.imageHeaderView.alpha = 0.4
                self.imageHeaderView.alpha = 1
                self.navigationItem.titleView = self.customTitleView()
                self.navigationItem.titleView?.layer.zPosition = -1
                

            })
            if offset <= offset_HeaderStop {
                if avatarg.layer.zPosition < imageHeaderView.layer.zPosition{
                    imageHeaderView.layer.zPosition = 0
                    UIView.animate(withDuration: 0.2, animations: {
                        self.imageHeaderView.alpha = 0.3
                        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(12, for: UIBarMetrics.default)
                        self.navigationItem.titleView?.layer.zPosition = 2
                    })
                }
            }else {
                if avatarg.layer.zPosition >= imageHeaderView.layer.zPosition{
                    imageHeaderView.layer.zPosition = 0
                    UIView.animate(withDuration: 0.2, animations: {
                        self.imageHeaderView.alpha = 1
                        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(12, for: UIBarMetrics.default)

                        self.navigationItem.titleView?.layer.zPosition = 2
                    })
                }
            }
        }
        
        // Apply Transformations
        
        imageHeaderView.layer.transform = headerTransform
        avatarg.layer.transform = avatarTransform
   }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! TweetCell
        
//        let cell =  Bundle.main.loadNibNamed("TweetCell", owner: self, options: nil)?.first as! ReusableTweetCell
        let tweet = tweets?[indexPath.row]
        cell.tweet = tweet
        cell.delegate = self
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "tweetDetail", sender: indexPath)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let sectionView = UIView()
            let items = ["Tweets","Media","Moments","Favorites"]
        
            let segmentedControl = UISegmentedControl(items: items)
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
            var views = ["super": self.view]
            sectionView.addSubview(segmentedControl)
            sectionView.backgroundColor = UIColor.white
        
            sectionView.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: sectionView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
            sectionView.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: sectionView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
            let separator = UIView()
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = UIColor.lightGray
            sectionView.addSubview(separator)
            views["separator"] = separator
            let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[separator]-0-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: views)
            let constraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:[separator(0.5)]-0-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: views)
        
            sectionView.addConstraints(constraintH)
            sectionView.addConstraints(constraintV)
            return sectionView
        
    }
    
    
    
   func customTitleView() -> UIView {
        if(_customTitleView == nil){
            let myLabel = UILabel()
            myLabel.translatesAutoresizingMaskIntoConstraints = false
            myLabel.text = userHandle.text
            myLabel.numberOfLines = 1
        
            myLabel.textColor = UIColor.white
            myLabel.font  = UIFont.boldSystemFont(ofSize: 14)
        
            let smallText = UILabel()
            smallText.translatesAutoresizingMaskIntoConstraints = false
            if let tweetCount = user?.tweetsCount {
                smallText.text = "\(tweetCount) Tweets"
            }
            smallText.numberOfLines = 1;
            smallText.textColor = UIColor.white
            smallText.font  = UIFont.boldSystemFont(ofSize: 10)

            let wrapper = UIView()
            wrapper.addSubview(myLabel)
            wrapper.addSubview(smallText)
        
            let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[myLabel]-0-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: ["myLabel" :myLabel, "smallText":smallText])
            let constraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[myLabel]-2-[smallText]-0-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views:["myLabel" :myLabel, "smallText":smallText])
            
            wrapper.addConstraints(constraintH)
            wrapper.addConstraints(constraintV)
            
            wrapper.frame = CGRect(x: 0, y: 0, width: max(myLabel.intrinsicContentSize.width, smallText.intrinsicContentSize.width), height: myLabel.intrinsicContentSize.height + smallText.intrinsicContentSize.height + 3)
            wrapper.clipsToBounds = true;
        
            _customTitleView  = wrapper;
        }
        return _customTitleView!
    }
    


    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentTweets = tweets {
            return currentTweets.count
        }
        return 0
    }
    
    
    
    
    
}


//MARK : Reload and infinite scroll.

extension ProfileViewController:RefreshAndLoadProtocol {
    
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

   


extension ProfileViewController : TweetProtocol  {
    func urlTap(url: URL?) {
        //to wk webview
    }

    func mentionsTap(mention: String?) {
        // to onmentisearch api
    }
    
    func hashTagTap(tag: String?) {
        // to hashTag search
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
        
    }
    
    func onCancel() {
        reply = nil
    }
}



