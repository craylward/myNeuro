//
//  AccelerometerStep.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/11/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import UIKit
import MapKit
import CoreLocation
import CoreMotion

class AccelerometerStep: ORKActiveStep {
    
    
    static func stepViewControllerClass() -> AccelerometerStepViewController.Type {
        return AccelerometerStepViewController.self
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

