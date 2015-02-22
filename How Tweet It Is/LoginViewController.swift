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
                self.performSegueWithIdentifier("DashboardSegue", sender: self)
            } else {
               println(error)
            }
            
        }
    }
}
