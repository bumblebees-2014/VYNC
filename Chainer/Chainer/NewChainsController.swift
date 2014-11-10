//
//  FirstViewController.swift
//  viewAllUsers
//
//  Created by Apprentice on 11/8/14.
//  Copyright (c) 2014 Apprentice. All rights reserved.
//

import UIKit

class NewChainsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblVideoMessages: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(videoMessageMgr.newVideoMessages.count)
    }
    
    override func viewDidAppear(animated: Bool) {
        tblVideoMessages.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSource requirements
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "test")
        cell.textLabel.text = "Video Id: \(videoMessageMgr.newVideoMessages[indexPath.row].messageID)"
        cell.detailTextLabel?.text = "Reply To: \(videoMessageMgr.newVideoMessages[indexPath.row].replyToID). Created at \(videoMessageMgr.newVideoMessages[indexPath.row].createdAt)"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoMessageMgr.newVideoMessages.count
    }
    
    // Load a new view when clicked --> to be filled in with a show video route
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("anyone listening?")
        let cameraView = self.storyboard?.instantiateViewControllerWithIdentifier("Camera") as CameraViewController
        self.navigationController?.pushViewController(cameraView, animated: true)
    }
}

