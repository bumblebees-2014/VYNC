//
//  LoginViewController.swift
//  VYNC
//
//  Created by Thomas Abend on 2/2/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController {
    
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var pageImage: UIImageView!
    var pageIndex: Int!
    var color: String!
    var titleString : String!
    var imageString : String!
    
    override func viewDidLoad() {
        if color == nil {
            color = "Red"
        }
        if color == "Red" {
            self.view.backgroundColor = UIColor.VYNCTeal()
        } else if color == "Green" {
            self.view.backgroundColor = UIColor.VYNCBlue()
        } else if color == "Blue" {
            self.view.backgroundColor = UIColor.VYNCPink()
        }
        pageLabel.text = titleString!
        pageImage.image = UIImage(named: imageString!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}