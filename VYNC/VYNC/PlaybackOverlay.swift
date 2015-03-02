
//
//  PlaybackOverlay.swift
//  VYNC
//
//  Created by Thomas Abend on 1/27/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

protocol VyncCameraPlaybackLayerDelegate {
    func acceptVideo()
    func retakeVideo()
}

class VyncCameraPlaybackLayer: UIView {
    
    var videoList : [NSURL] = []
    var playbackDelegate : VyncCameraPlaybackLayerDelegate? = nil
    let playerLayer = AVPlayerLayer()
    
    @IBAction func acceptVideo(sender: AnyObject) {
        playbackDelegate!.acceptVideo()
    }
    
    @IBAction func retakeVideo(sender: AnyObject) {
        playbackDelegate!.retakeVideo()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bounds = UIScreen.mainScreen().bounds
        self.bounds = bounds
        self.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        playerLayer.bounds = bounds
        playerLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.zPosition = -1
        self.layer.addSublayer(playerLayer)
        self.tag = 2
    }
    
    func playVideos(){
        let items = self.videoList.map({video in AVPlayerItem(URL:video)})
        self.playerLayer.player = AVQueuePlayer(items: items)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "repeat:", name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)
        self.playerLayer.player.play()
    }
    
    func repeat(notification:NSNotification){
        if let playerItem = notification.object as? AVPlayerItem {
            let asset = playerItem.asset
            let copyOfPlayerItem = AVPlayerItem(asset: asset)
            let player = self.playerLayer.player as AVQueuePlayer
            player.insertItem(copyOfPlayerItem, afterItem: nil)
            
        }
    }
    
    deinit {
        self.playerLayer.player = nil;
        self.playerLayer.removeFromSuperlayer()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)
    }
    
}
