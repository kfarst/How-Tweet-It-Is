//
//  TweetDetailViewController.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/20/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc protocol TweetDetailViewControllerDelegate {
    func backButtonClicked(_ tweet:Tweet, indexPathRow: Int)
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
    
    @IBAction func onReply(_ sender: AnyObject) {
        let vc: ComposeTweetViewController = sb.instantiateViewController(withIdentifier: "ComposeTweetViewController") as! ComposeTweetViewController
        vc.replyToTweet = tweet
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func onRetweet(_ sender: AnyObject) {
        self.tweet!.retweeted = 1
        self.tweet!.retweetCount! += 1
        self.retweetButton.isEnabled = false
        self.viewDidLoad()
        
        Tweet.retweet(self.tweet!.id!, completion: {(error: Error?) -> Void in
            if (error != nil) {
                self.tweet!.retweeted = 0
                self.tweet!.retweetCount! -= 1
                self.retweetButton.isEnabled = true
                self.viewDidLoad()
            }
        })

    }
    
    @IBAction func onFavorite(_ sender: AnyObject) {
        if (self.tweet!.favorited == 0) {
            self.tweet!.favorited = 1
            self.tweet!.favoriteCount! += 1
            self.viewDidLoad()
            Tweet.favorite(self.tweet!.id!, completion: {(error: Error?) -> Void in
                if (error != nil) {
                    self.tweet!.favorited = 0
                    self.tweet!.favoriteCount! -= 1
                    self.viewDidLoad()
                }
            })
        } else {
            self.tweet!.favorited = 0
            self.tweet!.favoriteCount! -= 1
            self.viewDidLoad()
            
            Tweet.unfavorite(self.tweet!.id!, completion: {(error: Error?) -> Void in
                if (error != nil) {
                    self.tweet!.favorited = 0
                    self.tweet!.favoriteCount! -= 1
                    self.viewDidLoad()
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.setImageWith(URL(string: tweet!.user!.profileImageUrl!))
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true
        
        nameLabel.text = tweet!.user?.name!
        handleLabel.text = "@\(tweet!.user!.screenName!)"
        tweetLabel.text = tweet!.text!
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yy, hh:mm a"
        createdAtLabel.text = dateFormat.string(from: tweet!.createdAt! as Date)
        
        if (tweet!.favoriteCount > 0) {
            self.favoriteCount.isHidden = false
            self.favoriteCount.text = "\(tweet!.favoriteCount!)"
        } else {
            self.favoriteCount.text = "0"
        }
        if (tweet!.retweetCount > 0) {
            self.retweetCount.isHidden = false
            self.retweetCount.text = "\(tweet!.retweetCount!)"
        } else {
            self.favoriteCount.text = "0"
        }
        
        if let retweetedBy = tweet?.retweetedBy {
            self.retweetLabel.text = "\(retweetedBy.name!) retweeted"
            self.retweetLabel.isHidden = false
            self.retweetImage.isHidden = false
            
        } else {
            self.retweetLabel.isHidden = true
            self.retweetImage.isHidden = true
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(TweetDetailViewController.dismissViewController), name:NSNotification.Name(rawValue: "NewTweetCreated"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func dismissViewController() {
        self.navigationController?.popViewController(animated: true)
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
