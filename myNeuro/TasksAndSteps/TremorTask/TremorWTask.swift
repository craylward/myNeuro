//
//  TremorTaskW.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/11/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit
import CoreMotion
import ResearchKit

public var TremorTaskW: ORKOrderedTask {
    var steps = [ORKStep]()
    
    let instructionStep1 = ORKInstructionStep(identifier: "instruction1")
    instructionStep1.title = "Tremor Task"
    instructionStep1.text = "This activity measures the tremor of your hands in various positions. Find a place where you can sit comfortably for the duration of this task."
    instructionStep1.image = UIImage(named: "tremor1_w")
    steps += [instructionStep1]
    
    let instructionStep2 = ORKInstructionStep(identifier: "instruction2")
    instructionStep2.title = "Tremor Task"
    instructionStep2.text = "You will be instructed to perform 3 tasks to observe tremor. Place the Apple Watch on the wrist of your more affected hand and start the Tremor Task on the watch app."
    instructionStep2.image = UIImage(named: "tremor2_w")
    steps += [instructionStep2]
    
    let connectStep = TremorWConnectStep(identifier: "tremorWConnectStep")
    steps += [connectStep]
    
    let restingInstructionStep = ORKInstructionStep(identifier: "restingInstruction")
    restingInstructionStep.title = "Resting Tremor"
    restingInstructionStep.text = "Place your arm on a flat surface at a comfortable height. Relax your arm."
    steps += [restingInstructionStep]
    
    let countdown_r = ORKCountdownStep(identifier: "countdownResting")
    countdown_r.stepDuration = 5
    countdown_r.shouldSpeakCountDown = true
    steps += [countdown_r]
    
    let restingTremorStep = TremorStepW(identifier: "restingTremorStepW")
    steps += [restingTremorStep]
    
    let posturalInstructionStep = ORKInstructionStep(identifier: "posturalInstruction")
    posturalInstructionStep.title = "Postural Tremor"
    posturalInstructionStep.text = "Stretch your dominant arm out in front of your body parallel to the ground with your palm facing down. Your wrist should be straight and your fingers comfortably separated so that they do not touch each other"
    steps += [posturalInstructionStep]
    
    let countdown_p = ORKCountdownStep(identifier: "countdownPostural")
    countdown_p.stepDuration = 5
    countdown_p.shouldSpeakCountDown = true
    steps += [countdown_p]
    
    let posturalTremorStep = TremorStepW(identifier: "posturalTremorStepW")
    steps += [posturalTremorStep]
    
    let kineticInstructionStep = ORKInstructionStep(identifier: "kineticInstruction")
    kineticInstructionStep.title = "Kinetic Tremor"
    kineticInstructionStep.text = "With the arm starting from the outstretched position, slowly perform three finger-to-nose maneuvers reaching as far as possible while outstretching the arm."
    steps += [kineticInstructionStep]
    
    let countdown_k = ORKCountdownStep(identifier: "countdownKinetic")
    countdown_k.stepDuration = 5
    countdown_k.shouldSpeakCountDown = true
    steps += [countdown_k]
    
    let kineticTremorStep = TremorStepW(identifier: "kineticTremorStepW")
    steps += [kineticTremorStep]

    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Thanks!"
    summaryStep.text = "Your measurements have been recorded"
    steps += [summaryStep]
    
    return ORKOrderedTask(identifier: "TremorTaskWatch", steps: steps)
}