//
//  WatchTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/4/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit

public var WatchTask: ORKOrderedTask {
    var steps = [ORKStep]()
    
    let instructionStep = ORKInstructionStep(identifier: "instruction")
    instructionStep.title = "Watch Task"
    instructionStep.text = "Please listen to a randomized music clip for 30 seconds, and we'll record your heart rate."
    
    steps += [instructionStep]
    
    return ORKOrderedTask(identifier: "WatchTask", steps: steps)
}
