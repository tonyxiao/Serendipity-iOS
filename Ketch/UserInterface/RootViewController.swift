//
//  RootViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import FacebookSDK
import Meteor

class RootViewController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // If server logs us out, then let's also log out of the UI
        listenForNotification(METDDPClientDidChangeAccountNotification).filter { _ in
            return !Core.meteor.hasAccount()
        }.deliverOnMainThread().flattenMap { _ in
            return UIAlertView.show("Error", message: "You have been logged out")
        }.subscribeNext { [weak self] _ in
            self?.showSignup(false)
            return
        }
//        showWelcome(false)

        // Try login now
        if !Core.attemptLoginWithCachedCredentials() {
            showSignup(false)
        } else {
            showGame(false)
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue);
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if let vc = topViewController {
            return vc.prefersStatusBarHidden()
        } else {
            return false
        }
    }
    
    private func makeViewController(identifier: String) -> UIViewController {
        return storyboard?.instantiateViewControllerWithIdentifier(identifier) as UIViewController!
    }
        
    func showProfile(user: User?, animated: Bool) {
        setViewControllers([makeViewController("Profile")], animated: animated)
    }
    
    func showGame(animated: Bool) {
        setViewControllers([makeViewController("Game")], animated: animated)
    }
    
    func showSignup(animated: Bool) {
        setViewControllers([makeViewController("Signup")], animated: animated)
    }
    
    func showWelcome(animated: Bool) {
        setViewControllers([makeViewController("Welcome")], animated: animated)
    }
    
    @IBAction func logout(sender: AnyObject) {
        self.showSignup(true)
        Core.logout().subscribeCompleted {
            Log.info("Signed out")
        }
    }
}
