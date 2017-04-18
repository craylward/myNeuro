//
//  Math.swift
//  myNeuro
//
//  Created by Charlie Aylward on 4/6/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreData
import Accelerate


func standardDeviation(_ arr : [Double]) -> Double
{
    let avg = average(arr)
    let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, +)
    return sqrt(sumOfSquaredAvgDiff / (Double(arr.count)-1))
}

func frequency(_ arr : [Double], duration : TimeInterval) -> Double
{
    let count = Double(arr.count)
    let freq = count/duration
    return freq
}

func average(_ arr : [Double]) -> Double
{
    let count = Double(arr.count)
    let sum = arr.reduce(0, +)
    let avg = sum/count
    return avg
}

func bradyAnalysis (_ resultId: Int){
    let coreData = CoreDataStack.coreData
    
    //fetch bradykinesia results
    let tappingSamplesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TappingSample")
    tappingSamplesRequest.predicate = NSPredicate(format: "id == \(resultId)")
    var tappingSamples: [TappingSample]?
    do {
        tappingSamples = try coreData.privateObjectContext.fetch(tappingSamplesRequest) as? [TappingSample]
    } catch {
        let fetchError = error as NSError
        print(fetchError)
    }
    
    guard tappingSamples!.count > 0 else { print("No results found"); return }
    
    var tapIntervals = tappingSamples!.map{$0.timeStamp as! TimeInterval}
    var index = tapIntervals.count - 1
    while index > 0 {                                   // start at the last timestamp entry and work toward 0 index
        tapIntervals[index] -= tapIntervals[index-1]  // subtract time from preceding timestamp from current timestamp
        index -= 1                                      // iterate
    }
    tapIntervals.removeFirst()                         // remove the first time interval (0) to get rid of the 0.00 time from initial tap
    //        let count = tapIntervals.count
    //        let freq = frequency(tapIntervals, duration: tappingDuration)
    //        let sd = standardDeviation(tapIntervals)
    //        let avg = average(tapIntervals)
    //        let min = tapIntervals.minElement()!
    //        let max = tapIntervals.maxElement()!
    
    let tapDurations = tappingSamples!.map{$0.duration as! Double}
    
    let analysis = NSEntityDescription.insertNewObject(forEntityName: "BradyAnalysis", into: coreData.privateObjectContext) as! BradyAnalysis
    analysis.brady_cvDuration = NSNumber(value: standardDeviation(tapDurations)/average(tapDurations))
    analysis.brady_intervalAvg = NSNumber(value: average(tapIntervals))
    analysis.date = Date()
    analysis.user_id = tappingSamples!.first!.user_id
    
    // Optional: Code to sort the timestamps from earliest to latest. For unknown reason, if buttons are tapped in rapid succession, the timestamp order may be off.
    // data.timestamps.sortInPlace(<)
    
    do {
        try coreData.privateObjectContext.save()
    } catch {
        fatalError("Failure to save context: \(error)")
    }
}

func tremorAnalysis (_ resultId: Int){
    let coreData = CoreDataStack.coreData
    
    //fetch bradykinesia results
    let tremorSamplesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MotionSample")
    tremorSamplesRequest.predicate = NSPredicate(format: "id == \(resultId)")
    
    var tremorSamples: [MotionSample]?
    do {
        tremorSamples = try coreData.privateObjectContext.fetch(tremorSamplesRequest) as? [MotionSample]
    } catch {
        let fetchError = error as NSError
        print(fetchError)
    }
    
    guard tremorSamples!.count > 0 else { print("No results found"); return }
    
    let analysis = NSEntityDescription.insertNewObject(forEntityName: "TremorAnalysis", into: coreData.privateObjectContext) as! TremorAnalysis
    analysis.date = Date()
    analysis.user_id = tremorSamples!.first!.user_id
    //analysis.tremor_r_K =
    //analysis.tremor_r_RMS =
    //analysis.tremor_p_K =
    //analysis.tremor_p_RMS =
    //analysis.tremor_k_K =
    //analysis.tremor_k_RMS =
    
    do {
        try coreData.privateObjectContext.save()
    } catch {
        fatalError("Failure to save context: \(error)")
    }
}

func gaitAnalysis (_ resultId: Int){
    let coreData = CoreDataStack.coreData
    
    //fetch bradykinesia results
    //let gaitMotionSamplesRequest = NSFetchRequest(entityName: "MotionSample")
    let gaitWalkingOutboundRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WalkingSample")
    let gaitWalkingReturnRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WalkingSample")
    let idPredicate = NSPredicate(format: "id == \(resultId)")
    let outboundPredicate = NSPredicate(format: "type == %@", "walking.outbound.pedometer")
    let returnPredicate = NSPredicate(format: "type == %@", "walking.return.pedometer")
    let outboundPredicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [idPredicate, outboundPredicate])
    let returnPredicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [idPredicate, returnPredicate])
    gaitWalkingOutboundRequest.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: false)]
    gaitWalkingReturnRequest.sortDescriptors = [NSSortDescriptor(key: "duration", ascending: false)]
    gaitWalkingOutboundRequest.predicate = outboundPredicates
    gaitWalkingReturnRequest.predicate = returnPredicates

//    var gaitMotionSamples: [MotionSample]?
    var gaitWalkingOutboundSamples: [WalkingSample]?
    var gaitWalkingReturnSamples: [WalkingSample]?
    do {
        //gaitMotionSamples = try coreData.privateObjectContext.executeFetchRequest(gaitMotionSamplesRequest) as? [MotionSample]
        gaitWalkingOutboundSamples = try coreData.privateObjectContext.fetch(gaitWalkingOutboundRequest) as? [WalkingSample]
        gaitWalkingReturnSamples = try coreData.privateObjectContext.fetch(gaitWalkingReturnRequest) as? [WalkingSample]
    } catch {
        let fetchError = error as NSError
        print(fetchError)
    }
    
    guard gaitWalkingOutboundSamples!.count > 0 && gaitWalkingReturnSamples!.count > 0 else { print("No walking results found"); return }
    
    let walkingOutbound = gaitWalkingOutboundSamples!.first
    let walkingReturn = gaitWalkingReturnSamples!.first
    // PROCESS GAIT ACCELEROMETER
    
    let numberOfStepsTotal = Double(walkingOutbound!.numberOfSteps) + Double(walkingReturn!.numberOfSteps)
    let durationTotal = Double(walkingOutbound!.duration) + Double(walkingReturn!.duration)
    let distanceTotal = Double(walkingOutbound!.distance) + Double(walkingReturn!.distance)
    let analysis = NSEntityDescription.insertNewObject(forEntityName: "GaitAnalysis", into: coreData.privateObjectContext) as! GaitAnalysis
    analysis.date = Date()
    analysis.gait_cycleTime = NSNumber(value: numberOfStepsTotal/durationTotal)
    analysis.gait_strideLength = NSNumber(value: numberOfStepsTotal/distanceTotal)
    analysis.gait_walkingSpeed = NSNumber(value: distanceTotal/durationTotal)
    analysis.user_id = gaitWalkingOutboundSamples!.first!.user_id
    
    analysis.updrs = 0
    do {
        try coreData.privateObjectContext.save()
    } catch {
        fatalError("Failure to save context: \(error)")
    }
}

// NSDate Comparisons
func <=(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 <= rhs.timeIntervalSince1970
}
func >=(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 >= rhs.timeIntervalSince1970
}
func >(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}
func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}
func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}
