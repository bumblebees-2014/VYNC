//
//  File.swift
//  VYNC
//
//  Created by Thomas Abend on 1/18/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//
import UIKit
import CoreMedia
import CoreData
import MobileCoreServices
import AVKit
import AVFoundation

class VyncListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet var vyncTable: UITableView!
    @IBOutlet weak var showStatsButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    var refreshControl:UIRefreshControl!
    var vyncs = [Vync]()
    var deadVyncs = [Vync]()
    var lastPlayed : NSIndexPath?
    var videoLayer = VyncPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set vyncTable attributes
        self.vyncTable.separatorStyle = UITableViewCellSeparatorStyle.None
        self.vyncTable.rowHeight = UITableViewAutomaticDimension
        self.vyncTable.estimatedRowHeight = 70
        
        setupButtons()
        
        // Sync New Videos
        VideoMessage.syncer.uploadNew() {done in
            VideoMessage.syncer.downloadNew() {done in
                self.updateView()
            }
        }
    }
    
    func setupButtons(){
        // Set the font of nav bar title

        let font = [NSFontAttributeName: UIFont.VEgypt(), NSForegroundColorAttributeName: UIColor.VBlue()]
        self.navigationController!.navigationBar.titleTextAttributes = font
        // Set the font of nav bar item
        let buttonFont = [NSFontAttributeName: UIFont(name: "flaticon", size: 28)!, NSForegroundColorAttributeName: UIColor.VTeal()]
        showStatsButton.setTitleTextAttributes(buttonFont, forState: .Normal)
        showStatsButton.title = "\u{e004}"
        cameraButton.setTitleTextAttributes(buttonFont, forState: .Normal)
        cameraButton.title = "\u{e006}"
        // Add pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "reloadVyncs", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.layer.zPosition = -1
        self.vyncTable.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.lastPlayed = nil
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        updateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ACTIONS
    
    @IBAction func reloadVyncs() {
        self.refreshControl.beginRefreshing()
        self.lastPlayed = nil
        VideoMessage.syncer.uploadNew() {done in
            VideoMessage.syncer.downloadNew() {done in
                VideoMessage.saveNewVids() {done in
                    self.updateView()
                    self.refreshControl.endRefreshing()
                }
            }
        }
        User.syncer.sync()
    }
    
    func updateView() {
        let vyncArrays = VideoMessage.vyncArrays()
        self.vyncs = vyncArrays[0]
        self.deadVyncs = vyncArrays[1]
        self.vyncTable.reloadData()
        self.vyncTable.setNeedsDisplay()
    }
    
    func reply(index:Int){
        let camera = self.storyboard?.instantiateViewControllerWithIdentifier("Camera") as VyncCameraViewController
        camera.vync = vyncs[index]
        self.presentViewController(camera, animated: false, completion: nil)
    }
    
    @IBAction func showCam() {
        let camera = self.storyboard?.instantiateViewControllerWithIdentifier("Camera") as VyncCameraViewController
        self.presentViewController(camera, animated: false, completion: nil)
    }
    
    // CELL PROPERTIES
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return vyncs.count
        } else {
            return deadVyncs.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return "Active VYNCS"
        } else {
            return "Inactive VYNCS"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VyncCell", forIndexPath: indexPath) as VyncCell
        
        let array = indexPath.section == 0 ? vyncs : deadVyncs
        let vync = array[indexPath.row] as Vync
        cell.setVyncData(vync)
        addGesturesToCell(cell)
        return cell
    }
    
    // CELL EDITING FEATURES
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0 ? vyncs[indexPath.row].waitingOnYou : true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if(indexPath.section == 0) {
            let replyClosure = { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                self.reply(indexPath.row)
            }
            
            let reply = UITableViewRowAction(
                style: UITableViewRowActionStyle.Normal,
                title: "FORWARD",
                handler: replyClosure
            )
            reply.backgroundColor = UIColor.VPink()
            return [reply]
        } else {
            let delete = UITableViewRowAction(
                style: UITableViewRowActionStyle.Normal,
                title: "DELETE",
                handler: {
                    done in
                    self.deadVyncs[indexPath.row].delete()
                    self.deadVyncs.removeAtIndex(indexPath.row)
                    self.lastPlayed = nil;
                    self.vyncTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic
                    )
                }
            )
            return [delete]
        }
    }
    
    // CELL GESTURES
    
    func addGesturesToCell(cell:UITableViewCell){
        // long touch for playback
        let longTouch = UILongPressGestureRecognizer()
        longTouch.minimumPressDuration = 0.3
        longTouch.addTarget(self, action: "holdToPlayVideos:")
        cell.addGestureRecognizer(longTouch)
        
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTapCell:")
        singleTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target:self, action: "doubleTapCell:")
        doubleTap.numberOfTapsRequired = 2
        
        cell.addGestureRecognizer(singleTap)
        cell.addGestureRecognizer(doubleTap)
        singleTap.requireGestureRecognizerToFail(doubleTap)
    }

    @IBAction func holdToPlayVideos(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            if let indexPath = self.vyncTable.indexPathForRowAtPoint(sender.view!.center)? {
                let array = indexPath.section == 0 ? vyncs : deadVyncs
                let index = indexPath.row as Int
                let vync = array[index]
                if vync.isSaved {
                    if indexPath != self.lastPlayed {
                        self.videoLayer.player = nil
                        let items = array[index].videoItems()
                        var loopPlayer = AVQueueLoopPlayer(items: items)
                        self.videoLayer.player = loopPlayer
                        // In order to communicate the information abou
                        loopPlayer.layer = self.videoLayer
                        vync.markAsWatched()
                        updateView()
                        self.lastPlayed = indexPath
                    }
                    self.navigationController?.view.layer.addSublayer(self.videoLayer)
                    self.videoLayer.playVideos()
                }
            }
        }
        if sender.state == .Ended {
            self.videoLayer.player.pause()
            self.videoLayer.removeFromSuperlayer()
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        }
    }
    
    func singleTapCell(sender:UITapGestureRecognizer){
        let indexPath = self.vyncTable.indexPathForRowAtPoint(sender.view!.center)
        let array = indexPath?.section == 0 ? vyncs : deadVyncs

        if let cell = vyncTable.cellForRowAtIndexPath(indexPath!) as? VyncCell {
            let index = indexPath!.row as Int
            let v = array[index]
            if v.isSaved == false {
                cell.statusLogo.hidden = true
                cell.saving.startAnimating()
                VideoMessage.saveTheseVids(v.messages) {done in
                    cell.statusLogo.hidden = false
                    cell.saving.stopAnimating()
                    self.updateView()
                    cell.deselectCellAnimation()
                }
            } else {
                if !cell.isFlipped {
                    cell.selectCellAnimation()
                }
            }
        }

    }
    
    func doubleTapCell(sender:UITapGestureRecognizer){
        let indexPath:NSIndexPath = self.vyncTable.indexPathForRowAtPoint(sender.view!.center)!
        let array = indexPath.section == 0 ? vyncs : deadVyncs
        if let cell = vyncTable.cellForRowAtIndexPath(indexPath) as? VyncCell {
            if cell.isFlipped == false {
                cell.isFlipped = true
                // In case it was single tapped before
                cell.subTitle.textColor = UIColor.clearColor()
                cell.titleLabel.transform = CGAffineTransformMakeTranslation(0, 0)
                cell.titleLabel.text = array[indexPath.row].usersList
                vyncTable.beginUpdates()
                vyncTable.endUpdates()
            } else {
                cell.titleLabel.text = array[indexPath.row].title
                cell.isFlipped = false
                vyncTable.beginUpdates()
                vyncTable.endUpdates()
            }
        }
    }
    
}
