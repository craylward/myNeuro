//
//  ProcessBradykinesia.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/16/17.
//  Copyright © 2017 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreData

func processBradykinesia(results: [ORKStepResult]) {
    let taskResult = CoreDataStack.createNewTaskResult(type: "Bradykinesia")
    
    for stepResult in results {
        for childResult in stepResult.results! {
            if let grandChildResult = childResult as? ORKTappingIntervalResult {
                print(childResult.identifier)
                grandChildResult.samples != nil ? processTappingResult(grandChildResult, taskResult) : print("Skipped \(childResult.identifier)")
            }
            else if let grandChildResult = childResult as? ORKFileResult {
                if grandChildResult.identifier.contains("accelerometer"){
                    let typeResult = "bradykinesia.\(childResult.identifier).acc"
                    processFileResult(grandChildResult.fileURL!, typeResult, taskResult)
                }
            }
        }
    }
}

func processTappingResult(_ tapResult: ORKTappingIntervalResult, _ taskResult: TaskResult) {
    
    for tappingSample in tapResult.samples! {
        let sample = NSEntityDescription.insertNewObject(forEntityName: "TappingSample", into: CoreDataStack.coreData.privateObjectContext) as! TappingSample
        sample.id = taskResult.id
        sample.user_id = taskResult.user_id
        sample.isBacked = 0
        sample.timeStamp = NSNumber(value: tappingSample.timestamp)
        sample.loc_x = NSNumber(value: Double(tappingSample.location.x))
        sample.loc_y = NSNumber(value: Double(tappingSample.location.y))
        sample.duration = NSNumber(value: Double(tappingSample.duration))
        sample.hand = tapResult.identifier
        if tappingSample.buttonIdentifier == ORKTappingButtonIdentifier.left {
            sample.button_id = "left"
        }
        else if tappingSample.buttonIdentifier == ORKTappingButtonIdentifier.right {
            sample.button_id = "right"
        }
        else {
            sample.button_id = "none"
        }
        //            CoreDataStack.coreData.savePrivateContext()
    }
}

func processFileResult_Bradykinesia(_ url: URL, _ type: String, _ taskResult: TaskResult) {
    // Debugging
    print(type)
    //print(CoreDataStack.coreData.privateObjectContext.persistentStoreCoordinator?.persistentStores[0].URL)
    //let string = try? NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
    //print(string) ///   DEV: Prints entire JSON file contents
    
    if let data = try? Data(contentsOf: url, options: []) {
        let json = JSON(data: data)
        for item in json["items"].arrayValue {
            let sample = NSEntityDescription.insertNewObject(forEntityName: "AccelSample", into: CoreDataStack.coreData.privateObjectContext) as! AccelSample
            sample.id = taskResult.id
            sample.user_id = taskResult.user_id
            sample.timeStamp = NSNumber(value: Double(item["timestamp"].stringValue)!)
            sample.type = type
            sample.aX = (NSNumber(value: Double(item["x"].stringValue)!))
            sample.aY = (NSNumber(value: Double(item["y"].stringValue)!))
            sample.aZ = (NSNumber(value: Double(item["z"].stringValue)!))
            sample.isBacked = 0
            //                CoreDataStack.coreData.savePrivateContext()
        }
    }
}
