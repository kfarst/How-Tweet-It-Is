//
//  User.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/16/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileImageUrl: String?
    var backgroundImageUrl: String?
    var tagLine: String?
    var dictionary: NSDictionary
    var location: String?
    var numberOfFollowers: Int?
    var numberFollowing: Int?
    var numberOfTweets: Int?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        backgroundImageUrl = dictionary["profile_background_image_url"] as? String
        tagLine = dictionary["description"] as? String
        location = dictionary["location"] as? String
        numberOfFollowers = dictionary["followers_count"] as? Int
        numberFollowing = dictionary["friends_count"] as? Int
        numberOfTweets = dictionary["statuses_count"] as? Int
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NotificationCenter.default.post(name: Notification.Name(rawValue: userDidLogoutNotification), object: nil)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                do {
                let data = UserDefaults.standard.object(forKey: currentUserKey) as? Data
                if data != nil {
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
                } catch let error {
                    print("\(error.localizedDescription)")
                }
                
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            if _currentUser != nil {
                do {
                    let data = try JSONSerialization.data(withJSONObject: user!.dictionary, options: .prettyPrinted)
                    UserDefaults.standard.set(data, forKey: currentUserKey)
                } catch let error {
                    print("\(error.localizedDescription)")
                }
            } else {
                UserDefaults.standard.set(nil, forKey: currentUserKey)
            }
            UserDefaults.standard.synchronize()
            
        }
    }
}
