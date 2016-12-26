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
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.borderWidth = 1
        self.layer.backgroundColor = UIColor.white.cgColor
        self.setTitleColor(UIColor.white, for: .highlighted)
        self.setBackgroundColor(self.tintColor, forState: .highlighted)
        self.clipsToBounds = true
        
    }
    
    override var isEnabled: Bool {
        didSet {
            switch isEnabled {
            case true:
                self.layer.borderColor = self.tintColor.cgColor
                self.setTitleColor(self.tintColor, for: UIControlState())
            case false:
                layer.borderColor = UIColor.lightGray.cgColor
                self.setTitleColor(UIColor.lightGray, for: .disabled)
            }
        }
    }
}

// UPDATE: NO LONGER NEEDED AS ELIGIBILITY USES SEGMENTED CONTROL
class EligibilityButton: UIButton {
    required init(coder aDecoder: (NSCoder!)) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: .selected)
        self.setBackgroundColor(self.tintColor, forState: .selected)
        self.clipsToBounds = true
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}
