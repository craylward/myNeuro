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

class TremorStep: ORKActiveStep {
    
    static func stepViewControllerClass() -> TremorStepViewController.Type {
        return TremorStepViewController.self
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        if identifier.containsString("W") { // If W is in string, this is a watch task
            
        }
        else { // task is running only on the phone
            self.stepDuration = 5
            self.shouldStartTimerAutomatically = true
            self.shouldVibrateOnStart = true
            self.shouldVibrateOnFinish = true
            self.shouldContinueOnFinish = true
            self.recorderConfigurations = [ORKDeviceMotionRecorderConfiguration(identifier: "recorder", frequency: 100)]
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}