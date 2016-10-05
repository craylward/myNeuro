//
//  AccelerometerTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/11/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit

public var AccelerometerTask: ORKOrderedTask {
    var steps = [ORKStep]()
    
    let instructionStep = ORKInstructionStep(identifier: "instruction")
    instructionStep.title = "Accelerometer Task"
    instructionStep.text = "Move the phone around to gather accelerometer data"
    
    steps += [instructionStep]
    
    let countdownStep = ORKCountdownStep(identifier: "countdown")
    countdownStep.stepDuration = 5
    countdownStep.shouldSpeakCountDown = true
    
    steps += [countdownStep]
    
    let accelerometerStep = AccelerometerStep(identifier: "accelerometerStep")

    accelerometerStep.stepDuration = 10
    accelerometerStep.shouldStartTimerAutomatically = true
    accelerometerStep.shouldVibrateOnStart = true
    accelerometerStep.shouldVibrateOnFinish = true
    accelerometerStep.shouldContinueOnFinish = true
    
    steps += [accelerometerStep]
    
    //TODO: add summary step
    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Thanks!"
    summaryStep.text = "Your answers have been recorded"
    steps += [summaryStep]
    
    return ORKOrderedTask(identifier: "AccelerometerTask", steps: steps)
}