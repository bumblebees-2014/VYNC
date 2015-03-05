//
//  LoginViewController.swift
//  VYNC
//
//  Created by Thomas Abend on 2/2/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController, FBLoginViewDelegate {
    
    @IBOutlet weak var fbLoginView : FBLoginView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var pageImage: UIImageView!
    var pageIndex: Int!
    var color: String!
    var titleString : String!
    var imageString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        if color == nil {
            color = "Red"
        }
        if color == "Red" {
            self.view.backgroundColor = UIColor(netHex:0x7FF2FF)
        } else if color == "Green" {
            self.view.backgroundColor = UIColor(netHex:0x73A1FF)
        } else if color == "Blue" {
            self.view.backgroundColor = UIColor(netHex:0xFFB5C9)
        }
        pageLabel.text = titleString!
        pageImage.image = UIImage(named: imageString!)
        
    }
    

    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("RootNavigationController") as UINavigationController
        presentViewController(vc, animated: true, completion: {
        
            // Push notification settings being set and request from user being fired
            var types: UIUserNotificationType = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
            var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        })
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser){

        let fbId = user.objectID as String
        if myUserId() == nil {
            FBRequestConnection.startForMeWithCompletionHandler{(connection, user, error) -> Void in
                println("Adding user")
                let email = user.objectForKey("email") as String
                // new User object
                var newUser = User.syncer.newObj()
                newUser.id = 0
                newUser.username = user.name
                newUser.facebookObjectId = fbId
                newUser.isMe = 1
                newUser.email = email
                User.syncer.save()
                User.syncer.sync()
            }
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println(UIScreen.mainScreen().bounds)
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}