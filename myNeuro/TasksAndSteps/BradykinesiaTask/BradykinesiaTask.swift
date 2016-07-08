//
//  BradykinesiaTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 6/29/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit


public var BradykinesiaTask: ORKOrderedTask = {
    let intendedUseDescription = "Finger tapping is a useful method for evaluting Bradykinesia symptoms."
    
    let tappingDuration = NSTimeInterval(5)
    return ORKOrderedTask.twoFingerTappingIntervalTaskWithIdentifier("BradykinesiaTask", intendedUseDescription: intendedUseDescription, duration: tappingDuration, options: ORKPredefinedTaskOption.None) // CHANGED: Duration: 10
}()

public var BradykinesiaTaskWatch: ORKOrderedTask = {
    let intendedUseDescription = "Finger tapping is a useful method for evaluting Bradykinesia symptoms."
    
    let tappingDuration = NSTimeInterval(5)
    return ORKOrderedTask.twoFingerTappingIntervalTaskWithIdentifier("BradykinesiaTaskWatch", intendedUseDescription: intendedUseDescription, duration: tappingDuration, options: ORKPredefinedTaskOption.None) // CHANGED: Duration: 10
}()