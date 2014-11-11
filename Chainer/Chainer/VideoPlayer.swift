//
//  VideoPlayer.swift
//  Chainer
//
//  Created by Faraaz Nishtar on 11/11/14.
//  Copyright (c) 2014 DBC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Foundation

public func avPlayerControllerFor(url: String) -> AVPlayerViewController {
    let player: AVPlayer = AVPlayer(URL: NSURL(string: url))
    // create player view controller
    let avPlayerVC = AVPlayerViewController()
    avPlayerVC.player = player
    
    return avPlayerVC
}

public func playVidUrlOnViewController(vidUrl: String, vc: UIViewController) {
    
    let avPlayerVC = avPlayerControllerFor(vidUrl)
    
    // show player view controller
    vc.presentViewController(avPlayerVC, animated: true, completion: {
        avPlayerVC.player.play()
    })
    
}