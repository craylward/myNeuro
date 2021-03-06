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
    
    let tappingDuration = TimeInterval(10)
    
    return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: "BradykinesiaTask",
        intendedUseDescription: intendedUseDescription,
        duration: tappingDuration,
        handOptions: .both,
        options: []
    ) // CHANGED: Duration: 10
}()
