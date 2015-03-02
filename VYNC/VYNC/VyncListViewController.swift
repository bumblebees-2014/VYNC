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
    var refreshControl:UIRefreshControl!
    
//    Setting this equal to a global variable that is an array of vyncs. This will later be replaced by a function return from a dB query.
    var vyncs = VideoMessage.asVyncs()
    var lastPlayed : Int? = nil
    
    var videoLayer = VyncPlayerLayer()

    @IBOutlet weak var showStatsButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vyncTable.rowHeight = UITableViewAutomaticDimension
        self.vyncTable.estimatedRowHeight = 70
        setupButtons()

        VideoMessage.syncer.uploadNew() {done in
            self.updateView()
            VideoMessage.syncer.downloadNew() {done in
                self.updateView()
            }
        }
    }
    
    func setupButtons(){
        // Set the font of nav bar title
        let color = UIColor(netHex:0x73A1FF)
        let font = [NSFontAttributeName: UIFont(name: "Egypt 22", size: 50)!, NSForegroundColorAttributeName: color]
        self.navigationController!.navigationBar.titleTextAttributes = font
        // Set the font of nav bar item
        let buttonColor = UIColor(netHex:0x7FF2FF)
        let buttonFont = [NSFontAttributeName: UIFont(name: "flaticon", size: 28)!, NSForegroundColorAttributeName: buttonColor]
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
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        updateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vyncs.count
    }
    
    @IBAction func reloadVyncs() {
        println("refresh \(VideoMessage.syncer.all().exec()!.count)")
        self.refreshControl.beginRefreshing()
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
        self.vyncs = VideoMessage.asVyncs()
        self.vyncTable.reloadData()
        self.vyncTable.setNeedsDisplay()
    }
    
    // Set the properties of cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VyncCell", forIndexPath: indexPath) as VyncCell
        addGesturesToCell(cell)
       //        Set Title and Length Labels
        let date = vyncs[indexPath.row].mostRecent()
        
        cell.titleLabel.text = vyncs[indexPath.row].title()
        cell.lengthLabel.text = String(vyncs[indexPath.row].size())
        // New vyncs get special color and gesture
        if vyncs[indexPath.row].waitingOnYou {
            cell.statusLogo.textColor = UIColor(netHex:0xFFB5C9)
//            cell.lengthLabel.text = "?"
            cell.lengthLabel.backgroundColor = UIColor(netHex:0xFFB5C9)
            cell.subTitle.text = "\(date) - Swipe to Reply"
        } else {
            cell.subTitle.text = "\(date) - Hold to Play"
            cell.statusLogo.textColor = UIColor(netHex:0x7FF2FF)
            cell.lengthLabel.backgroundColor = UIColor(netHex:0x7FF2FF)
        }
        // Unwatched vyncs get a flame
        if vyncs[indexPath.row].unwatched {
            cell.isWatchedLabel.hidden = false
        } else {
            cell.isWatchedLabel.hidden = true
        }
        
        // Not yet uploaded vyncs/Not yet saved vyncs get special background color
        if vyncs[indexPath.row].notUploaded {
            cell.contentView.layer.borderWidth = 0.5
            cell.contentView.layer.borderColor = UIColor.redColor().CGColor
            cell.lengthLabel.layer.borderWidth = 2.0
            cell.lengthLabel.layer.borderColor = UIColor.redColor().CGColor
        } else if vyncs[indexPath.row].isSaved == false {
            cell.statusLogo.textColor = UIColor.orangeColor()
            cell.subTitle.textColor = UIColor.orangeColor()
            cell.titleLabel.transform = CGAffineTransformMakeTranslation(0, -10)
            cell.subTitle.text = "Tap to download"
        } else {
            cell.contentView.layer.borderWidth = 0.0
            cell.lengthLabel.layer.borderWidth = 0.0
        }
        return cell
    }
    
    
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

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if vyncs[indexPath.row].waitingOnYou {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let replyClosure = { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            self.reply(indexPath.row)
        }
        
        let reply = UITableViewRowAction(
            style: UITableViewRowActionStyle.Normal,
            title: "FORWARD",
            handler: replyClosure
            )
        reply.backgroundColor = UIColor(netHex: 0xFFB5C9)
        return [reply]
    }
    
    
    @IBAction func holdToPlayVideos(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            if let index = self.vyncTable.indexPathForRowAtPoint(sender.view!.center)?.row as Int! {
                if vyncs[index].isSaved {
                    if index != self.lastPlayed {
                        self.videoLayer.player = nil
                        let items = vyncs[index].videoItems()
                        var loopPlayer = AVQueueLoopPlayer(items: items)
                        self.videoLayer.player = loopPlayer
                        // In order to communicate the information abou
                        loopPlayer.layer = self.videoLayer
                        vyncs[index].unwatched = false
                        updateView()
                        self.lastPlayed = index
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
        if let cell = vyncTable.cellForRowAtIndexPath(indexPath!) as? VyncCell {
            let index = indexPath!.row as Int
            let v = vyncs[index]
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
                println("saved")
                cell.selectCellAnimation()
            }
        }

    }
    
    func doubleTapCell(sender:UITapGestureRecognizer){
        let indexPath:NSIndexPath = self.vyncTable.indexPathForRowAtPoint(sender.view!.center)!
        if let cell = vyncTable.cellForRowAtIndexPath(indexPath) as? VyncCell {
            if cell.isFlipped == false {
//                let view = self.view.viewWithTag(19)
                cell.isFlipped = true
                
                cell.titleLabel.text = "Users on this vync:\n" + vyncs[indexPath.row].usersList()
                UIView.setAnimationsEnabled(false)
                vyncTable.beginUpdates()
                vyncTable.endUpdates()
                UIView.setAnimationsEnabled(true)

            } else {
                cell.titleLabel.text = vyncs[indexPath.row].title()
                cell.isFlipped = false
                vyncTable.beginUpdates()
                vyncTable.endUpdates()
            }
        }
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
    
}
