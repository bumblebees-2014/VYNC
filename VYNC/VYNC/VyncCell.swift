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
        
        isWatchedLabel.text = "\u{e001}"
        // DIY Separators
        var frame = self.bounds
        frame.origin.y = frame.size.height - 0.1
        frame.size.height = 0.1
        let separatorView = UIView(frame: frame)
        separatorView.backgroundColor = UIColor.lightGrayColor()
        separatorView.autoresizingMask = UIViewAutoresizing.FlexibleWidth|UIViewAutoresizing.FlexibleTopMargin
        self.contentView.addSubview(separatorView)
        
    }
    
    func setVyncData(vync:Vync) {
        //  Set Title and Length Labels

        titleLabel.text = vync.title
        lengthLabel.text = String(vync.size)
        lengthLabel.textColor = UIColor.blackColor()
        
        //   New vyncs get special color and gesture
        if vync.isDead {
            statusLogo.textColor = UIColor.blackColor()
            lengthLabel.backgroundColor = UIColor.blackColor()
            lengthLabel.textColor = UIColor.whiteColor()
            subTitle.text = "\(vync.date) - Swipe to Delete"
        } else if vync.waitingOnYou {
            statusLogo.textColor = UIColor.VPink()
            lengthLabel.backgroundColor = UIColor.VPink()
            subTitle.text = "\(vync.date) - Swipe to Reply"
        } else {
            subTitle.text = "\(vync.date) - Hold to Play"
            statusLogo.textColor = UIColor.VTeal()
            lengthLabel.backgroundColor = UIColor.VTeal()
        }
        // Unwatched vyncs get a flame
        if vync.unwatched {
            isWatchedLabel.hidden = false
        } else {
            isWatchedLabel.hidden = true
        }
        
        // Not yet uploaded vyncs/Not yet saved vyncs get special background color
        if vync.notUploaded {
            contentView.layer.borderWidth = 0.5
            contentView.layer.borderColor = UIColor.redColor().CGColor
            lengthLabel.layer.borderWidth = 2.0
            lengthLabel.layer.borderColor = UIColor.redColor().CGColor
        } else if vync.isSaved == false {
            statusLogo.textColor = UIColor.orangeColor()
            subTitle.textColor = UIColor.orangeColor()
            titleLabel.transform = CGAffineTransformMakeTranslation(0, -10)
            subTitle.text = "Tap to download"
        } else {
            contentView.layer.borderWidth = 0.0
            lengthLabel.layer.borderWidth = 0.0
        }
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
