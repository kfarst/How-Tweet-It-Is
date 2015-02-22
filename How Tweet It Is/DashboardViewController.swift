//
//  DashboardViewController.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/16/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetDetailViewControllerDelegate, TweetTableViewCellDelegate {
    
    @IBOutlet weak var tweetTableView: UITableView!
    
    var tweets: [Tweet] = []
    var refreshControl: UIRefreshControl!
    var sb = UIStoryboard(name: "Main", bundle: nil)
    var selectedTableRow = -1
    
    @IBAction func composeTweet(sender: AnyObject) {
        var vc = sb.instantiateViewControllerWithIdentifier("ComposeTweetViewController") as ComposeTweetViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func logoutUser(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    @IBAction func replyToTweet(sender: AnyObject) {
        var indexPathRow = sender.tag
        var vc = sb.instantiateViewControllerWithIdentifier("ComposeTweetViewController") as ComposeTweetViewController
        
        vc.replyToTweet = self.tweets[indexPathRow];
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func retweetTweet(sender: AnyObject) {
        var indexPathRow = sender.tag
        var tweet = tweets[indexPathRow]
        
        // TODO make it more realtime and show error if it fails.
        tweet.retweeted = 1
        tweet.retweetCount! += 1
        
        var cell = self.tweetTableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPathRow, inSection: 0)) as TweetTableViewCell
        
        cell.tweet = tweet
        
        Tweet.retweet(tweet.id!, completion: {(error: NSError?) -> Void in
            if (error != nil) {
                println("Retweeting error: \(error)")
                tweet.retweeted = 0
                tweet.retweetCount! -= 1
                var cell = self.tweetTableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPathRow, inSection: 0)) as TweetTableViewCell
                cell.tweet = tweet
                
            } else {
                self.tweets[indexPathRow] = tweet
            }
        })
    }
    
    @IBAction func favoriteTweet(sender: AnyObject) {
        var indexPathRow = sender.tag
        var tweet = tweets[indexPathRow]

        if (tweet.favorited == 1) {
            tweet.favorited = 0
            tweet.favoriteCount! -= 1
            
            var cell = self.tweetTableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPathRow, inSection: 0)) as TweetTableViewCell
            
            cell.tweet = tweet
            
            Tweet.unfavorite(tweet.id!, completion: {(error: NSError?) -> Void in
                if (error != nil) {
                    tweet.favorited = 1
                    tweet.favoriteCount! += 1
                    cell.tweet = tweet
                } else {
                    self.tweets[indexPathRow] = tweet
                }
            })
        } else {
            tweet.favorited = 1
            tweet.favoriteCount! += 1
            
            var cell = self.tweetTableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPathRow, inSection: 0)) as TweetTableViewCell
            
            cell.tweet = tweet
            
            Tweet.favorite(tweet.id!, completion: {(error: NSError?) -> Void in
                if (error != nil) {
                    tweet.favorited = 0
                    tweet.favoriteCount! -= 1
                    cell.tweet = tweet
                } else {
                    self.tweets[indexPathRow] = tweet
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        tweetTableView.estimatedRowHeight = 95.0
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        
        SVProgressHUD.show()

        Tweet.getHomeTimeline(nil, completion: {(tweets: [Tweet]?, error: NSError?) -> Void in
            if (tweets != nil) {
                self.tweets = tweets!
                self.tweetTableView.reloadData()
                SVProgressHUD.dismiss()
            } else {
                println("Tweets fetching error: \(error!)")
            }
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTweetCreated:", name: "NewTweetCreated", object: nil)

        initializeRefreshControl()
        tweetTableView.reloadData()
    }
    
    func replyToTweet(tweet: Tweet!) {
        var vc = sb.instantiateViewControllerWithIdentifier("ComposeTweetViewController") as ComposeTweetViewController
        
        vc.replyToTweet = tweet
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func newTweetCreated(notification: NSNotification){
        var tweet = notification.object as Tweet
        
        self.tweets.insert(tweet, atIndex: 0)
        self.tweetTableView.reloadData()
        self.tweetTableView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TweetTableViewCell") as TweetTableViewCell
        
        cell.indexPathRow = indexPath.row
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        
        if (tweets.count - indexPath.row == 1) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                self.loadMoreTweets()
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func loadMoreTweets() {
        
        var params: NSDictionary = ["max_id": self.tweets[tweets.count-1].id!]
        
        Tweet.getHomeTimeline(params, completion: {(newTweets: [Tweet]?, error: NSError?) -> Void in
            if (newTweets != nil) {
                self.tweets += newTweets!
                self.tweetTableView.reloadData()
            } else {
                println("Tweets fetching error: \(error!)")
            }
        })
        
        self.refreshControl.endRefreshing()
    }
    
    func backButtonClicked(tweet: Tweet, indexPathRow: Int) {
        self.tweets[indexPathRow] = tweet
        var cell = self.tweetTableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPathRow, inSection: 0)) as TweetTableViewCell
        cell.tweet = tweet
    }
    
    func initializeRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "loadMoreTweets", forControlEvents: UIControlEvents.ValueChanged)
        self.tweetTableView.addSubview(refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources thkat can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TweetDetailSegue" {
            var vc: TweetDetailViewController = segue.destinationViewController as TweetDetailViewController
            var index = tweetTableView.indexPathForSelectedRow()!.row
            self.tweetTableView.deselectRowAtIndexPath(tweetTableView.indexPathForSelectedRow()!, animated: false)
            var selectedTweet = self.tweets[index]
            vc.tweet = selectedTweet
            vc.indexPathRow = index
            vc.delegate = self
        }
    }
}
