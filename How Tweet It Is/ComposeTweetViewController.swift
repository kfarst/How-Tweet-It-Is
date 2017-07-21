//
//  ComposeTweetViewController.swift
//  
//
//  Created by Kevin Farst on 2/18/15.
//
//

import UIKit

@objc protocol ComposeTweetDelegate {
    func tweetComposed(_ tweet: Tweet)
}

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetText: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBAction func cancelComposition(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newTweetPosted(_ sender: AnyObject) {
        let text = tweetText.text
        var inReplyToTweetId: String? = nil
        
        if let inReplyToTweet = replyToTweet {
            inReplyToTweetId = inReplyToTweet.id
        }
        
        Tweet.newTweet(text!, inReplyToTweetId: inReplyToTweetId) { (tweet, error) -> () in
            if (error != nil) {
                print("Tweeting error: \(String(describing: error))")
            } else {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "NewTweetCreated"), object: tweet)
                
                self.dismiss(animated: true, completion: nil)
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
        tweetButton.setTitleColor(UIColor.white, for: UIControlState())
        tweetButton.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
        tweetButton.layer.cornerRadius = 4
        tweetButton.layer.masksToBounds = true
        tweetButton.clipsToBounds = false
        
        if let imageUrl = user?.profileImageUrl {
            profileImage.setImageWith(URL(string: imageUrl))
        }
        
        nameLabel.text = user?.name
        handleLabel.text = user?.screenName

        if replyToTweet == nil {
            placeholderLabel.isHidden = false
        } else {
            if let handle = replyToTweet?.user?.screenName {
                placeholderLabel.isHidden = true
                tweetText.text = "@\(handle)"
            }
            
            var text = tweetText.text!
            let count = text.characters.count
            
            characterCountLabel.text = "\(140 - count)"
        }
        
        profileImage.layer.cornerRadius = 4
        profileImage.clipsToBounds = true

        tweetText.delegate = self
        tweetText.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = true
        
        var text = tweetText.text!
        let count = text.characters.count
        
        characterCountLabel.text = "\(140 - count)"
        
        if (count == 0) {
            tweetButton.isEnabled = false
        } else {
            tweetButton.isEnabled = true
        }
        
        if (count > 140) {
            tweetButton.isEnabled = false
            tweetButton.backgroundColor = UIColor.gray
            characterCountLabel.textColor = UIColor.red
        } else {
            tweetButton.isEnabled = true
            tweetButton.backgroundColor = twitterBlue
            characterCountLabel.textColor = UIColor.lightGray
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if tweetText.text.isEmpty {
            placeholderLabel.isHidden = false
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
