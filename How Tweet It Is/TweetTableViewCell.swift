//
//  TweetTableViewCell.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/17/15.
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


@objc protocol TweetTableViewCellDelegate {
    func replyToTweet(tweet: Tweet!)
}

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var retweetImage: UIImageView!
    
    var indexPathRow: Int = -1
    var sb = UIStoryboard(name: "Main", bundle: nil)
    var delegate: TweetTableViewCellDelegate!
    var tweet: Tweet! {
        
        
        willSet(newTweet) {
            
            self.nameLabel.text = newTweet.user!.name
            self.handleLabel.text = "@\(newTweet.user!.screenName!)"
            self.tweetLabel.text = newTweet.text
            
            if (newTweet.favoriteCount > 0) {
                self.favoriteCountLabel.isHidden = false
                self.favoriteCountLabel.text = "\(newTweet.favoriteCount!)"
            } else {
                self.favoriteCountLabel.isHidden = true
            }
            
            if (newTweet.retweetCount > 0) {
                self.retweetCountLabel.isHidden = false
                self.retweetCountLabel.text = "\(newTweet.retweetCount!)"
            } else {
                self.retweetCountLabel.isHidden = true
            }
            
            if let retweetedBy = newTweet.retweetedBy {
                self.retweetLabel.text = "\(retweetedBy.name!) retweeted"
                self.retweetLabel.isHidden = false
                self.retweetImage.isHidden = false
            } else {
                self.retweetLabel.isHidden = true
                self.retweetImage.isHidden = true
            }
            
            self.profileImage.setImageWith(URL(string: (newTweet.user!.profileImageUrl! as NSString) as String))
            
            profileImage.layer.cornerRadius = 5;
            profileImage.clipsToBounds = true;
            timeLabel.text = newTweet.userReadableCreatedTime
            
            if (newTweet.retweeted == 1) {
                self.retweetButton.isEnabled = false
                let image = UIImage(named: "retweet-on.png") as UIImage?
                self.retweetButton.setImage(image, for: UIControlState.disabled)
            } else {
                self.retweetButton.isEnabled = true
                let image = UIImage(named: "retweet-light.png") as UIImage?
                self.retweetButton.setImage(image, for: UIControlState())
            }
            
            if (newTweet.favorited == 1) {
                self.favoriteButton.isEnabled = false
                let image = UIImage(named: "favorite-on.png") as UIImage?
                self.favoriteButton.setImage(image, for: UIControlState())
            } else {
                self.favoriteButton.isEnabled = true
                let image = UIImage(named: "favorite-light.png") as UIImage?
                self.favoriteButton.setImage(image, for: UIControlState())
            }
            
            // These tags will help when the user clicks to figure out what row this belongs to.
            self.replyButton.tag = self.indexPathRow
            self.retweetButton.tag = self.indexPathRow
            self.favoriteButton.tag = self.indexPathRow
        }
        
        didSet(oldValue) {
            
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true

        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
