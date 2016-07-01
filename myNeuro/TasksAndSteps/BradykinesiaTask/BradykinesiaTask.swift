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
    
    
    return ORKOrderedTask.twoFingerTappingIntervalTaskWithIdentifier("BradykinesiaTask", intendedUseDescription: intendedUseDescription, duration: tappingDuration, options: ORKPredefinedTaskOption.None) // CHANGED: Duration: 10
}()