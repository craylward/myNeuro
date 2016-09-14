//
//  BradyWStep.swift
//  myNeuro
//
//  Created by Charlie Aylward on 8/16/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import UIKit
import MapKit
import CoreLocation
import CoreMotion
import WatchConnectivity

class BradyStepW: ORKWaitStep {
    
    static func stepViewControllerClass() -> BradyStepWViewController.Type {
        return BradyStepWViewController.self
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        //self.indicatorType = ORKProgressIndicatorType.ProgressBar
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}