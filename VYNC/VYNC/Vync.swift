//
//  Vync.swift
//  VYNC
//
//  Created by Thomas Abend on 1/25/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import CoreData
import AVFoundation

struct Vync {
    
    var messages : [VideoMessage]
    init(messages: [VideoMessage]){
        self.messages = messages
    }
    
    var notUploaded: Bool {
        return self.messages.first!.id == 0
    }
    var waitingOnYou: Bool {
        if let mostRecentRecipient = self.messages.first?.recipientId {
            return User.myUserId() == mostRecentRecipient
        } else {
            return false
        }
    }
    
    var isSaved: Bool {
        return messages.filter({video in video.saved == 1}).count == messages.count
    }
    
    var unwatched: Bool {
        return self.messages.first!.watched == 0 || self.messages.first!.watched == nil
    }

    var size: String {
        return "\(self.messages.count)"
    }
    
    var replyToId: Int {
        if let initialMessage = self.messages.last {
            return initialMessage.replyToId as Int
        } else {
            return 0
        }
    }
    
    var date: String {
        if let createdAt = messages.first?.createdAt {
            if let date = createdAtToNSDate(createdAt) as NSDate! {
                return "\(date.mediumDateString)"
            } else {
                return "Infinity years ago"
            }
        } else {
            
            return "Just now"
        }
    }
    
    var isDead: Bool {
        if let createdAt = messages.first?.createdAt {
            if let date = createdAtToNSDate(createdAt) as NSDate! {
                let daysInterval = NSDate.today().timeIntervalSinceDate(date) / 86400
                return daysInterval >= 2
            }
        }
        return false
    }
    
    var title: String {

        if let video = messages.last as VideoMessage! {
            if let title = video.title as String! {
                if title == "" {
                    return "N/A"
                } else if countElements(title) > 15 {
                    return title[0...15]
                } else {
                    return title
                }
            }
        }
        return "Title Error"
    }
    
    var usersList: String {
        if waitingOnYou && !isDead {
            return "Forward to see who is on this VYNC"
        } else {
            let userNames = self.messages.map({
                message in
                "\(self.findUsername(message.senderId as Int))"
            })
            return "Users on this vync:\n" + ("\n").join(userNames)
        }
    }
    
    func videoItems()->[AVPlayerItem]{
        if waitingOnYou && !isDead {
            let firstMessage = self.messages.first!
            let firstMessageUrl = NSURL.fileURLWithPath(videoFolder + "/" + firstMessage.videoId!) as NSURL!
            let firstItem = AVPlayerItem(URL: firstMessageUrl)

            let standinPath = NSBundle.mainBundle().pathForResource("VYNC", ofType:"mov")!
            let standinURL = NSURL.fileURLWithPath(standinPath)
            let standinItem = AVPlayerItem(URL: standinURL)
            
            return [firstItem, standinItem]
            
        } else {
            return self.messages.map({
                message in
                AVPlayerItem(URL: (NSURL.fileURLWithPath(videoFolder + "/" + message.videoId!) as NSURL!))
            })
        }
    }
    
    func createdAtToNSDate(string:String)->NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let secondFormatter = NSDateFormatter()
        secondFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss 'UTC'"
        if let date = formatter.dateFromString(string) as NSDate! {
            return date
        } else if let date = secondFormatter.dateFromString(string) as NSDate! {
            return date
        } else {
            return nil
        }
    }
    
    func findUsername(userId:Int)->String{
        if let user = User.syncer.all().find(userId) as User! {
            return user.isMe == 1 ? "You" : user.username
        } else {
            return "Fail :("
        }
    }
    
    func markAsWatched() {
        self.messages.first!.watched = 1
        VideoMessage.syncer.save()
    }
    
    func delete() {
        let fm = NSFileManager()
        for message in self.messages {
            let localUrlString = videoFolder + "/" + message.videoId!
            fm.removeItemAtPath(localUrlString, error: nil)
            VideoMessage.syncer.delete(message)
        }
        VideoMessage.syncer.save()
    }
    
}
