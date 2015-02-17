//
//  LoginViewController.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/16/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func twitterLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user: User?, error: NSError?) in
            if user != nil {
                self.performSegueWithIdentifier("homeSegue", sender: self)
            } else {
               //var alert = UIAlertController(title: "Error", message: error as? String, preferredStyle: UIAlertControllerStyle.Alert)
               //alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
               //self.presentViewController(alert, animated: true, completion: nil)
               //println(error)
            }
            
        }
    }
}
