//  VideosMessages.swift
//  viewAllUsers
//
//  Created by Apprentice on 11/9/14.
//  Copyright (c) 2014 Apprentice. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Videos {
    
    lazy var db : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()
    
    var mostRecent : VideoMessage? {
        get {
            var req = NSFetchRequest(entityName: "VideoMessage")
            req.sortDescriptors = [Videos.sortBy("messageID", ascending: false)]
            req.fetchLimit = 1
            var error: NSError?
            if let db = self.db {
                let results = db.executeFetchRequest(req, error: &error) as [VideoMessage]
                if results.count == 1 {
                    return results[0]
                }
            }
            return nil
        }
    }
    
    func asChains() -> [[VideoMessage]] {
        // declaring this at the top...using it below in the for loop and returning it.
        var chains = [[VideoMessage]]()
        
        // set the App delegate and managed context  before query.
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        // define our fetch request. We are looking for a list of replyToIDs order of most recently created at.
        let fetchRequest = NSFetchRequest(entityName:"VideoMessage")
        let ed = NSEntityDescription.entityForName("VideoMessage",
            inManagedObjectContext: managedContext)!
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = ["replyToID"]
        var error: NSError?
        // Make the request
        let fetchedResults: [AnyObject]? = managedContext.executeFetchRequest(fetchRequest, error: &error)
        // if the query worked as expected
        if let results = fetchedResults as? [VideoMessage] {
            // set data structures. Chain will be passed around and manipulated, we will be building into chains.
            var chain = [VideoMessage]()
            for video in results {
                // If it's the first chain or it's on the same chain as the previous video add it to chain
                if chain.isEmpty || chain.last!.replyToID == video.replyToID {
                    chain.append(video)
                } else {
                // Add the chain to chains and reset chain.
                    chains.append(chain)
                    chain = [video]
                }
            }
            // Got to get that last one.
            if chain.isEmpty == false {
                chains.append(chain)
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        return chains
    }
    
    
    class func sortBy(key: NSString, ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: key, ascending: ascending)
    }
    
    func update() {
        var since = 0
        if let sinceVid = self.mostRecent {
            since = sinceVid.messageID as Int
        }
        
        var data : NSData?
        var request = HTTPTask()
        var deviceId = UIDevice.currentDevice().identifierForVendor.UUIDString
        request.GET("http://chainer.herokuapp.com/videomessages/\(deviceId)/all",
            parameters: ["since" : since],
            success: { (response: HTTPResponse) in
                if response.responseObject != nil {
                    if let data = response.responseObject as? NSData {
                        self.addVideosToSql(JSONDecoder(data))
                    }
                }
        })
    }
    
    func createVideoFromJSON(decoder: JSONDecoder) -> VideoMessage {
        var vid = NSEntityDescription.insertNewObjectForEntityForName("VideoMessage",
            inManagedObjectContext: self.db!) as VideoMessage
        vid.messageID = decoder["id"].integer as Int!
        vid.replyToID = decoder["reply_to_id"].integer as Int!
        vid.senderID =  decoder["sender_id"].integer as Int!
        vid.recipientID = decoder["recipient_id"].integer as Int!
        vid.videoID = decoder["video_id"].string as String!
        vid.createdAt = decoder["created_at"].string as String!
        return vid
    }
    
    func addVideosToSql(decoderArray: JSONDecoder) {
        for decoder in decoderArray.array! {
            createVideoFromJSON(decoder)
        }
        db!.save(nil)
    }

}

