//
//  LoginViewController.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/16/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var sb = UIStoryboard(name: "Main", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func twitterLogin(_ sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user: User?, error: Error?) in

            if user != nil {
                var dashboardController = self.sb.instantiateViewControllerWithIdentifier("MenuViewController") as MenuViewController
                self.presentViewController(dashboardController, animated: true, completion: nil)
            } else {
               print(error as Any)
            }

        }
    }
}
