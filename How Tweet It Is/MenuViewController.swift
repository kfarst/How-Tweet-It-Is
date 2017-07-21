//
//  MenuViewController.swift
//  How Tweet It Is
//
//  Created by Kevin Farst on 2/24/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var contentViewTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var timelineButton: UIButton!
    @IBOutlet weak var mentionsButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        if sender == timelineButton {
            self.activeViewController = self.viewControllers!["dashboard"]
            timelineButton.setTitleColor(twitterBlue, for: .normal)
            mentionsButton.setTitleColor(UIColor.white, for: .normal)
            profileButton.setTitleColor(UIColor.white, for: .normal)
        } else if sender == mentionsButton {
            self.activeViewController = self.viewControllers!["mentions"]
            timelineButton.setTitleColor(UIColor.white, for: .normal)
            mentionsButton.setTitleColor(twitterBlue, for: .normal)
            profileButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.activeViewController = self.viewControllers!["profile"]
            timelineButton.setTitleColor(UIColor.white, for: .normal)
            mentionsButton.setTitleColor(UIColor.white, for: .normal)
            profileButton.setTitleColor(twitterBlue, for: .normal)
        }
        
        closeMenu()
    }
    
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        if menuOpen == false {
            self.menuOpen = true
            self.contentViewTapRecognizer.isEnabled = true
            
            UIView.animate(withDuration: 0.35, animations: {
                var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = -1.0 / 800.0;
                self.contentView.layer.zPosition = 100
                rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, self.contentView.frame.size.width / 2 * 0.4, 0.0, 0.0);
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 0.6, 0.6, 0.6);
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(-45.0 * .pi / 180.0), 0.0, 1.0, 0.0)
                
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.contentView.layer.transform = rotationAndPerspectiveTransform
                })
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        if (sender.state == .ended) {
            closeMenu()
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        closeMenu()
    }
    
    let twitterBlue = UIColor(hexString: "#55acee")
    var sb = UIStoryboard(name: "Main", bundle: nil)
    var menuOpen = false
    var viewControllers: [String: UIViewController]?
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil) {
            if let oldVC = oldViewControllerOrNil {
                oldVC.willMove(toParentViewController: nil)
                oldVC.view.removeFromSuperview()
                oldVC.removeFromParentViewController()
            }
            if let newVC =  activeViewController {
                self.addChildViewController(newVC)
                newVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                newVC.view.frame = self.contentView.bounds
                self.contentView.addSubview(newVC.view)
                newVC.didMove(toParentViewController: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let dashboardVC = sb.instantiateViewController(withIdentifier: "TimelineNavController") as! CustomNavigationViewController
        
        let mentionsVC = sb.instantiateViewController(withIdentifier: "TimelineNavController") as! CustomNavigationViewController
        (mentionsVC.viewControllers[0] as! DashboardViewController).timelineType = "mentions"
        
        let profileVC = sb.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        self.viewControllers = ["dashboard": dashboardVC, "mentions": mentionsVC, "profile": profileVC]
        self.activeViewController = self.viewControllers!["dashboard"]
        timelineButton.setTitleColor(twitterBlue, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeMenu() {
        if (menuOpen) {
            self.menuOpen = false
            self.contentViewTapRecognizer.isEnabled = false
            
            UIView.animate(withDuration: 0.35, animations: {
                var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = -1.0 / 800.0;
                self.contentView.layer.zPosition = 100
                rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0.0, 0.0, 0.0);
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 1.0, 1.0, 1.0);
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.0, 0.0, 1.0, 0.0)
                
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.contentView.layer.transform = rotationAndPerspectiveTransform
                })

                self.view.layoutIfNeeded()
            })
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
