//
//  Tweet.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation



class TK {
    static let id = "id_str"
    static let text = "text"
    static let retweetCount = "retweet_count"
    static let favoritesCount = "favorite_count"
    static let createdAt = "created_at"
    static let user = "user"
    static let retweeted = "retweeted"
    static let favorited = "favorited"
    static let inReplyToUserId = "in_reply_to_user_id_str"
    static let retweetdStatus = "retweeted_status"
    static let screenName = "screen_name"
    static let name = "name"
    static let profileImageUrl = "profile_image_url_https"
    static let userRetweeted = "userRetweeted"
    struct filter {
        static let userId = "user_id"
        static let includeRetweets =  "include_rts"
    }
}



class Tweet: NSObject, NSCoding {

    var user:User?
    var text: String?
    var retweetCount: Int = 0
    var favouritesCount: Int = 0
    var tweetedDate: Date?
    var id: String?

    var userName: String?
    var userScreenName: String?
    var userProfileImage: URL?
    var retweeted: Bool?
    var favorited: Bool?
    var retweetedStatus:NSDictionary?
    var retweetUserName: String?
    var retweetUserScreenName: String?
    var timeAgo:String?
    var inReplyToUser:String?
    var replyUser:User?
    var retweetedId:String?
    
    //for pagination
    static var lastTweetId:String?
    //for notification
    static var userDidRetweeted = TK.userRetweeted

    public func encode(with aCoder: NSCoder) {
        
    }
    
    static let api = TwitterApi.shared

    public required init?(coder aDecoder: NSCoder) {
        
    }
    

    init(dictionary: NSDictionary) {
        text = dictionary[TK.text] as? String
        retweetCount = (dictionary[TK.retweetCount] as? Int) ?? 0
        favouritesCount = (dictionary[TK.favoritesCount] as? Int) ?? 0
        let timeStampString = dictionary[TK.createdAt] as? String
        if let timeStampString = timeStampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            tweetedDate = formatter.date(from: timeStampString)
            let dateFormatter = DateFormatter()
            timeAgo = dateFormatter.tiwtterTimeSince(from: tweetedDate! as NSDate)
        }
        user = User(dictionary: dictionary[TK.user] as! NSDictionary)
        id = dictionary[TK.id] as? String
        
        retweeted = dictionary[TK.retweeted] as? Bool ?? false
        favorited = dictionary[TK.favorited] as? Bool ?? false
        let inreplyTouser = dictionary[TK.inReplyToUserId] as?  String
        if inreplyTouser != nil {
            self.inReplyToUser = inreplyTouser
        }
        let retweetStatus = dictionary[TK.retweetdStatus] as? NSDictionary
        if retweetStatus != nil {
            self.retweetedStatus = retweetStatus
            let user = retweetStatus?[TK.user] as? NSDictionary
            userName = user?[TK.screenName] as? String
            userScreenName = user?[TK.name] as? String
            let profileImage = user?[TK.profileImageUrl] as? String
            userProfileImage = URL(string: profileImage!)
            let retweetUser = dictionary[TK.user] as? NSDictionary
            retweetUserName = retweetUser?[TK.screenName] as? String
            retweetUserScreenName = retweetUser?[TK.name] as? String
            retweetedId = retweetStatus?[TK.id] as? String
        }
        else {
            let user = dictionary[TK.user] as? NSDictionary
            if user != nil
            {
                userName = user?[TK.screenName] as? String
                userScreenName = user?[TK.name] as? String
                let profileImage = user?[TK.profileImageUrl] as? String
                userProfileImage = URL(string: profileImage!)
            }
        }
        
    }

    class func tweetsWith(dictionaryArray: [NSDictionary]) -> [Tweet] {
        var tweets: [Tweet] = []
        
        for dictionary in dictionaryArray {
            let tweet = Tweet(dictionary: dictionary)
            if tweet.inReplyToUser != nil {
                let parameters = [TK.filter.userId : tweet.inReplyToUser]
                Tweet.user(parameters: parameters as [String : AnyObject], success: { (replyuser) in
                    tweet.replyUser = replyuser
                }, failure: { (error) in
                    print("Error in retrieving in reply user \(error.localizedDescription)")
                })
            }
            tweets.append(tweet)
            lastTweetId = tweet.id
        }
        return tweets
    }

    func favorite(success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.favorite(tweet: self, success: { (tweetArg) in
               success(tweetArg)
        }, failure: { (error) in
                failure(error)
        })
    }
    
    func unfavorite(success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.unfavorite(tweet: self, success: { (tweetArg) in
            success(tweetArg)
        }, failure: { (error) in
            failure(error)
        })
    }


    func reTweet(success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.reTweet(tweet: self, success: { (tweetArg) in
            success(tweetArg)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    func unReTweet(success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.getAndUnRetweet(tweet: self, success: { (tweetArg) in
            success(tweetArg)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    class func timeline(parameters: [String: Any]?, success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        User.api?.timeline(parameters: parameters, success: success, failure: failure)
    }
    
    class func mentions(parameters: [String: Any]?, success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        User.api?.mentions(parameters: parameters, success: success, failure: failure)
    }
    
    class func home(parameters: [String: AnyObject]? ,success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.home(parameters: parameters!, success: { (newtweets) in
                    success(newtweets)
            }, failure: { (error) in
                 failure(error)
        })
    }

    
    class func tweet(parameters: [String: AnyObject]?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.tweet(parameters: parameters!, success: { (postedTweet) in
            success(postedTweet)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    class func user(parameters: [String: AnyObject]?, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        Tweet.api?.user(parameters: parameters!, success: { (gotuser) in
            success(gotuser)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    

    
    class func timeline(source:TweetsSource , parameters: [String: AnyObject]?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        switch source {
            
            case TweetsSource.HOME :
                Tweet.api?.home(parameters: parameters!, success: { (newtweets) in
                    success(newtweets)
                }, failure: { (error) in
                    failure(error)
                })
            case TweetsSource.MENTIONS :
                var newParams = parameters
                newParams?[TK.filter.includeRetweets] = 1 as AnyObject
                Tweet.api?.mentions(parameters: newParams, success: { (tweets) in
                    success(tweets)
                }, failure: { (error) in
                    failure(error)
                })
            
            case TweetsSource.SEARCH :
                var newParams = parameters
//                newParams?[TK.filter.includeRetweets] = 1 as AnyObject
                Tweet.api?.search(parameters: newParams, success: { (tweets) in
                    success(tweets)
                }, failure: { (error) in
                    failure(error)
                })
        }
    }
    
   }
