//
//  WatchViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 4/20/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import WatchKit
import CoreMotion

class WatchStepViewController: ORKActiveStepViewController
{
    override func start() {
        super.start()
        
        if let step = step as? WatchStep {
            do {
                
            } catch {}
        }
    }
    
    override func stepDidFinish() {
        super.stepDidFinish()
    }
    
}