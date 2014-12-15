
//  Created by Apprentice on 11/8/14.
//  Copyright (c) 2014 Apprentice. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet var tblUsers: UITableView!
    @IBOutlet var searchBar : UISearchBar!

    var users = [User]()
    var filteredUsers = [User]()
    var replyToID : Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Returning to view. Loops through users and reloads them.
    override func viewWillAppear(animated: Bool) {
        users = userMgr.asUsers()
        tblUsers.reloadData()
    }
    
    // UITableViewDataSource requirements
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "test")
        
        var user : User
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.textLabel?.text = "\(user.username)"

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return filteredUsers.count
        } else {
            return users.count
        }
    }
    
    // Sending a video message to the server
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let videoURL = NSURL(string: PathToFile)
        let userID = users[indexPath.item].userID
        var deviceID = UIDevice.currentDevice().identifierForVendor.UUIDString
        //post the video that the user takes to the server
        var request = HTTPTask()
        println(self.replyToID!)
        request.POST("http://chainer.herokuapp.com/upload", parameters: [
            "replyToID": self.replyToID!,
            "senderDevice": deviceID,
            "recipient" : userID,
            "file": HTTPUpload(fileUrl: videoURL!) ],
            success: {(response: HTTPResponse) in
                if let data = response.responseObject as? NSData {
                    self.replyToID = 0
                }
            
            },failure: {(error: NSError, response: HTTPResponse?) in
        })
        self.performSegueWithIdentifier("backToHome", sender: self)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filteredUsers = self.users.filter({( user : User) -> Bool in
            var categoryMatch = (scope == "All") || (user.username == scope)
            var stringMatch = user.username.rangeOfString(searchText.lowercaseString)
            return categoryMatch && (stringMatch != nil)
        })
    }
    
    //MARK: - UISearchBarDelegate
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString.lowercaseString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!,
        shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text.lowercaseString)
        return true
    }
}

