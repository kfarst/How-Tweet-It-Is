//  TwitterClient.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/16/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

let twitterConsumerKey = "Bdp9XFimZeHkguhWzH7y4dH4K"
let twitterConsumerSecret = "wrwvsKwVi4m5ULjzNqafaiLBXnu28798Hq5AJ7GjawIBz09qKI"
let twitterBaseUrl = URL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((_ user: User?, _ error: Error?) -> ())?
    // Has to be a computed properties
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseUrl, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance!
    }
    
    
    func loginWithCompletion(_ completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
        loginCompletion = completion
        
        // Fetch request token and redirect to auth page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("Got the request token")
            let query = URLQueryItem(name: "oauth_token", value: requestToken.token)
            
            var authUrl = URLComponents()
            authUrl.scheme = "https"
            authUrl.path = "api.twitter.com/oauth/authorize"
            authUrl.queryItems = [query]
            
            UIApplication.shared.openURL(authUrl.url!)
            
            }) { (error: Error?) -> Void in
                print("Failed to get the token")
                self.loginCompletion?(nil, error)
        }
    }
    
    func homeTimelineWithParams(_ params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: NSError?) -> ()) {
        TwitterClient.sharedInstance.get("1.1/statuses/home_timeline.json", parameters: params,
            success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets, nil)
                
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(nil, error)
            } as! (AFHTTPRequestOperation?, Error?) -> Void
        )
    }
    
    func openUrl(_ url: URL) {
        TwitterClient.sharedInstance.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query),
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
                
                TwitterClient.sharedInstance.get("1.1/account/verify_credentials.json", parameters: nil,
                    success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
                        print("user: \(String(describing: response))")
                        let user = User(dictionary: response as! NSDictionary)
                        User.currentUser = user
                        print("user \(String(describing: user.name))")
                        self.loginCompletion?(user, nil)
                    }, failure: { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
                        print("failed to get the User data")
                        self.loginCompletion?(nil, error)
                })
            },
            failure: { (error: Error?) -> Void in
                print("failed ot get the access token")
                self.loginCompletion?(nil, error)
        })
    }
}
