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
    
    @IBAction func menuButtonTapped(sender: UIButton) {
        if sender == timelineButton {
            self.activeViewController = self.viewControllers!["dashboard"]
        } else if sender == mentionsButton {
            self.activeViewController = self.viewControllers!["mentions"]
        } else {
            self.activeViewController = self.viewControllers!["profile"]
        }
        
        closeMenu()
    }
    
    
    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        if menuOpen == false {
            self.menuOpen = true
            self.contentViewTapRecognizer.enabled = true
            
            UIView.animateWithDuration(0.35, animations: {
                var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = -1.0 / 800.0;
                self.contentView.layer.zPosition = 100
                rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, self.contentView.frame.size.width / 2 * 0.4, 0.0, 0.0);
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 0.6, 0.6, 0.6);
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(-45.0 * M_PI / 180.0), 0.0, 1.0, 0.0)
                
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.contentView.layer.transform = rotationAndPerspectiveTransform
                })
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func swipeLeft(sender: UISwipeGestureRecognizer) {
        if (sender.state == .Ended) {
            closeMenu()
        }
    }
    
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        closeMenu()
    }
    
    var sb = UIStoryboard(name: "Main", bundle: nil)
    var menuOpen = false
    var viewControllers: [String: UIViewController]?
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil) {
            if let oldVC = oldViewControllerOrNil {
                oldVC.willMoveToParentViewController(nil)
                oldVC.view.removeFromSuperview()
                oldVC.removeFromParentViewController()
            }
            if let newVC =  activeViewController {
                self.addChildViewController(newVC)
                newVC.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
                newVC.view.frame = self.contentView.bounds
                self.contentView.addSubview(newVC.view)
                newVC.didMoveToParentViewController(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        var dashboardVC = sb.instantiateViewControllerWithIdentifier("TimelineNavController") as CustomNavigationViewController
        
        var mentionsVC = sb.instantiateViewControllerWithIdentifier("TimelineNavController") as CustomNavigationViewController
        (mentionsVC.viewControllers[0] as DashboardViewController).timelineType = "mentions"
        
        var profileVC = sb.instantiateViewControllerWithIdentifier("ProfileViewController") as ProfileViewController
        
        self.viewControllers = ["dashboard": dashboardVC, "mentions": mentionsVC, "profile": profileVC]
        self.activeViewController = self.viewControllers!["dashboard"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeMenu() {
        if (menuOpen) {
            self.menuOpen = false
            self.contentViewTapRecognizer.enabled = false
            
            UIView.animateWithDuration(0.35, animations: {
                var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = -1.0 / 800.0;
                self.contentView.layer.zPosition = 100
                rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0.0, 0.0, 0.0);
                rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 1.0, 1.0, 1.0);
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 0.0, 0.0, 1.0, 0.0)
                
                UIView.animateWithDuration(1.0, animations: { () -> Void in
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
