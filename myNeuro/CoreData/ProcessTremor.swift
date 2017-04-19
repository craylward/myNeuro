//
//  ProcessTremor.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/16/17.
//  Copyright © 2017 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreData

func processTremor(results: [ORKStepResult]) {
    let taskResult = CoreDataStack.createNewTaskResult(type: "Tremor")
    
    for stepResult in results { // Iterate through TaskResult child results (Cast as step results)
        for childResult in stepResult.results! { // Iterate through the child results of the tremor steps (file results)
            if let grandChildResult = childResult as? ORKFileResult {
                print(childResult.identifier)
                let typeResult = stepResult.identifier + "." + grandChildResult.identifier  // i.e "tremor.handInLap.right" + "." + "ac1_acc"
                processFileResult_Tremor(grandChildResult.fileURL!, typeResult, taskResult)
            }
        }
    }
}

func processFileResult_Tremor(_ url: URL, _ type: String, _ taskResult: TaskResult) {
    // Debugging
    print(type)
    //print(CoreDataStack.coreData.privateObjectContext.persistentStoreCoordinator?.persistentStores[0].URL)
    //let string = try? NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
    //print(string) ///   DEV: Prints entire JSON file contents
    
    if let data = try? Data(contentsOf: url, options: []) {
        let json = JSON(data: data)
        for item in json["items"].arrayValue {
            if type.contains("otion"){
                let sample = NSEntityDescription.insertNewObject(forEntityName: "MotionSample", into: CoreDataStack.coreData.privateObjectContext) as! MotionSample
                sample.id = taskResult.id
                sample.user_id = taskResult.user_id
                sample.timeStamp = NSNumber(value: Double(item["timestamp"].stringValue)!)
                sample.type = type
                sample.rX = NSNumber(value: Double(item["rotationRate"]["x"].stringValue)!)
                sample.rY = NSNumber(value: Double(item["rotationRate"]["y"].stringValue)!)
                sample.rZ = NSNumber(value: Double(item["rotationRate"]["z"].stringValue)!)
                sample.aX = NSNumber(value: Double(item["userAcceleration"]["x"].stringValue)!)
                sample.aY = NSNumber(value: Double(item["userAcceleration"]["y"].stringValue)!)
                sample.aZ = NSNumber(value: Double(item["userAcceleration"]["z"].stringValue)!)
                sample.isBacked = 0
            }
            else if type.contains("acc") {
                let sample = NSEntityDescription.insertNewObject(forEntityName: "AccelSample", into: CoreDataStack.coreData.privateObjectContext) as! AccelSample
                sample.id = taskResult.id
                sample.user_id = taskResult.user_id
                sample.timeStamp = NSNumber(value: Double(item["timestamp"].stringValue)!)
                sample.type = type
                sample.aX = (NSNumber(value: Double(item["x"].stringValue)!))
                sample.aY = (NSNumber(value: Double(item["y"].stringValue)!))
                sample.aZ = (NSNumber(value: Double(item["z"].stringValue)!))
                sample.isBacked = 0
            }
            //                CoreDataStack.coreData.savePrivateContext()
            
            /* More Device Motion Attributes */
            // Double(item["attitude"]["x"].stringValue)!)
            // Double(item["attitude"]["y"].stringValue)!)
            // Double(item["attitude"]["z"].stringValue)!)
            // Double(item["attitude"]["w"].stringValue)!)
            // Double(item["gravity"]["x"].stringValue)!)
            // Double(item["gravity"]["y"].stringValue)!)
            // Double(item["gravity"]["z"].stringValue)!)
            // Double(item["magneticField"]["x"].stringValue)!)
            // Double(item["magneticField"]["y"].stringValue)!)
            // Double(item["magneticField"]["z"].stringValue)!)
            // Double(item["magneticField"]["accuracy"].stringValue)!)
        }
    }
}
