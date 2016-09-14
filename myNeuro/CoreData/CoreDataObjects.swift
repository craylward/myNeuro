//
//  CoreDataObjects.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/21/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import CoreData
import ResearchKit

class Participant: NSManagedObject {
    @NSManaged var user_id: NSNumber
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var joinDate: NSDate
    
    // Demographic
    @NSManaged var age: NSNumber?
    @NSManaged var ethnicity: String?
    @NSManaged var gender: String?
    
    //PD Characteristics
    @NSManaged var dbsParam: NSNumber?
    @NSManaged var medsLast24h: String?
    @NSManaged var pdDiagnosis: NSDate?
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
}
class TaskResult: NSManagedObject {
    @NSManaged var user_id: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var id: NSNumber
    @NSManaged var type: String
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
}

class TappingSample: NSManagedObject {
    @NSManaged var id: NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var timeStamp: NSNumber
    @NSManaged var loc_x: NSNumber
    @NSManaged var loc_y: NSNumber
    @NSManaged var button_id: String
    @NSManaged var duration: NSNumber
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
}

class AccelSample: NSManagedObject {
    @NSManaged var timeStamp: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var type: String
    @NSManaged var aX: NSNumber
    @NSManaged var aY: NSNumber
    @NSManaged var aZ: NSNumber
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
}

class MotionSample: NSManagedObject {
    @NSManaged var timeStamp: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var type: String
    @NSManaged var aX: NSNumber
    @NSManaged var aY: NSNumber
    @NSManaged var aZ: NSNumber
    @NSManaged var rX: NSNumber
    @NSManaged var rY: NSNumber
    @NSManaged var rZ: NSNumber
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
}

class WalkingSample: NSManagedObject {
    @NSManaged var id: NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var timeStamp: NSNumber
    @NSManaged var numberOfSteps: NSNumber
    @NSManaged var distance: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var type: String
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
}

class QuestionnaireSample: NSManagedObject {
    @NSManaged var id: NSNumber
    @NSManaged var user_id: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var q1: NSNumber
    @NSManaged var q2: NSNumber
    @NSManaged var q3: NSNumber
    @NSManaged var q4: NSNumber
    @NSManaged var q5: NSNumber
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
}

class BradyAnalysis: NSManagedObject {
    @NSManaged var date: NSDate
    @NSManaged var brady_intervalAvg: NSNumber
    @NSManaged var brady_cvDuration: NSNumber
    @NSManaged var updrs: NSNumber
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
    @NSManaged var user_id: NSNumber
}
class TremorAnalysis: NSManagedObject {
    @NSManaged var date: NSDate
    @NSManaged var tremor_r_RMS: NSNumber
    @NSManaged var tremor_r_K: NSNumber
    @NSManaged var tremor_p_RMS: NSNumber
    @NSManaged var tremor_p_K: NSNumber
    @NSManaged var tremor_k_RMS: NSNumber
    @NSManaged var tremor_k_K: NSNumber
    @NSManaged var updrs: NSNumber
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
    @NSManaged var user_id: NSNumber
}
class GaitAnalysis: NSManagedObject {
    @NSManaged var date: NSDate
    @NSManaged var gait_cycleTime: NSNumber
    @NSManaged var gait_strideLength: NSNumber
    @NSManaged var gait_walkingSpeed: NSNumber
    @NSManaged var gait_stepIntReg: NSNumber
    @NSManaged var updrs: NSNumber
    @NSManaged var isBacked: NSNumber
    @NSManaged var pk: NSNumber
    @NSManaged var user_id: NSNumber
}