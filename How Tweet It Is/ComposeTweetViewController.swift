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

class ComposeTweetViewController: UIViewController {
    
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
                println("error while Tweeting! \(error)")
            } else {
                println("Tweeted!!!!!! \(tweet)")
                NSNotificationCenter.defaultCenter().postNotificationName("NewTweetCreated", object: tweet)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    var user = User.currentUser
    var delegate: ComposeTweetDelegate!
    var replyToTweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tweetButton.backgroundColor = UIColor(hexString: "#55acee")
        tweetButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        tweetButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        tweetButton.layer.cornerRadius = 4.0
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
        }
        
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
            characterCountLabel.textColor = UIColor.redColor()
        } else {
            tweetButton.enabled = true
            characterCountLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        placeholderLabel.hidden = true
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
