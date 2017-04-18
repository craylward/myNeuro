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

class TremorStepW: ORKWaitStep {//ORKActiveStep {
    
    static func stepViewControllerClass() -> TremorStepWViewController.Type {
        return TremorStepWViewController.self
    }
    
    
    override init(identifier: String) {
        super.init(identifier: identifier)
//        self.stepDuration = 10
//        self.shouldStartTimerAutomatically = false
//        self.shouldVibrateOnStart = true
//        self.shouldVibrateOnFinish = true
//        self.shouldContinueOnFinish = false
//        self.shouldShowDefaultTimer = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
