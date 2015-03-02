//
//  VyncCell.swift
//  VYNC
//
//  Created by Thomas Abend on 1/21/15.
//  Copyright (c) 2015 Thomas Abend. All rights reserved.
//

import UIKit


class VyncCell: UITableViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lengthLabel:UILabel!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var statusLogo: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var isWatchedLabel: UILabel!
    @IBOutlet weak var saving: UIActivityIndicatorView!
    
    var isMoving = false
    var isFlipped = false

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
        lengthLabel.layer.masksToBounds = true
        let corner = lengthLabel.layer.frame.width / 2
        lengthLabel.layer.cornerRadius = corner

        
        if self.contentView.frame.height < 70 {
            self.contentView.frame.size = CGSize(width: self.frame.size.width, height: 70)
            self.setNeedsDisplay()
            println(self.frame.height)
            println(self.bounds.height)
            println(self.contentView.frame.height)
        }
        isWatchedLabel.text = "\u{e001}"
    }
    
    func selectCellAnimation() {
        if self.isMoving == false {
            self.isMoving = true
            UIView.animateWithDuration(0.33, delay:0, options: .CurveEaseIn, animations:{
                self.titleLabel.transform = CGAffineTransformMakeTranslation(0, -10)
                self.contentView.layoutIfNeeded()
                }, completion:
                { finished in
                    self.subTitle.textColor = UIColor.blackColor()
                    self.deselectCellAnimation()
                })
        }
    }
    
    func deselectCellAnimation() {
        UIView.animateWithDuration(0.5, delay:2.5, options: .CurveEaseIn, animations:{
            self.titleLabel.transform = CGAffineTransformMakeTranslation(0, 0)
            self.contentView.layoutIfNeeded()
            }, completion:
            { finished in
                self.subTitle.textColor = UIColor.clearColor()
                self.isMoving = false
            }
        )
    }
    
}
