//
//  TitleViewController.swift
//  VYNC
//
//  Created by Thomas Abend on 1/26/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit

class TitleViewController : UIViewController, UITextFieldDelegate {
    var replyToId: Int = 0

    @IBOutlet weak var vyncTitle: UITextField!

    
    @IBOutlet weak var charsLeft: UILabel!
    

    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.utf16Count + string.utf16Count - range.length
        charsLeft.text = "\(30 - newLength)"
        return newLength < 30 //Bool
    }
    
    @IBAction func submit(sender: AnyObject) {
        if vyncTitle.text == "" {
            let alert = UIAlertController(title: "Nope!", message: "You must enter a title in order to start a new VYNC.", preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: false, completion: {})
        } else {
            let contactsNav = self.storyboard?.instantiateViewControllerWithIdentifier("ContactsNav") as UINavigationController
            let contacts = contactsNav.viewControllers[0] as ContactsViewController
            contacts.replyToId = self.replyToId
            contacts.vyncTitle = vyncTitle.text
            self.presentViewController(contactsNav, animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vyncTitle.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
