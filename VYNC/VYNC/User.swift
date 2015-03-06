//
//  User.swift
//  VYNC
//
//  Created by Thomas Abend on 1/29/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import CoreData
@objc(User)
class User: NSManagedObject {
    
    class var syncer : Syncer<User> {
        return Syncer<User>(url: host + "/users")
    }
    
    
    @NSManaged var username: String
    @NSManaged var id: NSNumber
    @NSManaged var email: String
    @NSManaged var facebookObjectId: String
//  Using like a boolean: 1=true 0=false
    @NSManaged var isMe :NSNumber

    
    class func signedUp()->Bool{
        if let user = User.syncer.all().filter("isMe == %@", args: 1).exec()?.first as User! {
            return true
        } else {
            return false
        }
    }
    
    class func myUserId()->Int?{
        if let me = User.syncer.all().filter("isMe == %@", args: 1).exec()!.first as User! {
            return me.id as? Int
            
        } else {
            return nil
        }
    }
    
    class func me()->User{
        return User.syncer.all().filter("isMe == %@", args: 1).exec()!.first as User!
    }
    
    class func myFacebookId()->String{
        if let me = User.syncer.all().filter("isMe == %@", args: 1).exec()!.first as User! {
            return me.facebookObjectId as String
            
        } else {
            return ""
        }
        
    }
}