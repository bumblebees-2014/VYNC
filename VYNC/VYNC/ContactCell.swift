//
//  ContactCell.swift
//  VYNC
//
//  Created by Thomas Abend on 3/6/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit

class ContactCell : UITableViewCell {

    @IBOutlet weak var profilePicture: FBProfilePictureView!

    @IBOutlet weak var contactImageView: UIImageView!

    @IBOutlet weak var username: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.masksToBounds = true
        let corner = profilePicture.layer.frame.width / 2
        println(corner)
        profilePicture.layer.cornerRadius = CGFloat(5)
    }
    
    func setupContact(user: User) {
        contactImageView.image = UIImage(named: "envelope")
        username.text = "\(user.username)"
        self.profilePicture.profileID = user.facebookObjectId
        UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.profilePicture.alpha = 1
        }, completion: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profilePicture.alpha = 0
        profilePicture.profileID = nil
    }
}