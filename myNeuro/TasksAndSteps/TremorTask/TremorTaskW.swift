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
    
    let instructionStep = ORKInstructionStep(identifier: "instruction")
    instructionStep.title = "Tremor Task"
    instructionStep.text = "For this activity, you will be instructed to perform 3 tasks to observe tremor. /n/nStart The Tremor Activity on the watch app."
    steps += [instructionStep]
    
    let restingInstructionStep = ORKInstructionStep(identifier: "restingInstruction")
    restingInstructionStep.title = "Resting Tremor"
    restingInstructionStep.text = "Place your arm on a flat surface at a comfortable height. Relax your arm."
    steps += [restingInstructionStep]
    
    let restingTremorStep = TremorStep(identifier: "restingTremorStepW")
    
    steps += [restingTremorStep]
    
    let posturalInstructionStep = ORKInstructionStep(identifier: "posturalInstruction")
    posturalInstructionStep.title = "Postural Tremor"
    posturalInstructionStep.text = "Stretch your dominant arm out in front of your body parallel to the ground with your palm facing down. Your wrist should be straight and your fingers comfortably separated so that they do not touch each other"
    steps += [posturalInstructionStep]
    
    let posturalTremorStep = TremorStep(identifier: "posturalTremorStepW")
    
    steps += [posturalTremorStep]
    
    let kineticInstructionStep = ORKInstructionStep(identifier: "kineticInstruction")
    kineticInstructionStep.title = "Kinetic Tremor"
    kineticInstructionStep.text = "With the arm starting from the outstretched position, slowly perform three finger-to-nose maneuvers reaching as far as possible while outstretching the arm."
    
    steps += [kineticInstructionStep]
    
    let kineticTremorStep = TremorStep(identifier: "kineticTremorStepW")
    
    steps += [kineticTremorStep]
    
    //TODO: add summary step
    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Thanks!"
    summaryStep.text = "Your measurements have been recorded"
    steps += [summaryStep]
    
    return ORKOrderedTask(identifier: "TremorTaskWatch", steps: steps)
}