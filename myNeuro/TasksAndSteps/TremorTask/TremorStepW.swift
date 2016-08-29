//
//  TremorStep.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/11/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import UIKit
import MapKit
import CoreLocation
import CoreMotion
import WatchConnectivity

class TremorStepW: ORKActiveStep {
    
    static func stepViewControllerClass() -> TremorStepWViewController.Type {
        return TremorStepWViewController.self
    }
    
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        self.stepDuration = 5
        self.shouldStartTimerAutomatically = true
        self.shouldVibrateOnStart = true
        self.shouldVibrateOnFinish = true
        self.shouldContinueOnFinish = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}