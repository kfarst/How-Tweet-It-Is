//
//  Tweet.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/16/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    // Add all the class variables.
    
    var user: User?
    var retweetedBy: User?
    var text: String?
    var createdAtString: String?
    var createdAt: Date?
    var favoriteCount: Int?
    var retweetCount: Int?
    var userReadableCreatedTime: String?
    var id: String?
    var retweeted: Int?
    var favorited: Int?
    var entities: NSDictionary?
    
    class func formatCreatedTimeToUserReadableTime(_ createdAt: Date) -> String {
        
        let timeSinceCreation = createdAt.timeIntervalSinceNow
        let timeSinceCreationInt =  Int(timeSinceCreation) * -1
        let timeSinceCreationMins = timeSinceCreationInt/60 as Int
        
        if (timeSinceCreationMins == 0) {
            return "now"
        } else if (timeSinceCreationMins >= 1 && timeSinceCreationMins < 60) {
            return "\(timeSinceCreationMins)m"
        } else if (timeSinceCreationMins < 1440) {
            return "\(timeSinceCreationMins/60)h"
        } else if (timeSinceCreationMins >= 1440) {
            return "\(timeSinceCreationMins/1440)d"
        }
        return "now"
    }
    
    init(dictionary: NSDictionary) {
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        favoriteCount = dictionary["favorite_count"] as? Int
        retweetCount = dictionary["retweet_count"] as? Int
        id = dictionary["id_str"] as? String
        retweeted = dictionary["retweeted"] as? Int
        favorited = dictionary["favorited"] as? Int
        entities = dictionary["entities"] as? NSDictionary
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "EEE MM d HH:mm:ss Z y"
        
        createdAt = formatter.date(from: createdAtString!)
        userReadableCreatedTime = Tweet.formatCreatedTimeToUserReadableTime(createdAt!)
    }
    
    class func tweetsWithArray(_ array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            if (dictionary["retweeted_status"] != nil) {
                let tweet = Tweet(dictionary: dictionary["retweeted_status"] as! NSDictionary)
                tweet.retweetedBy = User(dictionary: dictionary["user"] as! NSDictionary)
                tweets.append(tweet)
            } else {
                tweets.append(Tweet(dictionary: dictionary))
            }
            
        }
        return tweets
    }
    
    class func getHomeTimeline(_ params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> ()) {
        TwitterClient.sharedInstance.get("1.1/statuses/home_timeline.json", parameters: params,
            success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets, nil)
                
            }, failure: { (operation: AFHTTPRequestOperation?, error: Error?) -> Void in
                completion(nil, error)
            }
        )
    }
    
    class func getMentionsTimeline(_ params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> ()) {
        TwitterClient.sharedInstance.get("1.1/statuses/mentions_timeline.json", parameters: params,
            success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets, nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: Error!) -> Void in
                completion(nil, error)
            }
        )
    }
    
    class func getUserTimeline(_ screenName: String, completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> ()) {
        TwitterClient.sharedInstance.get("1.1/statuses/user_timeline.json?screen_name=\(screenName)", parameters: nil,
            success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets, nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: Error!) -> Void in
                completion(nil, error)
            }
        )
    }
    
    class func retweet(_ id: String, completion: @escaping (_ error: Error?) -> ()) {
        TwitterClient.sharedInstance.post("1.1/statuses/retweet/\(id).json", parameters: nil,
            success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
                completion(nil)
                
            } as! (AFHTTPRequestOperation?, Any?) -> Void, failure: { (operation: AFHTTPRequestOperation!, error: Error!) -> Void in
                completion(error)
            }
        )
    }
    
    class func favorite(_ id: String, completion: @escaping (_ error: Error?) -> ()) {
        TwitterClient.sharedInstance.post("1.1/favorites/create.json?id=\(id)", parameters: nil,
            success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
                completion(nil)
                
            }, failure: { (operation: AFHTTPRequestOperation!, error: Error!) -> Void in
                completion(error)
            }
        )
    }
    
    class func unfavorite(_ id: String, completion: @escaping (_ error: Error?) -> ()) {
        TwitterClient.sharedInstance.post("1.1/favorites/destroy.json?id=\(id)", parameters: nil,
            success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
                completion(nil)
                
            }, failure: { (operation: AFHTTPRequestOperation!, error: Error!) -> Void in
                completion(error)
            }
        )
    }
    
    
    class func newTweet(_ text: String, inReplyToTweetId: String?, completion: @escaping (_ tweet: Tweet?, _ error: Error?) -> ()) {
        
        let params = ["status":text] as NSMutableDictionary
        if let replyToTweetId = inReplyToTweetId {
            params["in_reply_to_status_id"] = replyToTweetId
        }
        print(params)
        TwitterClient.sharedInstance.post("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation?, response: Any?) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet, nil)
        }) { (operation: AFHTTPRequestOperation?, error: Error?) in
            print("\(String(describing: error?.localizedDescription))")
        }
    }
}
    
    

