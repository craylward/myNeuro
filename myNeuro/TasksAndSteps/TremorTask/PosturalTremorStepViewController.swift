//
//  PosturalTremorStepViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/4/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreMotion

class PosturalTremorStepViewController: ORKActiveStepViewController
{
    static func stepViewControllerClass() -> PosturalTremorStepViewController.Type {
        return PosturalTremorStepViewController.self
    }
}