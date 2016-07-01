//
//  RestingTremorStepViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 6/29/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreMotion

class RestingTremorStepViewController: MotionStepViewController
{
    // ORKActiveStepViewController Functions
    static func stepViewControllerClass() -> RestingTremorStepViewController.Type {
        return RestingTremorStepViewController.self
    }   
}