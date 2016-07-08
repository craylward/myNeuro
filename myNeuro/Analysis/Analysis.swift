//
//  processJSONFiles.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/1/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreData

struct motionData {
    //    var attitude_x: [Double] = []
    //    var attitude_y: [Double] = []
    //    var attitude_z: [Double] = []
    //    var attitude_w: [Double] = []
    var timestamp: [Double] = []
    var rotationRate_x: [Double] = []
    var rotationRate_y: [Double] = []
    var rotationRate_z: [Double] = []
    var userAcceleration_x: [Double] = []
    var userAcceleration_y: [Double] = []
    var userAcceleration_z: [Double] = []
    //    var gravity_x: [Double] = []
    //    var gravity_y: [Double] = []
    //    var gravity_z: [Double] = []
    //    var magneticField_x: [Double] = []
    //    var magneticField_y: [Double] = []
    //    var magneticField_z: [Double] = []
    //    var magneticField_acc: [Double] = []
}

struct bradyData {
    var timestamps: [Double] = []
    var timeIntervals: [Double] = []
    var count: Int?
    var freq: Double?
    var sd: Double?
    var avg: Double?
    var min: Double?
    var max: Double?
}

func processTremorFiles(urls: [NSURL]) {
    
    // MARK: Parse JSON files
    guard urls.count == 3 else {     // Should have 3 urls for: 1. Resting Tremor 2. Postural Tremor 3. Kinetic Tremor
        print("3 JSONs not produced by tremor task")
        return
    }
    
    var resting = motionData()
    var postural = motionData()
    var kinetic = motionData()
    //process resting
    resting = parseDeviceMotion(urls[0])
    //process postural
    postural = parseDeviceMotion(urls[1])
    //process kinetic
    kinetic = parseDeviceMotion(urls[2])
    
    // MARK: Data Analysis
    
}

func processBradykinesia(result: ORKCollectionResult) {
    
    // MARK: Parse Bradykinesia task data
    guard result is ORKTaskResult else {
        print("Bradykinesia task did not produce proper result type")
        return
    }
    var data = bradyData()
    guard let stepResult = result.resultForIdentifier("tapping") as! ORKCollectionResult? else {
        print("No step result with the identifier 'tapping' found")
        return
    }
    
    let fileResult = stepResult.resultForIdentifier("accelerometer")
    let tapResult = stepResult.resultForIdentifier("tapping") as! ORKTappingIntervalResult
    
    data.timestamps = tapResult.samples!.map { tappingSample in
        return tappingSample.timestamp
    }
    
    var timeIntervals = data.timestamps
    var index = timeIntervals.count - 1
    while index > 0 {                                   // start at the last timestamp entry and work toward 0 index
        timeIntervals[index] -= timeIntervals[index-1]  // subtract time from preceding timestamp from current timestamp
        index -= 1                                      // iterate
    }
    timeIntervals.removeFirst()                         // remove the first time interval (0) to get rid of the 0.00 time from initial tap
    data.timeIntervals = timeIntervals
    data.count = timeIntervals.count
    data.freq = frequency(timeIntervals, duration: tappingDuration)
    data.sd = standardDeviation(timeIntervals)
    data.avg = average(timeIntervals)
    data.min = timeIntervals.minElement()!
    data.max = timeIntervals.maxElement()!
    
    // MARK: Save data
    var bradyResult = [NSManagedObject]()
    
    // MARK: Data Analysis
    
}

func parseDeviceMotion(url: NSURL) -> motionData {
    //    DEV: Prints entire JSON file contents
    //    let string = try? NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
    //    print(string)
    var deviceMotion = motionData()
    if let data = try? NSData(contentsOfURL: url, options: []) {
        let json = JSON(data: data)
        
        for item in json["items"].arrayValue {
            // deviceMotion.attitude_x.append(Double(item["attitude"]["x"].stringValue)!)
            // deviceMotion.attitude_y.append(Double(item["attitude"]["y"].stringValue)!)
            // deviceMotion.attitude_z.append(Double(item["attitude"]["z"].stringValue)!)
            // deviceMotion.attitude_w.append(Double(item["attitude"]["w"].stringValue)!)
            deviceMotion.timestamp.append(Double(item["timestamp"].stringValue)!)
            deviceMotion.rotationRate_x.append(Double(item["rotationRate"]["x"].stringValue)!)
            deviceMotion.rotationRate_y.append(Double(item["rotationRate"]["y"].stringValue)!)
            deviceMotion.rotationRate_z.append(Double(item["rotationRate"]["z"].stringValue)!)
            deviceMotion.userAcceleration_x.append(Double(item["userAcceleration"]["x"].stringValue)!)
            deviceMotion.userAcceleration_y.append(Double(item["userAcceleration"]["y"].stringValue)!)
            deviceMotion.userAcceleration_z.append(Double(item["userAcceleration"]["z"].stringValue)!)
            // deviceMotion.gravity_x.append(Double(item["gravity"]["x"].stringValue)!)
            // deviceMotion.gravity_y.append(Double(item["gravity"]["y"].stringValue)!)
            // deviceMotion.gravity_z.append(Double(item["gravity"]["z"].stringValue)!)
            // deviceMotion.magneticField_x.append(Double(item["magneticField"]["x"].stringValue)!)
            // deviceMotion.magneticField_y.append(Double(item["magneticField"]["y"].stringValue)!)
            // deviceMotion.magneticField_z.append(Double(item["magneticField"]["z"].stringValue)!)
            // deviceMotion.magneticField_acc.append(Double(item["magneticField"]["accuracy"].stringValue)!)
        }
    }
    return deviceMotion
}

// Format of JSON
//   Optional({
//      "items":[{"attitude":{"y":0.0609771140960272896,"w":0.8165446439237274624,"z":-0.00009291811398977849344,"x":0.5740528088967228416},
//              "timestamp":23693.64129112499712,
//              "rotationRate":{"x":-0.02606136165559291904,"y":-0.02979453653097152512,"z":-0.02649024501442909184},
//              "userAcceleration":{"x":-0.016878303140401840128,"y":-0.006516824010759591936,"z":0.06510348618030548992},
//              "gravity":{"x":0.09968775510787964928,"y":-0.937468171119689728,"z":-0.3334903419017792512},
//              "magneticField":{"y":0,"z":0,"x":0,"accuracy":-1}
//              }, ...
//              ]
//          })