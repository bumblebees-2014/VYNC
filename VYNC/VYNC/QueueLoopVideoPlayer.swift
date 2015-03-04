//
//  QueueLoopVideoPlayer.swift
//  VYNC
//
//  Created by Thomas Abend on 1/27/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import AVKit

class AVQueueLoopPlayer : AVQueuePlayer {
    
    var layer : VyncPlayerLayer!
    
    override func play() {
        super.play()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "repeat:", name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)
    }
    
    func repeat(notification:NSNotification){
        if var playerItem = notification.object as? AVPlayerItem {
            var asset = playerItem.asset
            var copyOfPlayerItem = AVPlayerItem(asset: asset)
            self.insertItem(copyOfPlayerItem, afterItem: nil)
            println("REPEAT. Items Size=\(self.items().count)")
        }
    }
    
    deinit {
        println("queue deinit")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AVPlayerItemDidPlayToEndTimeNotification", object: nil)
    }
}

class VyncPlayerLayer : AVPlayerLayer {
    
    var timer = CATextLayer()
    var currentItemDuration = 0
    var counting = true
    
    override init(){
        super.init()
        self.backgroundColor = UIColor.blackColor().CGColor
        self.frame = UIScreen.mainScreen().bounds
        self.videoGravity = AVLayerVideoGravityResizeAspectFill
        timer.frame = CGRectMake(30, 30, 60, 60)
        self.timer.font = UIFont(name: "Egypt 22", size: 60)
        self.timer.foregroundColor = UIColor(netHex:0x73A1FF).CGColor
        self.timer.fontSize = 60
        timer.string = ""
        self.addSublayer(timer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func playVideos() {
        self.player.addPeriodicTimeObserverForInterval(
            CMTimeMake(1,1),
            queue: dispatch_get_main_queue(),
            usingBlock: {
                (callbackTime: CMTime) -> Void in
                var item = (self.player as AVQueuePlayer).items().first as AVPlayerItem!
                var duration = Int(round(CMTimeGetSeconds(item.asset.duration)))
                var currentTime = Int(round(CMTimeGetSeconds(item.currentTime())))
                self.timer.string = "\(duration - currentTime)"
        })
        self.player.play()
    }

}