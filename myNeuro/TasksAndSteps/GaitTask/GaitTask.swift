//
//  GaitTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 6/30/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit

public var GaitTask: ORKOrderedTask = {
    let intendedUseDescription = "This task will evaluate your gait and balance."
    
    return ORKOrderedTask.shortWalk(withIdentifier: "GaitTask", intendedUseDescription: intendedUseDescription, numberOfStepsPerLeg: 10, restDuration: TimeInterval(5), options: [])
}()
