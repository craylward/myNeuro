//
//  TremorTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/11/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit

public var TremorTask: ORKOrderedTask {
    var steps = [ORKStep]()
    
    let instructionStep = ORKInstructionStep(identifier: "instruction")
    instructionStep.title = "Tremor Task"
    instructionStep.text = "For this activity, you will be instructed to perform 3 tasks to observe tremor."
    
    steps += [instructionStep]
    
    let restingInstructionStep = ORKInstructionStep(identifier: "restingInstruction")
    restingInstructionStep.title = "Resting Tremor"
    restingInstructionStep.text = "Place your arm on a flat surface at a comfortable height. Relax your arm."
    
    steps += [restingInstructionStep]
    
    let countdownStep_r = ORKCountdownStep(identifier: "countdown_r")
    countdownStep_r.stepDuration = 5
    countdownStep_r.shouldSpeakCountDown = true
    
    steps += [countdownStep_r]
    
    let restingTremorStep = RestingTremorStep(identifier: "restingTremorStep")
    
    restingTremorStep.stepDuration = 10
    restingTremorStep.shouldStartTimerAutomatically = true
    restingTremorStep.shouldVibrateOnStart = true
    restingTremorStep.shouldVibrateOnFinish = true
    restingTremorStep.shouldContinueOnFinish = true
    
    steps += [restingTremorStep]
    
    let posturalInstructionStep = ORKInstructionStep(identifier: "posturalInstruction")
    posturalInstructionStep.title = "Postural Tremor"
    posturalInstructionStep.text = "Stretch your dominant arm out in front of your body parallel to the ground with your palm facing down. Your wrist should be straight and your fingers comfortably separated so that they do not touch each other"
    
    steps += [posturalInstructionStep]

    let countdownStep_p = ORKCountdownStep(identifier: "countdown_p") // NOTE: Used for every tremor step task
    countdownStep_p.stepDuration = 5
    countdownStep_p.shouldSpeakCountDown = true
    
    steps += [countdownStep_p]
    
    let posturalTremorStep = PosturalTremorStep(identifier: "posturalTremorStep")
    
    posturalTremorStep.stepDuration = 10
    posturalTremorStep.shouldStartTimerAutomatically = true
    posturalTremorStep.shouldVibrateOnStart = true
    posturalTremorStep.shouldVibrateOnFinish = true
    posturalTremorStep.shouldContinueOnFinish = true
    
    steps += [posturalTremorStep]
    
    let kineticInstructionStep = ORKInstructionStep(identifier: "kineticInstruction")
    kineticInstructionStep.title = "Kinetic Tremor"
    kineticInstructionStep.text = "With the arm starting from the outstretched position, slowly perform three finger-to-nose maneuvers reaching as far as possible while outstretching the arm."
    
    steps += [kineticInstructionStep]
    
    let countdownStep_k = ORKCountdownStep(identifier: "countdown_k") // NOTE: Used for every tremor step task
    countdownStep_k.stepDuration = 5
    countdownStep_k.shouldSpeakCountDown = true
    
    steps += [countdownStep_k]
    
    let kineticTremorStep = KineticTremorStep(identifier: "kineticTremorStep")
    
    kineticTremorStep.stepDuration = 10
    kineticTremorStep.shouldStartTimerAutomatically = true
    kineticTremorStep.shouldVibrateOnStart = true
    kineticTremorStep.shouldVibrateOnFinish = true
    kineticTremorStep.shouldContinueOnFinish = true
    
    steps += [kineticTremorStep]
    
    //TODO: add summary step
    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Thanks!"
    summaryStep.text = "Your measurements have been recorded"
    steps += [summaryStep]
    
    return ORKOrderedTask(identifier: "TremorTask", steps: steps)
}