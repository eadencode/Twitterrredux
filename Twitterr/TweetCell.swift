//
//  TweetCell.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import UIKit


protocol RetweetProtocol  {
    func onReplyOfTweet(tweet:Tweet)
    func performProfileSegue(tweet:Tweet)
    func urlTap(url:URL?)
    func hashTagTap(tag:String?)
    func mentionsTap(mention:String?)
}


class TweetCell: UITableViewCell {

    @IBOutlet weak var retweetedIconHeight: NSLayoutConstraint!
    @IBOutlet weak var retweetedHeight: NSLayoutConstraint! //15
    @IBOutlet weak var favHeart: UIButton!
    
    @IBOutlet weak var userProfileImageUrl: UIImageView!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var reTweetCount: UILabel!
    @IBOutlet weak var tweetText: ActiveLabel!
    @IBOutlet weak var tweetedAgo: UILabel!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRetweeted: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetStack: UIStackView!
    @IBOutlet weak var favStack: UIStackView!
    var delegate:RetweetProtocol?
    var fromAction:Bool = false
    var indexRow:Int?
    
    var tweet:Tweet!  {
        didSet {
            if(tweet != nil) {
                layoutTweetText()
                layoutUserDetails()
                layoutFavAndRetweets()
                userName.sizeToFit()
                tweetedAgo.text = "•\(tweet?.timeAgo ?? "")"
                let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapOfImage(sender:)))
                userProfileImageUrl.addGestureRecognizer(gesture)
                
            }
        }
        
    }
    
    func onTapOfImage(sender:UITapGestureRecognizer) {
        delegate?.performProfileSegue(tweet: tweet)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func selectedIndex(index:Int?){
        indexRow = index
        userProfileImageUrl.tag = index!
    }
    
    @IBAction func onReply(_ sender: Any) {
        if(delegate != nil ) {
            delegate?.onReplyOfTweet( tweet: tweet)
        }
    }
    
    @IBAction func onFav(_ sender: Any) {
        if(!tweet.favorited!) {
           fav()
        }else{
           unfav()
        }
            
    }
    
    
    @IBAction func onRetweet(_ sender: Any) {
        
        if(!tweet.retweeted!) {
            retweet()
        }else{
            unretweet()
        }
    }
    
 
    
    override func prepareForReuse() {
        tweet = nil
        self.favoriteCount.text = ""
        self.reTweetCount.text = ""
        self.favHeart.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
        self.retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
        self.reTweetCount.textColor = UIColor.gray
        self.favoriteCount.textColor = UIColor.gray
    }

}
//Rendering and Layout of Cell

extension TweetCell {
    
    func layoutFavAndRetweets(){
        if let retweeteduser = tweet?.retweetUserName {
            userRetweeted.text = retweeteduser + " retweeted"
            retweetedIconHeight.constant = 17
            retweetedHeight.constant = 15
        }else{
            retweetedIconHeight.constant = 0
            retweetedHeight.constant = 0
        }
        
        var retweetedCount = 0
        if( tweet.retweetCount != 0) {
            retweetedCount = tweet.retweetCount
        }
        var favCount = 0
        if( tweet.favouritesCount != 0) {
            favCount = tweet.favouritesCount
        }
        if(tweet.favorited!  && favCount == 0) {
            favCount = 1
        }
        if(tweet.retweeted!  && retweetedCount == 0) {
            retweetedCount = 1
        }
        favoriteCount.text = favCount != 0 ? "\(favCount)" :""
        reTweetCount.text = retweetedCount != 0 ? "\(retweetedCount)" :""
        makeFavorite(count: favCount, fav: tweet.favorited!)
        makeRetweet(count: retweetedCount, retweeting: tweet.retweeted!)
    }
    
    func layoutUserDetails(){
        userName.text = tweet?.userScreenName
        userId.text = tweet?.userName
        userProfileImageUrl.setImageWith((tweet?.userProfileImage)!)
        userProfileImageUrl.layer.cornerRadius = 5
        userProfileImageUrl.clipsToBounds = true
        userProfileImageUrl.isUserInteractionEnabled = true
    }
    
    func layoutTweetText() {
        tweetText.customize { (label) in
            label.text = tweet.text
            if let replyuser = tweet.replyUser?.name  {
                label.text = "Replying to @\(replyuser)" + tweet.text!
            }
            Style.styleTwitterAttributedLabelForCell(label: label)
            
        }
        
        
        tweetText.handleURLTap { (url) in
            self.delegate?.urlTap(url: url)
        }
        
        tweetText.handleHashtagTap { (hashTag) in
            self.delegate?.hashTagTap(tag: hashTag)
        }
        
        tweetText.handleMentionTap { (mention) in
            self.delegate?.mentionsTap(mention: mention)
        }
    }
    
    
}



//Retweet Actions

extension TweetCell {
    
    
    func retweet() {
        let count =  self.tweet.retweetCount
        tweet.reTweet(success: { (tweetArg) in
        }, failure: { (error) in
            print("failed to retweet")
        })
        self.makeRetweet(count: count+1,retweeting: true)
    }
    
    
    func unretweet() {
        let countZero  = (self.tweet.retweetCount == 0)
        let count  = self.tweet.retweetCount

        tweet.unReTweet(success: { (tweetArg) in
            
        }, failure: { (error) in
            print("failed to retweet")
        })
        self.makeRetweet(count: (countZero ? 0 : (count - 1)) ,retweeting: false)
    }
    
    func fav() {
        let count =  self.tweet.favouritesCount
        tweet.favorite(success: { (tweetArg) in

        }, failure: { (error) in
            print("Error in favorite \(error.localizedDescription)")
        })
        self.makeFavorite(count: count+1 ,fav: true)
        
    }
    
    
    func unfav() {
        let countZero  = (self.tweet.favouritesCount == 0)
        let count  = self.tweet.favouritesCount
            tweet.unfavorite(success: { (tweetArg) in
                
            }, failure: { (error) in
                print("Error in favorite \(error.localizedDescription)")
            })
        self.makeFavorite(count: (countZero ? 0 : (count - 1)) ,fav: false)
    }
    
    
    
    
    
    func makeFavorite(count:Int ,fav:Bool) {
        let countToLabel = count
        let color = fav ? UIColor.red : UIColor.gray
        self.favoriteCount.textColor = color
        let image = fav ? #imageLiteral(resourceName: "favred") : #imageLiteral(resourceName: "favorite")
        self.favoriteCount.text = "\(countToLabel)"
        self.favHeart.setImage(image, for: .normal)
        self.tweet.favorited = fav
        self.tweet.favouritesCount = count
        if(countToLabel == 0) {
            self.favoriteCount.text = ""
        }
        
    }
    
    
    func makeRetweet(count:Int,retweeting:Bool) {
        
        let countToLabel = count
        self.tweet.retweeted = retweeting
        self.tweet.retweetCount  = count
        let color = retweeting ? UIColor.green : UIColor.gray
        self.reTweetCount.textColor = color
        let image = retweeting ? #imageLiteral(resourceName: "retweetgreen") : #imageLiteral(resourceName: "retweet")
        self.reTweetCount.text = "\(countToLabel)"
        self.retweetButton.setImage(image, for: .normal)
        if(countToLabel == 0) {
            self.reTweetCount.text = ""
        }
        
    }


    
}
