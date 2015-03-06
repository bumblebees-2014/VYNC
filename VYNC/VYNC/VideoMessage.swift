//
//  VideoMessage.swift
//  VYNC
//
//  Created by Thomas Abend on 1/30/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import CoreData

@objc(VideoMessage)
class VideoMessage: NSManagedObject {
    
    class var syncer : Syncer<VideoMessage> {
        return Syncer<VideoMessage>(url: host + "/users/\(User.myFacebookId())/videos")
    }
    
    @NSManaged var id: NSNumber?
    @NSManaged var title: String?
    @NSManaged var createdAt: String?
    @NSManaged var videoId: String?
    @NSManaged var senderId: NSNumber?
    @NSManaged var recipientId: NSNumber?
    @NSManaged var replyToId: NSNumber?
    // 0 for false, 1 for true
    @NSManaged var watched: NSNumber?
    @NSManaged var saved: NSNumber?
    
    class func allVyncs()->[Vync]{
        let allReplyTos = self.syncer.all().filter("id != 0").sortBy("id", ascending: false).uniq().pluck("replyToId")!
        var vyncs = allReplyTos.reduce([Vync](), combine: {
            initial, replyTo in
            let dict = replyTo as NSDictionary
            let id = dict.valueForKey("replyToId") as NSNumber
            var messages = VideoMessage.syncer.all().filter("replyToId == %@", args: id).sortBy("id", ascending: false).exec()!
            if let lastMessage = messages.last as VideoMessage! {
                if lastMessage.id == 0 {
                    let lastMessage = messages.last
                    messages.removeLast()
                    messages.insert(lastMessage!, atIndex: 0)
                }
            }
            return initial + [Vync(messages: messages)]
        })
        // Handle New Threads That Haven't Been Uploaded
        let newVideos = self.syncer.all().filter("id == 0 AND replyToId == 0").exec()!
        for video in newVideos {
            vyncs.insert(Vync(messages: [video]), atIndex: 0)
        }
        return vyncs
    }

    class func vyncArrays() -> [[Vync]] {
        let allVyncsArray = allVyncs()
        let liveVyncs = allVyncsArray.filter({vync in vync.isDead == false})
        let deadVyncs = allVyncsArray.filter({vync in vync.isDead == true})
        return [liveVyncs, deadVyncs]
    }
    
    class func deadVyncs()->[Vync]{
        return allVyncs().filter({vync in vync.isDead == true})
    }

    class func activeVyncs()->[Vync]{
        return allVyncs().filter({vync in vync.isDead == false})
    }
    
    class func saveTheseVids(videos: [VideoMessage] ,completion: (Void -> Void) = {}) {
        let s3Url = "https://s3-us-west-2.amazonaws.com/telephono/"
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            for message in videos {
                let localUrlString = videoFolder + "/" + message.videoId!
                let localUrl = NSURL(fileURLWithPath: localUrlString) as NSURL!
                let cloudUrl = NSURL(string: s3Url + message.videoId!) as NSURL!
                let localData = NSData(contentsOfURL: localUrl)
                if localData?.length == nil {
                        println("saving video to core data \(message.id)")
                        let data = NSData(contentsOfURL: cloudUrl)
                        data?.writeToFile(localUrlString, atomically: true)
                        message.saved = 1
                        message.watched = 0
                        self.syncer.save()
                } else {
                    println("already there")
                    message.saved = 1
                    self.syncer.save()
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI using completion callback
                println("back on the main thread")
                completion()
            }

        }
    }
    
    class func saveNewVids(completion:(Void->Void) = {}) {
        // Only save vids that are active. Dead vyncs can be saved on demand.
        let vids = activeVyncs().reduce([VideoMessage](), combine: {
            array, vync in
            if !vync.isSaved {
                return array + vync.messages
            } else {
                return array
            }
        })
        if vids.count == 0 {
            completion()
        } else {
            saveTheseVids(vids, completion: completion)
        }
    }
}
