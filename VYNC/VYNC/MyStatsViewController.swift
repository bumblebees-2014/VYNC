//
//  MyStatsViewController.swift
//  VYNC
//
//  Created by Thomas Abend on 2/12/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit

class MyStatsViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var numVyncsSent: UILabel!
    @IBOutlet weak var numVyncsRecieved: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = User.me().username
        let sent = VideoMessage.syncer.all().filter("senderId == %@", args: User.myUserId()!).exec()!
        let recieved = VideoMessage.syncer.all().filter("recipientId == %@", args: User.myUserId()!).exec()!
        numVyncsRecieved.text = "\(recieved.count)"
        numVyncsSent.text = "\(sent.count)"
    }
}