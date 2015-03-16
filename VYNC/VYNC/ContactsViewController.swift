//
//  ContactsViewController.swift
//  VYNC
//
//  Created by Thomas Abend on 1/25/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var contacts = User.syncer.all().filter("isMe == 2 && facebookObjectId != nil").exec()!
    var otherUsers = User.syncer.all().filter("isMe == nil && facebookObjectId != nil").exec()!
    
    var filteredUsers = [User]()
    var replyToId : Int = 0
    var vyncTitle : String?

    @IBOutlet var contactsList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchDisplayController!.searchResultsTableView.registerClass(ContactCell.self, forCellReuseIdentifier: "ContactCell")
        self.contactsList.rowHeight = UITableViewAutomaticDimension
        self.searchDisplayController?.searchResultsTableView.rowHeight = UITableViewAutomaticDimension
        contactsList.reloadData()
        contactsList.setNeedsDisplay()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource requirements
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : ContactCell
        var user : User
        if tableView == self.searchDisplayController!.searchResultsTableView {
            cell = self.contactsList.dequeueReusableCellWithIdentifier("ContactCell") as ContactCell
            user = filteredUsers[indexPath.row]
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as ContactCell
            if indexPath.section == 0 {
                user = contacts[indexPath.row] as User
            } else {
                user = otherUsers[indexPath.row] as User
            }

        }
        cell.setupContact(user)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return "Matches"
        } else {
            if(section == 0) {
                return "Friends"
            } else {
                return "Other Users"
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return filteredUsers.count
        } else {
            if section == 0 {
               return contacts.count
            } else {
               return otherUsers.count
            }

        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let recipientId = contacts[indexPath.row].id
        let filePath = videoFolder + "/videoToSend.mov"
        let data = NSData(contentsOfFile: filePath)
        let videoId = NSUUID().UUIDString + ".mov"
        let newFilePath = videoFolder + "/" + videoId
        data?.writeToFile(newFilePath, atomically: true)
        
        if self.replyToId != 0 {
            println("making a reply \(replyToId)")
            let vyncToUpdate = VideoMessage.allVyncs().filter({vync in vync.replyToId == self.replyToId})[0]

            var newMessage = VideoMessage.syncer.newObj()
            newMessage.id = 0
            newMessage.videoId = videoId
            newMessage.replyToId = replyToId
            newMessage.recipientId = recipientId
            newMessage.senderId = User.myUserId()
            newMessage.title = ""
            newMessage.saved = 1
            VideoMessage.syncer.save()

        } else {
            var newMessage = VideoMessage.syncer.newObj()
            newMessage.id = 0
            newMessage.videoId = videoId
            // but what if you have more than one 0? This is broken as is.
            newMessage.replyToId = 0
            newMessage.recipientId = recipientId
            newMessage.senderId = User.myUserId()
            newMessage.title = self.vyncTitle!
            newMessage.saved = 1
            VideoMessage.syncer.save()
        }
        performSegueWithIdentifier("backToHome", sender: self)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        let allUsers = contacts + otherUsers
        self.filteredUsers = allUsers.filter({( user : User) -> Bool in
            var nameMatch = (scope == "All") || (user.username == scope)
            var stringMatch = user.username.lowercaseString.rangeOfString(searchText.lowercaseString)
            return nameMatch && (stringMatch != nil)
        })
    }
    
    //MARK: - UISearchBarDelegate
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString.lowercaseString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController,
        shouldReloadTableForSearchScope searchOption: Int) -> Bool {
            self.filterContentForSearchText(self.searchDisplayController!.searchBar.text.lowercaseString)
            return true
    }
}