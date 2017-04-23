//
//  UserAccount.swift
//  Twitterr
//
//  Created by CK on 4/23/17.
//  Copyright © 2017 CK. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

let currentAccounts:[UserAccount] = []

class UserAccount: NSObject {

    //Notifications
    static let userAccountSwitched = "userAccountSwitched"
    static let userAccountRemoved = "useAccountRemoved"
    static let userAccountAdded = "useAccountAdded"

    var user:User?
    var requestToken:BDBOAuth1Credential
    var lastLoggedIn:String?
    static var current:UserAccount?
    
    init(user:User ,token:BDBOAuth1Credential) {
        self.user = user
        self.requestToken = token
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        let result = formatter.string(from: date)
        self.lastLoggedIn = result
    }


    public static func ==(l: UserAccount, r: UserAccount) -> Bool{
        return
            l.user!.name == r.user!.name
    }


}
