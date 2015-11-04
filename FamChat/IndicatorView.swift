//
//  IndicatorView.swift
//  FamChat
//
//  Created by Gerard Heng on 14/8/15.
//  Copyright (c) 2015 gLabs. All rights reserved.
//

import UIKit

public class IndicatorView {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strlabel = UILabel()
    
    public class var shared: IndicatorView {
        struct Static {
            static let instance: IndicatorView = IndicatorView()
        }
        return Static.instance
    }
    
    public func showActivityIndicator(view: UIView) {
        strlabel = UILabel(frame: CGRectMake(0, 0, 150, 30))
        strlabel.text = "Please Wait..."
        strlabel.textColor = UIColor.whiteColor()
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
        
        progressView.frame = CGRectMake(0, 0, 140, 100)
        progressView.center = view.center
        progressView.backgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 80, 80)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(progressView.bounds.width / 2, progressView.bounds.height / 2)
        
        activityIndicator.addSubview(strlabel)
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    public func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

