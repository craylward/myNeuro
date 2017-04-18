//
//  ProcessGait.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/16/17.
//  Copyright © 2017 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreData

func processGait(results: [ORKStepResult]) {
    let taskResult = CoreDataStack.createNewTaskResult(type: "Gait")
    
    for stepResult in results { // Iterate through TaskResult child results (Cast as step results)
        for fileResult in stepResult.results as! [ORKFileResult] { // Iterate through the child results of the gait steps (file results)
            let typeResult = stepResult.identifier + "." + fileResult.identifier  // i.e "walking.outbound" + "." + "pedometer"
            processFileResult(fileResult.fileURL!, typeResult, taskResult)
        }
    }
}

func processFileResult(_ url: URL, _ type: String, _ taskResult: TaskResult) {
    // Debugging
    print(type)
    //print(CoreDataStack.CoreDataStack.coreData.privateObjectContext.persistentStoreCoordinator?.persistentStores[0].URL)
    //let string = try? NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
    //print(string) ///   DEV: Prints entire JSON file contents
    
    if let data = try? Data(contentsOf: url, options: []) {
        let json = JSON(data: data)
        for item in json["items"].arrayValue {
            if type.contains("pedometer") {
                let sample = NSEntityDescription.insertNewObject(forEntityName: "WalkingSample", into: CoreDataStack.coreData.privateObjectContext) as! WalkingSample
                sample.distance = NSNumber(value: Double(item["distance"].stringValue)!)
                sample.numberOfSteps = NSNumber(value: Int(item["numberOfSteps"].stringValue)!)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SSSS"
                let startDate = dateFormatter.date(from: item["startDate"].stringValue)
                let endDate = dateFormatter.date(from: item["endDate"].stringValue)
                sample.duration = NSNumber(value: Double(endDate!.timeIntervalSince(startDate!)))
                sample.type = type
                sample.id = taskResult.id
                sample.user_id = taskResult.user_id
                sample.isBacked = 0
                print("test")
            }
            else if type.contains("otion"){
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
        }
    }
}
