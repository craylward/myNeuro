//
//  BradyWTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 8/16/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit
import CoreMotion
import ResearchKit

public var BradyTaskW: ORKOrderedTask {
    var steps = [ORKStep]()
    
    let instructionStep1 = ORKInstructionStep(identifier: "instruction1")
    instructionStep1.title = "BradykinesiaTask"
    instructionStep1.text = "This activity measures your tapping speed."
    steps += [instructionStep1]
    
    let instructionStep2 = ORKInstructionStep(identifier: "instruction2")
    instructionStep2.title = "Tremor Task"
    instructionStep2.text = "You will perform a tapping task on the watch. Place the Apple Watch on the wrist of your more affected hand and start the Finger Tapping activity on the watch app."
    instructionStep2.image = UIImage(named: "tremor2_w")
    steps += [instructionStep2]
    
    let watchStep = WatchConnectStep(identifier: "watchConnectStep")
    steps += [watchStep]
    
    let bradyStepW = BradyWStep(identifier: "bradyStepW")
    steps += [bradyStepW]
    
    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Thanks!"
    summaryStep.text = "Your measurements have been recorded"
    steps += [summaryStep]
    
    return ORKOrderedTask(identifier: "TremorTaskWatch", steps: steps)
}