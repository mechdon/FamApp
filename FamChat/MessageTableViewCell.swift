//
//  MessageTableViewCell.swift
//  FamChat
//
//  Created by Gerard Heng on 18/9/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit


class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var datetimeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var bubbleImage: UIImageView!
    
    override func layoutSubviews() {
       super.layoutSubviews()
    
        self.datetimeLabel.frame = CGRectMake(113.0, 14.0, 117.0, 21.0)
        self.datetimeLabel.font = UIFont.systemFontOfSize(9)
        self.addSubview(self.datetimeLabel)
        
        self.nameLabel.frame = CGRectMake(8.0, 78.0, 71.0, 21.0)
        self.nameLabel.font = UIFont.systemFontOfSize(9)
        self.nameLabel.textAlignment = .Center
        self.addSubview(self.nameLabel)
        
        if self.userImage.image != nil {
            self.userImage.frame = CGRectMake(14.0, 21.0, 58.0, 58.0)
            self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2
            self.userImage.image = self.userImage.image
            self.userImage.clipsToBounds = true
            self.addSubview(self.userImage)
        }
        
        self.messageLabel.preferredMaxLayoutWidth = 150
        //self.messageLabel = UILabel(frame: CGRectMake(130.0, 35.0, CGRectGetWidth(self.frame) - 20, 5))
        self.messageLabel.frame = CGRectMake(130.0, 35.0, CGRectGetWidth(self.frame) - 20, 5)
        self.messageLabel.font = UIFont.systemFontOfSize(15)
        self.messageLabel.numberOfLines = 0
        self.messageLabel.sizeToFit()
        self.addSubview(self.messageLabel)
        
        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        var vW: CGFloat = 0.0
                
        viewHeight = CGRectGetMaxY(self.messageLabel.frame) * 0.70
        vW = CGRectGetWidth(self.messageLabel.frame) + CGRectGetMinX(self.messageLabel.frame)/2
                
        if vW > 200 {
           viewWidth = 200
        } else {
           viewWidth = vW
        }
                
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), viewWidth, viewHeight)
        self.bubbleImage = UIImageView(frame: CGRectMake(100.0, 30.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)))
        self.bubbleImage.image = UIImage(named: "bubble")?.resizableImageWithCapInsets(UIEdgeInsetsMake(17, 17, 17, 17))
        self.addSubview(self.bubbleImage)
        self.sendSubviewToBack(self.bubbleImage)
        
    }
    
     
    
}
