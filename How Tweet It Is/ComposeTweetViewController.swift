//
//  ComposeTweetViewController.swift
//  
//
//  Created by Kevin Farst on 2/18/15.
//
//

import UIKit

@objc protocol ComposeTweetDelegate {
    func tweetComposed(tweet: Tweet)
}

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetText: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBAction func cancelComposition(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func newTweetPosted(sender: AnyObject) {
        var text = tweetText.text
        var inReplyToTweetId: String? = nil
        
        if let inReplyToTweet = replyToTweet {
            inReplyToTweetId = inReplyToTweet.id
        }
        
        Tweet.newTweet(text, inReplyToTweetId: inReplyToTweetId) { (tweet, error) -> () in
            if (error != nil) {
                println("Tweeting error: \(error)")
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("NewTweetCreated", object: tweet)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    var user = User.currentUser
    var delegate: ComposeTweetDelegate!
    var replyToTweet: Tweet?
    let twitterBlue = UIColor(hexString: "#55acee")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tweetButton.backgroundColor = twitterBlue
        tweetButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        tweetButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        tweetButton.layer.cornerRadius = 4
        tweetButton.layer.masksToBounds = true
        tweetButton.clipsToBounds = false
        
        if let imageUrl = user?.profileImageUrl {
            profileImage.setImageWithURL(NSURL(string: imageUrl))
        }
        
        nameLabel.text = user?.name
        handleLabel.text = user?.screenName

        if replyToTweet == nil {
            placeholderLabel.hidden = false
        } else {
            if let handle = replyToTweet?.user?.screenName {
                placeholderLabel.hidden = true
                tweetText.text = "@\(handle)"
            }
            
            var text = tweetText.text!
            var count = countElements(text)
            
            characterCountLabel.text = "\(140 - count)"
        }
        
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true

        tweetText.delegate = self
        tweetText.becomeFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = true
        
        var text = tweetText.text!
        var count = countElements(text)
        
        characterCountLabel.text = "\(140 - count)"
        
        if (count == 0) {
            tweetButton.enabled = false
        } else {
            tweetButton.enabled = true
        }
        
        if (count > 140) {
            tweetButton.enabled = false
            tweetButton.backgroundColor = UIColor.grayColor()
            characterCountLabel.textColor = UIColor.redColor()
        } else {
            tweetButton.enabled = true
            tweetButton.backgroundColor = twitterBlue
            characterCountLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if tweetText.text.isEmpty {
            placeholderLabel.hidden = false
        }
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
