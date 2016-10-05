//
//  Skin.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/26/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit

// Button skin for joining the study
class JoinStudyButton: UIButton {
    required init(coder aDecoder: (NSCoder!)) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = 5.0;
        self.layer.borderColor = self.tintColor.CGColor
        self.layer.borderWidth = 1
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        self.setBackgroundColor(self.tintColor, forState: .Highlighted)
        self.clipsToBounds = true
        
    }
    
    override var enabled: Bool {
        didSet {
            switch enabled {
            case true:
                self.layer.borderColor = self.tintColor.CGColor
                self.setTitleColor(self.tintColor, forState: .Normal)
            case false:
                layer.borderColor = UIColor.lightGrayColor().CGColor
                self.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
            }
        }
    }
}

// UPDATE: NO LONGER NEEDED AS ELIGIBILITY USES SEGMENTED CONTROL
class EligibilityButton: UIButton {
    required init(coder aDecoder: (NSCoder!)) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.setBackgroundColor(self.tintColor, forState: .Selected)
        self.clipsToBounds = true
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, forState: forState)
    }
}