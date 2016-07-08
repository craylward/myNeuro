//
//  ResultsParser.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/1/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit

struct ResultParser {
    
    static func findFiles(result: ORKTaskResult) -> [NSURL] {
        
        var urls = [NSURL]()
        
        if let resting = result.resultForIdentifier("restingTremorStep") as? ORKStepResult {
            if let recorder = resting.resultForIdentifier("recorder") as? ORKFileResult, let fileUrl = recorder.fileURL {
                    urls.append(fileUrl)
            }
        }
        if let postural = result.resultForIdentifier("posturalTremorStep") as? ORKStepResult {
            if let recorder = postural.resultForIdentifier("recorder") as? ORKFileResult, let fileUrl = recorder.fileURL {
                urls.append(fileUrl)
            }
        }
        if let kinetic = result.resultForIdentifier("kineticTremorStep") as? ORKStepResult {
            if let recorder = kinetic.resultForIdentifier("recorder") as? ORKFileResult, let fileUrl = recorder.fileURL {
                urls.append(fileUrl)
            }
        }
        
        return urls
    }
}