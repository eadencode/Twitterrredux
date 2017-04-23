//
//  TwitterApi.swift
//  Twitterr
//
//  Created by CK on 4/14/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

//MARK : Base
let baseUrl =  "https://api.twitter.com"

//MARK : Auth
let consumerKey = "BmQBNNGFgMmm7QNLLufoS65iG"
let consumerSecret = "LaAyniGXUMZQZfnQcBm7u3t5gli1d4ahpFuu1H6rBOeKTdhpnp"
let appOnlyUrl = "/oauth2/token"
let requestTokenUrl = "/oauth/request_token"
let authorizeUrl = "/oauth/authorize"
let accessTokenUrl = "/oauth/access_token"
let accountVerifyUrl = "/1.1/account/verify_credentials.json"


//MARK : Tweets
let homeUrl = "/1.1/statuses/home_timeline.json"
let userUrl = "/1.1/users/lookup.json"

let retweetUrl = "/1.1/statuses/retweet/"
let unretweetUrl = "/1.1/statuses/unretweet/"
let createFavoriteUrl = "/1.1/favorites/create.json"
let destroyFavoriteUrl = "/1.1/favorites/destroy.json"
let listFavoriteUrl = "/1.1/favorites/list.json"
let tweetUrl = "/1.1/statuses/update.json"
let userTimelineUrl = "/1.1/statuses/user_timeline.json"
let mentionsTimelineUrl = "/1.1/statuses/mentions_timeline.json"
let searchTimelineUrl = "/1.1/search/tweets.json"
let userInfoUrl = "/1.1/users/show.json"

//let full_tweet = GET("https://api.twitter.com/1.1/statuses/show/" + original_tweet_id + "json?include_my_retweet=1")
let fullTweetUrl = "/1.1/statuses/show/"
//let retweet_id = full_tweet.current_user_retweet.id_str

//MARK : App Config
let appUrlOAuthCallback = "twitterr://oauth"
var globalTweets = [Tweet]()



class TwitterApi:BDBOAuth1SessionManager{
    
    static let shared = TwitterApi(baseURL: URL(string: baseUrl), consumerKey: consumerKey, consumerSecret: consumerSecret)

    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    var registeredAccounts:[UserAccount] = [UserAccount]()
    
    var requestToken:BDBOAuth1Credential?
    //MARK : OAuth & Login
    
    func login(newUser:Bool, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        if(newUser) {
            deauthorize()
        }

        fetchRequestToken (withPath: requestTokenUrl, method: "GET", callbackURL: URL(string: appUrlOAuthCallback)! , scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            var authUrl = baseUrl + authorizeUrl + "?oauth_token=\(requestToken.token!)"
            if(newUser) {
                authUrl = authUrl + "&force_login=1"
            }
            let url = NSURL(string: authUrl)! as URL
            
            UIApplication.shared.open(url)
            
        }, failure: { (error: Error?) in
            self.loginFailure?(error!)
        })
    }
    
    func open(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: accessTokenUrl, method: "POST", requestToken: requestToken, success: { (accesToken: BDBOAuth1Credential?) in
            self.verify(success: { (user: User) in
                User.me = user
                self.loginSuccess?()
                self.requestToken = requestToken
                let userAccount = UserAccount(user: user, token: requestToken!)
                self.addNewAccount(userAccount: userAccount)
                UserAccount.current = userAccount
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserAccount.userAccountAdded), object: nil)
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
        },failure: { (error: Error?) in
            self.loginFailure?(error!)
        })
    }
    
    
    func verify(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get(accountVerifyUrl, parameters: nil, success: { (task, response) in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error?) in
            failure(error!)
        })
    }
    
    
    func logout() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
        User.me = nil
        if let account = UserAccount.current {
            removeAccount(userAccount: account)
        }
        UserAccount.current = nil
        deauthorize()
    }
    
    
    
    func home(parameters: [String: AnyObject]? ,success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        
        if(registeredAccounts.count == 0 ) {
            registeredAccounts.append(UserAccount(user: User.me!, token:self.requestSerializer.accessToken))
        }
        get(homeUrl, parameters: parameters, success: { (task, response) in
            let dictionariesArray = response as! [NSDictionary]
            self.saveResponse(dictionary: dictionariesArray)
            let tweets = Tweet.tweetsWith(dictionaryArray: dictionariesArray)
            success(tweets)
        }) { (task, error) in
            let tweets = Tweet.tweetsWith(dictionaryArray: self.retrieveResponse())
            success(tweets)
//            failure(error)
        }
    }
    
    
    
    
    func user(parameters: [String: AnyObject]? ,success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get(homeUrl, parameters: parameters, success: { (task, response) in
            let dictionariesArray = response as! [NSDictionary]
            let usr = User(dictionary: dictionariesArray[0])
            success(usr)
        }) { (task, error) in
            failure(error)
        }
    }
    
    
 
    func tweet(parameters: [String: AnyObject]?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post(tweetUrl, parameters: parameters, success: { (task, response) in
            success(Tweet.init(dictionary: response as! NSDictionary))
        }) { (task, error) in
            failure(error)
        }
    }
    
    
    func reTweet(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post(retweetUrl + tweet.id!+".json", parameters: nil, success: { (task:  URLSessionDataTask, response: Any?) in
            success(Tweet.init(dictionary: response as! NSDictionary))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("\nError posting retweet:: \(error) \n\n")
            failure(error)
        })
    }
    
    
    //These  apis take long time to reflect onserver.
    func getAndUnRetweet(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        var originalTweetId = tweet.id
        if(!tweet.retweeted!) {
            print("Will get auth Failure")
        }
        else{
            if tweet.retweetedStatus != nil  {
                originalTweetId = tweet.id
            }else{
                originalTweetId = tweet.retweetedId
            }
        }
        
        var idToUnTweet = originalTweetId
        if(idToUnTweet != nil) {
            let parameters = ["include_my_retweet" : "1"]

             get(fullTweetUrl+idToUnTweet!+".json", parameters: parameters, success: { (task, response) in
                let dictionary = response as! NSDictionary
                let currentUserRetweetDetails = dictionary["current_user_retweet"] as? NSDictionary
                if let curd = currentUserRetweetDetails {
                    idToUnTweet = curd["id_str"] as? String
                }
                self.unRetweet(tweetId: idToUnTweet!, success: { (tweet) in
                    print("success")
                    success(tweet)
                }, failure: { (error) in
                    failure(error)
                    print("Failure")
                })
                
            }) { (task, error) in
                failure(error)
                print("Error \(error.localizedDescription)")
            }
        }
        
       
    }
    
    func showFull(tweetId: String, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) -> ()) {
        let parameters = ["include_my_retweet" : "1"]
        get(fullTweetUrl+tweetId+".json", parameters: parameters, success: { (task, response) in
            let dictionary = response as! NSDictionary
            success(dictionary)
        }) { (task, error) in
            print("Error \(error.localizedDescription)")
        }
    }
    
    
    
    func unRetweet(tweetId: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post(unretweetUrl + tweetId+".json", parameters: nil, success: { (task:  URLSessionDataTask, response: Any?) in
            success(Tweet.init(dictionary: response as! NSDictionary))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("\nError posting unretweetUrl:: \(error) \n\n")
            failure(error)
        })
    }
    
    
    
    func favorite(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let parameters = ["id": tweet.id]
         post(createFavoriteUrl, parameters: parameters, success: { (task:  URLSessionDataTask, response: Any?) in
            success(Tweet.init(dictionary: response as! NSDictionary))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    
    func unfavorite(tweet: Tweet, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let parameters = ["id": tweet.id]
        post(destroyFavoriteUrl, parameters: parameters, success: { (task:  URLSessionDataTask, response: Any?) in
            success(Tweet.init(dictionary: response as! NSDictionary))
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    
    
    func userDetails(parameters: [String: Any], success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get(userInfoUrl, parameters: parameters, success: { (task:  URLSessionDataTask, response: Any?) in
            let user = User(dictionary: response as! NSDictionary)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    // Get user current timeline
    func timeline(parameters: [String: Any]?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get(userTimelineUrl, parameters: parameters, success: { (task: URLSessionDataTask, response: Any?) in
            let dictionariesArray = response as! [NSDictionary]
            let tweets = Tweet.tweetsWith(dictionaryArray: dictionariesArray)
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    // Get user mentions
    func mentions(parameters: [String: Any]?, success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        get(mentionsTimelineUrl, parameters: parameters,  success: { (task: URLSessionDataTask, response: Any?) in
            let dictionariesArray = response as! [NSDictionary]
            let tweets = Tweet.tweetsWith(dictionaryArray: dictionariesArray)
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
//    https://api.twitter.com/1.1/search/tweets.json
    

    
    func search(parameters: [String: Any]?, success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        get(searchTimelineUrl, parameters: parameters,  success: { (task: URLSessionDataTask, response: Any?) in
            let dictionariesArray = (response as! NSDictionary)["statuses"] as! [NSDictionary]
            
//            let dictionariesArray = response as! [NSDictionary]
            let tweets = Tweet.tweetsWith(dictionaryArray: dictionariesArray)
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func saveTweets(tweets:[Tweet]){
        let tweetsData = NSKeyedArchiver.archivedData(withRootObject: tweets)
        UserDefaults.standard.set(tweetsData, forKey: "tweets")
    }
    
    func loadTweets() -> [Tweet]{
        let tweetsData = UserDefaults.standard.object(forKey: "tweets") as? NSData
        if let tweetsData = tweetsData {
            let tweetsArray = NSKeyedUnarchiver.unarchiveObject(with: tweetsData as Data) as? [Tweet]
            
            if let tweetsArray = tweetsArray {
                print("Number of tweets to save \(tweetsArray.count)")
                return tweetsArray
            }
            
        }
        return [Tweet]()
    }
    
    
    func saveResponse(dictionary:[NSDictionary]) {
        let data:NSData = NSKeyedArchiver.archivedData(withRootObject: dictionary) as NSData
        UserDefaults.standard.set(data, forKey: "saved.response")
        UserDefaults.standard.synchronize()
    }
    
    func retrieveResponse()->[NSDictionary] {
        var data = UserDefaults.standard.object(forKey: "saved.response")
        if let data = data  {
            var nsdatauw = data as! NSData
            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: nsdatauw as Data) as! [NSDictionary]
            return dictionary
        }
        
        return [NSDictionary]()
    }
    
    
    //MARK : Adding/Deleting/Switching user accounts.
    
    
    func addNewAccount(userAccount: UserAccount) {
        if(registeredAccounts.count >= 0 ) {
            if(!registeredAccounts.contains(where: {$0.user?.name! == userAccount.user?.name!})) {
                registeredAccounts.append(userAccount)
            }
        }
        //notify
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserAccount.userAccountAdded), object: nil)
    }
    
    func removeAccount(userAccount: UserAccount) {
        if(registeredAccounts.count > 0 ) {
            if(registeredAccounts.contains(where: {$0.user?.name! == userAccount.user?.name!})) {
                let index = registeredAccounts.index(of: userAccount)
                if let foundIndex = index {
                    registeredAccounts.remove(at: foundIndex)
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserAccount.userAccountRemoved), object: nil)

        //notify
    }
    
    func switchAccount(userAccount: UserAccount) {
        //remove counts
//        if(registeredAccounts.count > 0 ) {
//            if(registeredAccounts.contains(userAccount)) {
//                let index = registeredAccounts.index(of: userAccount)
//                if let foundIndex = index {
//                    registeredAccounts.remove(at: foundIndex)
//                }
//            }
//        }
        self.requestSerializer.removeAccessToken()
        deauthorize()
        User.me = nil
        self.requestSerializer.saveAccessToken(userAccount.requestToken)
        User.me = userAccount.user
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserAccount.userAccountSwitched), object: nil)

        //notify
    }
    
    
    
    
}

