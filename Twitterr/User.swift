//
//  User.swift
//  Twitterr
//
//  Created by CK on 4/15/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation


class UK {
    static let id = "id_str"
    static let name = "name"
    static let screenName = "screen_name"
    static let description = "description"

    //appears above below location/url or description
    static let followersCount = "followers_count"
    static let friendsCount = "friends_count"
    static let tweetsCount = "statuses_count"
    
    //appears below user profile info.
    static let url = "url"
    static let location = "location"

    
    struct images {
        static let profileImageUrl = "profile_image_url_https"
        static let profileBackgroundImage = "profile_background_image_url_https"
        static let profileUserBackgroundImage = "profile_use_background_image"
        static let profileColor = "profile_background_color"
        static let profileBannerUrl = "profile_banner_url"
    }

}

class User: NSObject {
    var response: NSDictionary?

    //in order of appearance in profile page.
    var id:String?
    var descriptionText: String?
    var name: String?
    var screenName: String?

    var location: String?
    var url: String?
    
    var followersCount: Int
    var followingCount: Int
    var tweetsCount: Int
    
    var profileBanner: String?
    var profileImage: String?
    var profileBannerURL : URL?
    var profileImageURL:URL?
    

    
    static let currentUserDataKey = "com.ck.loggedinuser"
    static let userDidLogoutNotification = "UserDidLogout"
    
    

    
    init(dictionary: NSDictionary) {
        response = dictionary
        id = dictionary[UK.id] as? String
        descriptionText = dictionary[UK.description] as? String
        name = dictionary[UK.name] as? String
        screenName = dictionary[UK.screenName] as? String
        
        if let profileImageStringUrl = dictionary[UK.images.profileImageUrl] as? String {
            profileImage = profileImageStringUrl
            profileImageURL = URL(string: profileImageStringUrl)
        }
        
        if let profileBannerStringUrl = dictionary[UK.images.profileBannerUrl] as? String {
            profileBanner = profileBannerStringUrl
            profileBannerURL = URL(string: profileBannerStringUrl)
        }
        
        
        location = dictionary[UK.location] as? String
        url = dictionary[UK.url] as? String
        followersCount = (dictionary[UK.followersCount] as? Int) ?? 0
        followingCount = (dictionary[UK.friendsCount] as? Int) ?? 0
        tweetsCount = (dictionary[UK.tweetsCount] as? Int) ?? 0
    }
    
    private static var _current: User?
    static let api = TwitterApi.shared
    static let defaults = UserDefaults.standard

    class var me: User? {
        get{
            if _current == nil {
                let userData =  defaults.object(forKey: currentUserDataKey) as? Data
                if let userData = userData {
                    let dictionary = NSKeyedUnarchiver.unarchiveObject(with: userData)
                    if(dictionary != nil){
                        _current = User.init(dictionary: dictionary as! NSDictionary)
                    }else{
                        TwitterApi.shared?.logout()
                    }
                }
            }
            return _current
        }
        set(user){
            _current = user
            if let user = user {
                let data = NSKeyedArchiver.archivedData(withRootObject: user.response!)
                defaults.set(data, forKey: currentUserDataKey)
            }
            else {
                defaults.set(nil, forKey: currentUserDataKey)
            }
            
            defaults.synchronize()
        }
    }
    
    
    func info(parameters: [String: Any], success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        User.api?.userDetails(parameters: parameters, success: success, failure: failure)
    }
    

    
}
