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

class Vync {
    var messages : [VideoMessage]
    var notUploaded: Bool {
        get {
            return self.messages.first!.id == 0
        }
    }
    var waitingOnYou: Bool {
        get {
            if let mostRecentRecipient = self.messages.first {
                return myUserId() == mostRecentRecipient.recipientId
            } else {
                return false
            }  
        }
    }
    
    var isSaved: Bool {
        return messages.filter({video in video.saved == 0}).count == 0
    }
    
    var unwatched: Bool {
        get {
            return self.messages.first!.watched == 0 || self.messages.first!.watched == nil
        }
        set {
            self.messages.first!.watched = 1
            VideoMessage.syncer.save()
        }
    }
    
    init(messages: [VideoMessage]){
        self.messages = messages
    }

    func size()-> String{
        return "\(self.messages.count)"
    }
    
    func videoItems()->[AVPlayerItem]{
        if waitingOnYou {
            let firstMessage = self.messages.first!
            let firstMessageUrl = NSURL.fileURLWithPath(docFolderToSaveFiles + "/" + firstMessage.videoId!) as NSURL!
            let firstItem = AVPlayerItem(URL: firstMessageUrl)
            let standinItem = AVPlayerItem(URL: standin)
            return [firstItem, standinItem]
            
        } else {
            return self.messages.map({
                message in
                AVPlayerItem(URL: (NSURL.fileURLWithPath(docFolderToSaveFiles + "/" + message.videoId!) as NSURL!))
            })
        }
    }

    func replyToId()->Int {
        if let first = self.messages.last {
            return first.replyToId as Int
        } else {
            return 0
        }
    }
    
    func mostRecent()->String{
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
    
    func dead()->Bool {
        if let createdAt = messages.first?.createdAt {
            if let date = createdAtToNSDate(createdAt) as NSDate! {
               return date.isAtLeastTwoDaysAgo
            }
            else {
                return false
            }
        } else {
            return false
        }
    }

    func title()->String {
        if self.messages.count != 0 {
        if let video = messages.last as VideoMessage! {
            if let title = video.title as String! {
                return title
            } else {
                return "TODO"
            }
        } else {
            return "ToDo"
        }
        } else {return "oops"}
    }
    
    func usersList()->[String]{
        return self.messages.map({
            message in
            self.findUsername(message.senderId as Int)
        })
    }
    
    func findUsername(userId:Int)->String{
        if let user = User.syncer.all().find(userId) as User! {
            return user.username
        } else {
            return "Fail :("
        }
    }
    
}
