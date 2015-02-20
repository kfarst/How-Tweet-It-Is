//
//  DashboardViewController.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/16/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tweetTableView: UITableView!
    
    var tweets: [Tweet] = []
    var refreshControl: UIRefreshControl!
    var sb = UIStoryboard(name: "Main", bundle: nil)
    
    @IBAction func composeTweet(sender: AnyObject) {
        var vc = sb.instantiateViewControllerWithIdentifier("ComposeTweetViewController") as ComposeTweetViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func profileImageTapped(sender: AnyObject) {
    }
    
    
    
    
    @IBAction func logoutUser(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        tweetTableView.estimatedRowHeight = 90.0
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        
        Tweet.getHomeTimeline(nil, completion: {(tweets: [Tweet]?, error: NSError?) -> Void in
            if (tweets != nil) {
                self.tweets = tweets!
                self.tweetTableView.reloadData()
            } else {
                println("Failed to get the tweets \(error!)")
            }
        })
        
        initializeRefreshControl()
        tweetTableView.reloadData()
        // Do any additional setup after loading the view.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TweetTableViewCell") as TweetTableViewCell
        //cell.parentViewController = self
        cell.indexPathRow = indexPath.row
        cell.tweet = tweets[indexPath.row]
        
        if (tweets.count - indexPath.row == 1/*&& !self.isInfiniteRefreshing*/) {
            //infiniteActivityIndicator.hidden = false
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
       // self.isInfiniteRefreshing = true
        //println("\(params)")
        //if (self.viewMode == "home") {
            Tweet.getHomeTimeline(params, completion: {(newTweets: [Tweet]?, error: NSError?) -> Void in
                if (newTweets != nil) {
                    self.tweets += newTweets!
                    self.tweetTableView.reloadData()
                    //self.infiniteActivityIndicator.hidden = true
                    //self.isInfiniteRefreshing = false
                } else {
                    println("Failed to get the tweets \(error!)")
                }
            })
       //} else if self.viewMode == "mentions" {
       //    Tweet.getMentionsTimeline(params, completion: {(newTweets: [Tweet]?, error: NSError?) -> Void in
       //        if (newTweets != nil) {
       //            self.tweets += newTweets!
       //            self.tweetsTableView.reloadData()
       //            self.infiniteActivityIndicator.hidden = true
       //            self.isInfiniteRefreshing = false
       //        } else {
       //            println("Failed to get the mentions \(error!)")
       //        }
       //    })
       //}
        self.refreshControl.endRefreshing()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
