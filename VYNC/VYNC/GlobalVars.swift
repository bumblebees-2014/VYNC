//
//  GlobalVars.swift
//  VYNC
//
//  Created by Thomas Abend on 1/30/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// Some publics funcs

// DECLARE SOME GLOBAL VARS

//let standin = "https://s3-us-west-2.amazonaws.com/telephono/IMG_0370.MOV"
let path = NSBundle.mainBundle().pathForResource("VYNC", ofType:"mov")
let standin = NSURL.fileURLWithPath(path!) as NSURL!
let s3Url = "https://s3-us-west-2.amazonaws.com/telephono/"

let docFolderToSaveFiles = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
let fileName = "/videoToSend.MOV"
let pathToFile = docFolderToSaveFiles + fileName

let host = "https://vync-api.herokuapp.com" //"http://192.168.0.6:9393"
var deviceToken = ""


public func signedUp()->Bool{
    if let user = User.syncer.all().filter("isMe == %@", args: 1).exec()?.first as User! {
        return true
    } else {
        return false
    }
}

func myUserId()->Int?{
    if let me = User.syncer.all().filter("isMe == %@", args: 1).exec()!.first as User! {
        return me.id as? Int
        
    } else {
        return nil
    }
}

func me()->User{
    return User.syncer.all().filter("isMe == %@", args: 1).exec()!.first as User!
}

func myFacebookId()->String{
    if let me = User.syncer.all().filter("isMe == %@", args: 1).exec()!.first as User! {
        return me.facebookObjectId as String
        
    } else {
        return ""
    }
    
}

