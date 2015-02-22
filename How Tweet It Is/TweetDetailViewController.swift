//
//  TweetDetailViewController.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/20/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

@objc protocol TweetDetailViewControllerDelegate {
    func backButtonClicked(tweet:Tweet, indexPathRow: Int)
}

class TweetDetailViewController: UIViewController {
    
    var delegate: TweetDetailViewControllerDelegate?
    
    var tweet: Tweet?
    var indexPathRow = -1
    var sb = UIStoryboard(name: "Main", bundle: nil)
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var retweetImage: UIImageView!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    @IBAction func onReply(sender: AnyObject) {
        var vc: ComposeTweetViewController = sb.instantiateViewControllerWithIdentifier("ComposeTweetViewController") as ComposeTweetViewController
        vc.replyToTweet = tweet
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        self.tweet!.retweeted = 1
        self.tweet!.retweetCount! += 1
        self.retweetButton.enabled = false
        self.viewDidLoad()
        
        Tweet.retweet(self.tweet!.id!, completion: {(error: NSError?) -> Void in
            if (error != nil) {
                println("error while retweeting! \(error)")
                self.tweet!.retweeted = 0
                self.tweet!.retweetCount! -= 1
                self.retweetButton.enabled = true
                self.viewDidLoad()
            } else {
                println("retweeted!!!!!  while retweeting!")
            }
        })

    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        if (self.tweet!.favorited == 0) {
            self.tweet!.favorited = 1
            self.tweet!.favoriteCount! += 1
            self.viewDidLoad()
            Tweet.favorite(self.tweet!.id!, completion: {(error: NSError?) -> Void in
                if (error != nil) {
                    println("error while favoriting! \(error)")
                    self.tweet!.favorited = 0
                    self.tweet!.favoriteCount! -= 1
                    self.viewDidLoad()
                } else {
                    println("Favorited!!!!!!")
                }
            })
        } else {
            self.tweet!.favorited = 0
            self.tweet!.favoriteCount! -= 1
            self.viewDidLoad()
            
            Tweet.unfavorite(self.tweet!.id!, completion: {(error: NSError?) -> Void in
                if (error != nil) {
                    println("error while unfavoriting! \(error)")
                    self.tweet!.favorited = 0
                    self.tweet!.favoriteCount! -= 1
                    self.viewDidLoad()
                } else {
                    println("unFavorited!!!!!!")
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImage.setImageWithURL(NSURL(string: tweet!.user!.profileImageUrl!))
        nameLabel.text = tweet!.user?.name!
        handleLabel.text = "@\(tweet!.user!.screenName!)"
        tweetLabel.text = tweet!.text!
        
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd/yy, hh:mm a"
        createdAtLabel.text = dateFormat.stringFromDate(tweet!.createdAt!)
        
        if (tweet!.favoriteCount > 0) {
            self.favoriteCount.hidden = false
            self.favoriteCount.text = "\(tweet!.favoriteCount!)"
        } else {
            self.favoriteCount.hidden = true
        }
        if (tweet!.retweetCount > 0) {
            self.retweetCount.hidden = false
            self.retweetCount.text = "\(tweet!.retweetCount!)"
        } else {
            self.retweetCount.hidden = true
        }
        
        if let retweetedBy = tweet?.retweetedBy {
            self.retweetLabel.text = "\(retweetedBy.name!) retweeted"
            self.retweetLabel.hidden = false
            self.retweetImage.hidden = false
            
            //handleLabelTopConstraint.constant = 25.0
            //profileThumbViewTopConstraint.constant = 25.0
            //profileThumbButtonTopConstraint.constant = 25.0
            //timeLabelTopConstraint.constant = 25.0
            //nameLabelTopConstraint.constant = 24.0
            
        } else {
            // Fix this to change the height to 0 by changing the constraint
            self.retweetLabel.hidden = true
            self.retweetImage.hidden = true
            //handleLabelTopConstraint.constant = 9.0
            //profileThumbViewTopConstraint.constant = 9.0
            //profileThumbButtonTopConstraint.constant = 9.0
            //timeLabelTopConstraint.constant = 9.0
            //nameLabelTopConstraint.constant = 8.0
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissViewController", name:"NewTweetCreated", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissViewController() {
        self.navigationController?.popViewControllerAnimated(true)
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
