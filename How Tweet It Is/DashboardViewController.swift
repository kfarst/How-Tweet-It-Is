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
    
    @IBAction func composeTweet(_ sender: AnyObject) {
        let vc = sb.instantiateViewController(withIdentifier: "ComposeTweetViewController") as! ComposeTweetViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func logoutUser(_ sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    @IBAction func replyToTweet(_ sender: AnyObject) {
        let indexPathRow = sender.tag
        let vc = sb.instantiateViewController(withIdentifier: "ComposeTweetViewController") as! ComposeTweetViewController
        
        vc.replyToTweet = self.tweets[indexPathRow!];
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func retweetTweet(_ sender: AnyObject) {
        let indexPathRow = sender.tag
        let tweet = tweets[indexPathRow!]
        
        // TODO make it more realtime and show error if it fails.
        tweet.retweeted = 1
        tweet.retweetCount! += 1
        
        let cell = self.tweetTableView.cellForRow(at: IndexPath(row: indexPathRow!, section: 0)) as! TweetTableViewCell
        
        cell.tweet = tweet
        
        Tweet.retweet(tweet.id!, completion: {(error: Error?) -> Void in
            if (error != nil) {
                print("Retweeting error: \(String(describing: error))")
                tweet.retweeted = 0
                tweet.retweetCount! -= 1
                let cell = self.tweetTableView.cellForRow(at: IndexPath(row: indexPathRow!, section: 0)) as! TweetTableViewCell
                cell.tweet = tweet
                
            } else {
                self.tweets[indexPathRow!] = tweet
            }
        })
    }
    
    @IBAction func favoriteTweet(_ sender: AnyObject) {
        let indexPathRow = sender.tag
        let tweet = tweets[indexPathRow!]

        if (tweet.favorited == 1) {
            tweet.favorited = 0
            tweet.favoriteCount! -= 1
            
            let cell = self.tweetTableView.cellForRow(at: IndexPath(row: indexPathRow!, section: 0)) as! TweetTableViewCell
            
            cell.tweet = tweet
            
            Tweet.unfavorite(tweet.id!, completion: {(error: Error?) -> Void in
                if (error != nil) {
                    tweet.favorited = 1
                    tweet.favoriteCount! += 1
                    cell.tweet = tweet
                } else {
                    self.tweets[indexPathRow!] = tweet
                }
            })
        } else {
            tweet.favorited = 1
            tweet.favoriteCount! += 1
            
            let cell = self.tweetTableView.cellForRow(at: IndexPath(row: indexPathRow!, section: 0)) as! TweetTableViewCell
            
            cell.tweet = tweet
            
            Tweet.favorite(tweet.id!, completion: {(error: Error?) -> Void in
                if (error != nil) {
                    tweet.favorited = 0
                    tweet.favoriteCount! -= 1
                    cell.tweet = tweet
                } else {
                    self.tweets[indexPathRow!] = tweet
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

        Tweet.getHomeTimeline(nil, completion: {(tweets: [Tweet]?, error: Error?) -> Void in
            if (tweets != nil) {
                self.tweets = tweets!
                self.tweetTableView.reloadData()
                SVProgressHUD.dismiss()
            } else {
                print("Tweets fetching error: \(error!)")
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.newTweetCreated(_:)), name: NSNotification.Name(rawValue: "NewTweetCreated"), object: nil)

        initializeRefreshControl()
        tweetTableView.reloadData()
    }
    
    func replyToTweet(tweet: Tweet!) {
        let vc = sb.instantiateViewController(withIdentifier: "ComposeTweetViewController") as! ComposeTweetViewController
        
        vc.replyToTweet = tweet
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func newTweetCreated(_ notification: Notification){
        let tweet = notification.object as! Tweet
        
        self.tweets.insert(tweet, at: 0)
        self.tweetTableView.reloadData()
        self.tweetTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell") as! TweetTableViewCell
        
        cell.indexPathRow = indexPath.row
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        
        if (tweets.count - indexPath.row == 1) {
            DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.low).async(execute: {
                self.loadMoreTweets()
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func loadMoreTweets() {
        
        let params: NSDictionary = ["max_id": self.tweets[tweets.count-1].id!]
        
        Tweet.getHomeTimeline(params, completion: {(newTweets: [Tweet]?, error: Error?) -> Void in
            if (newTweets != nil) {
                self.tweets += newTweets!
                self.tweetTableView.reloadData()
            } else {
                print("Tweets fetching error: \(error!)")
            }
        })
        
        self.refreshControl.endRefreshing()
    }
    
    func backButtonClicked(_ tweet: Tweet, indexPathRow: Int) {
        self.tweets[indexPathRow] = tweet
        let cell = self.tweetTableView.cellForRow(at: IndexPath(row: indexPathRow, section: 0)) as! TweetTableViewCell
        cell.tweet = tweet
    }
    
    func initializeRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: #selector(DashboardViewController.loadMoreTweets), for: UIControlEvents.valueChanged)
        self.tweetTableView.addSubview(refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources thkat can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TweetDetailSegue" {
            let vc: TweetDetailViewController = segue.destination as! TweetDetailViewController
            let index = tweetTableView.indexPathForSelectedRow!.row
            self.tweetTableView.deselectRow(at: tweetTableView.indexPathForSelectedRow!, animated: false)
            let selectedTweet = self.tweets[index]
            vc.tweet = selectedTweet
            vc.indexPathRow = index
            vc.delegate = self
        }
    }
}
