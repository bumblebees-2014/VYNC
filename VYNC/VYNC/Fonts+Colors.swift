//
//  Fonts+Colors.swift
//  VYNC
//
//  Created by Thomas Abend on 3/6/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    class func VPink()->UIColor {
        return UIColor(netHex:0xFFB5C9)
    }
    
    class func VTeal()->UIColor {
        return UIColor(netHex:0x7FF2FF)
    }
    
    class func VBlue()->UIColor {
        return UIColor(netHex:0x73A1FF)
    }
}

extension UIFont {
    
    class func VEgypt() -> UIFont {
        return UIFont(name: "Egypt 22", size: 50)!
    }
}