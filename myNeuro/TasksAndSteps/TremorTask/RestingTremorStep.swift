//
//  RestingTremorStep.swift
//  myNeuro
//
//  Created by Charlie Aylward on 6/29/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import UIKit
import MapKit
import CoreLocation
import CoreMotion

class RestingTremorStep: ORKActiveStep {
    
    static func stepViewControllerClass() -> PosturalTremorStepViewController.Type {
        return PosturalTremorStepViewController.self
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}