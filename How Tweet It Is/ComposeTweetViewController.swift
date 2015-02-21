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
                
                self.dismissViewControllerAnimated(true, completion: {
                    
                })
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
            tweetText.text = "What do you want to say?"
        } else {
            if let handle = replyToTweet?.user?.screenName {
                tweetText.text = "@\(handle)"
            }
        }
        
        tweetText.textColor = UIColor.lightGrayColor()
        
        tweetText.becomeFirstResponder()
        
        tweetText.selectedTextRange = tweetText.textRangeFromPosition(tweetText.beginningOfDocument, toPosition: tweetText.beginningOfDocument)
        // Do any additional setup after loading the view.
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText: NSString = tweetText.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if countElements(updatedText) == 0 {
            
            textView.text = "What do you want to say?"
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = tweetText.textRangeFromPosition(tweetText.beginningOfDocument, toPosition: tweetText.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if tweetText.textColor == UIColor.lightGrayColor() && countElements(text) > 0 {
            tweetText.text = nil
            tweetText.textColor = UIColor.blackColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGrayColor()
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
