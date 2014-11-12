////
////  Users.swift
////  viewAllUsers
////
////  Created by Apprentice on 11/8/14.
////  Copyright (c) 2014 Apprentice. All rights reserved.
////
//
import Foundation
import UIKit
import CoreData


class UserManager {

    lazy var db : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()

    func asUsers() -> [User] {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        // define our fetch request. We are looking for a list of replyToIDs order of most recently created at.
        let fetchRequest = NSFetchRequest(entityName:"User")
        let ed = NSEntityDescription.entityForName("User",
            inManagedObjectContext: managedContext)!
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "username", ascending: false)]
        var error: NSError?
        // Make the request
        let fetchedResults: [AnyObject]? = managedContext.executeFetchRequest(fetchRequest, error: &error)
        return fetchedResults as [User]
    }
    
    
    
    var mostRecent : User? {
        get {
            var req = NSFetchRequest(entityName: "User")
            req.sortDescriptors = [UserManager.sortBy("userID", ascending: false)]
            req.fetchLimit = 1
            var error: NSError?
            if let db = self.db {
                let results = db.executeFetchRequest(req, error: &error) as [User]
                if results.count == 1 {
                    return results[0]
                }
            }
            return nil
        }
    }
    
    class func sortBy(key: NSString, ascending: Bool) -> NSSortDescriptor {
        return NSSortDescriptor(key: key, ascending: ascending)
    }

    func update() {
        var since = 0
        if let sinceUser = self.mostRecent {
            since = sinceUser.userID as Int
        }
        println("getting all users")
        var data : NSData?
        var request = HTTPTask()
        request.GET("http://chainer.herokuapp.com/allusers",
            parameters: ["since" : since ],
            success: { (response: HTTPResponse) in
                if response.responseObject != nil {
                    if let data = response.responseObject as? NSData {
                        self.addUsersToSql(JSONDecoder(data))
                    }
                }
        })
    }
    
    
    func createUserFromJSON(decoder: JSONDecoder) -> User {
        var user = NSEntityDescription.insertNewObjectForEntityForName("User",
            inManagedObjectContext: self.db!) as User
        user.userID = decoder["id"].integer as Int!
        user.username = decoder["username"].string as String!
        return user
    }
    
    func addUsersToSql(decoderArray: JSONDecoder) {
        for decoder in decoderArray.array! {
            createUserFromJSON(decoder)
        }
        db!.save(nil)
    }
    
}



let userMgr = UserManager()

class globalUser {
    var deviceToken : String? = ""
}

let currentUser = globalUser()