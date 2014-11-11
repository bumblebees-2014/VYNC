//  VideosMessages.swift
//  viewAllUsers
//
//  Created by Apprentice on 11/9/14.
//  Copyright (c) 2014 Apprentice. All rights reserved.
//

import Foundation
import UIKit

struct VideoMessage : JSONJoy {
    var messageID: Int?
    var replyToID: Int?
    var senderID: Int?
    var recipientID: Int?
    var videoID: String?
    var createdAt: String?
    var chain : Chain?
    
    
    init() {
    }
    
    init(_ decoder: JSONDecoder) {
        messageID = decoder["id"].integer as Int!
        replyToID = decoder["reply_to_id"].integer as Int!
        senderID = decoder["sender_id"].integer as Int!
        recipientID = decoder["recipient_id"].integer as Int!
        videoID = decoder["video_id"].string as String!
        createdAt = decoder["created_at"].string as String!
    }
    

    
}

struct Chain : JSONJoy, Equatable {
    
    var videos : [VideoMessage] = []
    
    init() {
    }
    init(_ decoder: JSONDecoder) {
        if let vms = decoder.array {
            videos = [VideoMessage]()
            for vmDecoder in vms {
                videos.append(VideoMessage(vmDecoder))
            }
        }
    }
    
}

func ==(c1 : Chain, c2 : Chain) -> Bool {
    return c1.videos.first?.replyToID == c2.videos.first?.replyToID
}



// This hard coding is to allow for more simple refactoring later.
let device_id = 1

class VideoMessageManager {

    var videos = [VideoMessage]()
    
    var chainsById = [ Int : Chain ]()
    
    func getInitialValues() {

        updateChains()
    }
    
//    if recipientID is your id and the message is the last message in the chain it's your turn to reply.
//    func newChains() {
//        for chain in self.chainsById.values {
////            if chain.videos.last.recipientID == device_id {
//            
//            }
//        }
//    }
    // iterate through all vms backwards. If vm.chain is already in my list of chains do nothing, if it isn't add it to my list of chains.

    func showChains() -> [Chain]{
        // Reverse the videos to get most recent first. (could also sort by created_at...may be a better solution...)
        let allMessages = reverse(self.videos)
        // list of chains
        var readyChains = [Chain]()
        
        // iterate through videos
        for video in allMessages {
            println(video.replyToID!)
            if contains(readyChains, chainsById[video.replyToID!]!) {
                println("\(video.messageID!)'s chain is already there")
            } else {
                readyChains.append(chainsById[video.replyToID!]!)
                println("\(chainsById[video.messageID!]!)'s chain was added")
            }
        }
        return readyChains
    }
    
    

    func updateChains() {
        var data : NSData?
        var request = HTTPTask()
        request.GET("http://chainer.herokuapp.com/videomessages/\(device_id)/all", parameters: nil,
            success: {(response: HTTPResponse) in
                if response.responseObject != nil {
                    data = response.responseObject as? NSData
                    if let data = response.responseObject as? NSData {
                        let str = NSString(data: data, encoding: NSUTF8StringEncoding)
                        println("response from all vms: \(str)") //prints the HTML of the page
                    }
                    var newMessages = [VideoMessage]()
                    JSONDecoder(data!).arrayOf(&newMessages)
                    for message in newMessages {
                        var msg = message
                        // add to our dictionary of chains
                        var chain = self.chainsById[msg.replyToID!]
                        if chain == nil {
                            self.chainsById[msg.replyToID!] = Chain()
                            chain = self.chainsById[msg.replyToID!]
                        }
                        msg.chain = chain
                        chain!.videos.append(msg)
                        
                        // add to our total list of messages
                        self.videos.append(msg)
                    }
                }
        })
    }
    

}

let videoMessageMgr = VideoMessageManager()

