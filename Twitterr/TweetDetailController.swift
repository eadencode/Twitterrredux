//
//  TweetDetailController.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit
import AFNetworking
class TweetDetailController: UIViewController {
    @IBOutlet weak var retweetIconHeight: NSLayoutConstraint!

    @IBOutlet weak var retweetedHeight: NSLayoutConstraint!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favCount: UILabel!
    @IBOutlet weak var dateString: UILabel!
    @IBOutlet weak var tweetText: ActiveLabel!
    @IBOutlet weak var userProfileUrl: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userDisplayName: UILabel!
    @IBOutlet weak var userRetweeted: UILabel!
    @IBOutlet weak var favIcon: UIButton!
    
    @IBOutlet weak var retweetIcon: UIButton!
    var tweet:Tweet!
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()
        renderTweetInfo()
        Style.styleNav(viewController: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReplyDetail(_ sender: Any) {
        
        self.performSegue(withIdentifier: "replyFromDetail", sender: self)
    }

    @IBAction func onRetweetAction(_ sender: Any) {
        let count = self.tweet.retweetCount
        if(!tweet.retweeted!) {
            tweet.reTweet( success: { (tweetArg) in
//                self.tweet = tweetArg
            }, failure: { (error) in
                print("failed to retweet \(error.localizedDescription)")
            })
            self.tweet.retweetCount = count + 1
            self.tweet.retweeted = true
            self.retweetIcon.setImage(#imageLiteral(resourceName: "retweetgreen"), for: .normal)

        }else {
            tweet.unReTweet( success: { (tweetArg) in
//                self.tweet = tweetArg
            }, failure: { (error) in
                print("failed to unretweet \(error.localizedDescription)")
            })
            let countZero = (count == 0)
            self.tweet.retweetCount = countZero ? 0 : (count - 1)
            self.tweet.retweeted = false
            self.retweetIcon.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
        }
        self.retweetCount.text = "\(self.tweet.retweetCount)"

    }
    
    
    @IBAction func onFavoriteDetail(_ sender: Any) {
        let count = self.tweet.retweetCount

        if(!tweet.favorited!) {
            tweet.favorite( success: { (tweetArg) in
//                self.tweet = tweetArg

            }, failure: { (error) in
                print("failed to favorite \(error.localizedDescription)")
            })
            self.tweet.favouritesCount = count + 1
            self.tweet.favorited = true
            self.favIcon.setImage(#imageLiteral(resourceName: "favred"), for: .normal)
        }
        else {
            tweet.unfavorite( success: { (tweetArg) in
//                self.tweet = tweetArg
            }, failure: { (error) in
                print("failed to unfavorite \(error.localizedDescription)")
            })
            let countZero = (count == 0)
            self.tweet.favouritesCount = countZero ? 0 : (count - 1)
            self.tweet.favorited = false
            self.favIcon.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
        }
        self.favCount.text = "\(self.tweet.favouritesCount)"

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "replyFromDetail") {
            let tweetController = segue.destination as! TweetController
            tweetController.replyTo = tweet
            tweetController.delegate = self
        }
        if (segue.identifier == "profileSegue") {
            let profileNav = segue.destination as! UINavigationController
            let profileController = profileNav.viewControllers.first as! ProfileViewController
            profileController.user = tweet.user
            

        }
        
    }
    
    
    func renderTweetInfo() {
        userProfileUrl.setImageWith((tweet.userProfileImage)!)
        favCount.text = "\(tweet.favouritesCount)"
        retweetCount.text = "\(tweet.retweetCount)"
        
        makeRetweet(count: tweet.retweetCount)
        makeFavorite(count: tweet.favouritesCount)
        
        if let tweetedAt = tweet.tweetedDate {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = DateFormatter.Style.short
            dateformatter.timeStyle = DateFormatter.Style.short
            dateString.text = dateformatter.string(from: tweetedAt)
        }
        userName.text = tweet.userName
        userDisplayName.text = tweet.userScreenName
        if let retweeteduser = tweet?.retweetUserName {
            userRetweeted.text = retweeteduser + " retweeted"
            retweetedHeight.constant = 15
            retweetIconHeight.constant = 17
            
        } else{
            retweetedHeight.constant = 0
            retweetIconHeight.constant = 0
        }
        tweetText.customize { (label) in
            label.text = self.tweet.text
            Style.styleTwitterAttributedLabel(label: label)
        }
    }

    
    func makeFavorite(count:Int) {
        if(count != 0) {
            self.favCount.text = "\(count)"
            if(tweet.favorited)!{
                self.favIcon.setImage(#imageLiteral(resourceName: "favred"), for: .normal)
            }
        }else{
            self.favCount.text = "0"
        }
    }
    
    
    func makeRetweet(count:Int) {
        if(count != 0) {
            self.retweetCount.text = "\(count)"
            if(tweet.retweeted)! {
                self.retweetIcon.setImage(#imageLiteral(resourceName: "retweetgreen"), for: .normal)
            }
        }else{
            self.retweetCount.text = "0"
        }
    }
    
    



}

extension TweetDetailController :  NewTweetProtocol {
    
    func onReplyOrNewTweet(tweet: Tweet) {
        
    }
    
    func onCancel() {
        
    }
}


