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
        
        if let results = result.results where results.count > 3, let restingTremorResult = results[2] as? ORKStepResult {
            for item in restingTremorResult.results! {
                if let fileresult = item as? ORKFileResult,
                    let fileUrl = fileresult.fileURL {
                    urls.append(fileUrl)
                }
            }
        }
        
        return urls
    }
}