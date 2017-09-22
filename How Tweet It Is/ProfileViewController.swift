//
//  ProfileViewController.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/26/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var tweetTableView: UITableView!
    
    var user: User?
    var tweets: [Tweet] = []
    var refreshControl: UIRefreshControl!
    
    @IBAction func homeButtonTapped(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        tweetTableView.estimatedRowHeight = 95.0
        tweetTableView.rowHeight = UITableViewAutomaticDimension
        
        SVProgressHUD.show()
        
        if self.user == nil {
            self.user = User.currentUser
        }
        
        Tweet.getUserTimeline(user!.screenName!, completion: {(tweets: [Tweet]?, error: Error?) -> Void in
            if (tweets != nil) {
                self.tweets = tweets!
                self.tweetTableView.reloadData()
                SVProgressHUD.dismiss()
            } else {
                print("Tweets fetching error: \(error!)")
            }
        })
        
        nameLabel.text =  user!.name!
        handleLabel.text = "@\(user!.screenName!)"
        
        if let url = user!.profileImageUrl {
            profileImage.setImageWith(URL(string: url))
            profileImage.layer.cornerRadius = 4
            profileImage.layer.masksToBounds = true
            profileImage.clipsToBounds = true
        }
        
        if let url = user!.backgroundImageUrl {
            backgroundImage.setImageWith(URL(string: url))
        } else {
            backgroundImage.image = UIImage(named: "background-image")
        }
        
        followersLabel.text = "\(user!.numberOfFollowers!)"
        followersLabel.text = "\(user!.numberFollowing!)"
        tweetCountLabel.text = "\(user!.numberOfTweets!)"
        
        initializeRefreshControl()
        tweetTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as!
        TweetTableViewCell
        
        cell.indexPathRow = indexPath.row
        cell.tweet = tweets[indexPath.row]
        
        if (tweets.count - indexPath.row == 1) {
            DispatchQueue.global().async(execute: {
                self.loadMoreTweets()
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func initializeRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: #selector(loadMoreTweets), for: UIControlEvents.valueChanged)
        self.tweetTableView.addSubview(refreshControl)
    }
    
    func loadMoreTweets() {
        
        var params: NSDictionary = ["max_id": self.tweets[tweets.count-1].id!]
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
