//
//  ResultsParser.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/1/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreData
import HealthKit

class ResultProcessor {
    
    let coreData = CoreDataStack.sharedInstance()
    let taskResult = NSEntityDescription.insertNewObjectForEntityForName("TaskResult", inManagedObjectContext: CoreDataStack.sharedInstance().privateObjectContext) as! TaskResult
    
    func processResult(result: ORKTaskResult) {
        
        guard result.results != nil else {
            return
        }
        taskResult.id = fetchTaskId()
        taskResult.date = result.startDate
        // Process Questionnaire Results
        if result.identifier.containsString("QuestionnaireTask") {
            processQuestionResult(result.results!)
        }
        // Process Consent Results
        else if result.identifier.containsString("ConsentTask") {
            processConsentResult(result.results!)
        }
        
        for stepResult in result.results as! [ORKStepResult] { // Iterate through TaskResult child results (Cast as step results)
            // Process Tremor Results
            if stepResult.identifier.lowercaseString.containsString("tremor") { // pick out the tremor steps
                for fileResult in stepResult.results as! [ORKFileResult] { // Iterate through the child results of the tremor steps (file results)
                    let typeResult = stepResult.identifier + "." + fileResult.identifier  // i.e "tremor.handInLap.right" + "." + "ac1_acc"
                    processFileResult(fileResult.fileURL!, type: typeResult)
                }
            }
                // Process Bradykinesia Results
            else if stepResult.identifier.containsString("tapping") {
                for childResult in stepResult.results! {
                    if let grandChildResult = childResult as? ORKTappingIntervalResult {
                        processTappingResult(grandChildResult)
                    }
                    else if let grandChildResult = childResult as? ORKFileResult {
                        if grandChildResult.identifier.containsString("accelerometer"){
                            processFileResult(grandChildResult.fileURL!, type: "bradykinesia.acc")
                        }
                        else {
                            processFileResult(grandChildResult.fileURL!, type: "bradykinesia.touch")
                        }
                        
                    }
                }
            }
                // Process Gait Results
            else if stepResult.identifier.containsString("walking") { // pick out the gait steps
                for fileResult in stepResult.results as! [ORKFileResult] { // Iterate through the child results of the gait steps (file results)
                    let typeResult = stepResult.identifier + "." + fileResult.identifier  // i.e "walking.outbound" + "." + "pedometer"
                    processFileResult(fileResult.fileURL!, type: typeResult)
                }
            }            
        }
        if result.identifier.containsString("BradykinesiaTask") {
            taskResult.type = "Bradykinesia"
            bradyAnalysis(Int(taskResult.id))
        }
        else if result.identifier.containsString("TremorTask") {
            taskResult.type = "Tremor"
            tremorAnalysis(Int(taskResult.id))
        }
        else if result.identifier.containsString("GaitTask") {
            taskResult.type = "Gait"
            gaitAnalysis(Int(taskResult.id))
        }
        else {
            print("ResultsToCoreData: NO ANALYSIS PERFORMED")
        }
    }
    
    
    func processConsentResult(consentResults: [ORKResult]) {
        var sample: Participant?
        let request = NSFetchRequest(entityName: "Participant")
        do {
            let result = try coreData.privateObjectContext.executeFetchRequest(request)
            if (result.count > 0) {
                sample = result[0] as? Participant
            }
            else {
                sample = NSEntityDescription.insertNewObjectForEntityForName("Participant", inManagedObjectContext: coreData.privateObjectContext) as? Participant
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

        
        for stepResult in consentResults as! [ORKStepResult] {
            if stepResult.identifier.containsString("ConsentReviewStep") {
                if let signatureResult = stepResult.resultForIdentifier("ConsentDocumentParticipantSignature") as! ORKConsentSignatureResult? {
                    sample!.firstName = signatureResult.signature!.givenName!
                    sample!.lastName = signatureResult.signature!.familyName!
                }
            }
            else if stepResult.identifier.containsString("DemographicStep") {
                if let ageResult = stepResult.resultForIdentifier("age") as! ORKNumericQuestionResult? {
                    sample!.age = ageResult.numericAnswer
                }
                if let genderResult = stepResult.resultForIdentifier("gender") as! ORKChoiceQuestionResult? {
                    sample!.gender = genderResult.choiceAnswers?.first as? String
                }
                if let ethnicityResult = stepResult.resultForIdentifier("ethnicity") as! ORKChoiceQuestionResult? {
                    sample!.ethnicity = ethnicityResult.choiceAnswers?.first as? String
                }
            }
            else if stepResult.identifier.containsString("PDCharacteristicsStep") {
                if let pddiagnosisResult = stepResult.resultForIdentifier("pdDiagnosis") as! ORKDateQuestionResult? {
                    sample!.pdDiagnosis = pddiagnosisResult.dateAnswer
                }
                if let medicationResult = stepResult.resultForIdentifier("medsLast24h") as! ORKChoiceQuestionResult? {
                    let meds = medicationResult.choiceAnswers as! [String]
                    sample!.medsLast24h = meds.joinWithSeparator(", ")
                }
                if let dbsResult = stepResult.resultForIdentifier("dbsParam") as! ORKNumericQuestionResult? {
                    sample!.dbsParam = dbsResult.numericAnswer
                }
            }
        }
        
                
                /* Attempt to obtain Demographics Data through HealthKit First */
//                let healthCharacteristicTypes = [
//                    HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
//                    HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
//                    HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierFitzpatrickSkinType)!,
//                ]
//                let typesToRequest = Set<HKCharacteristicType>(healthCharacteristicTypes)
//                HKHealthStore().requestAuthorizationToShareTypes(nil, readTypes: typesToRequest) { authorized, error in
//                    guard authorized else { return }
//                }
//                do {
//                    let dateOfBirth = try HKHealthStore().dateOfBirth()
//                    let now = NSDate()
//                    let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: dateOfBirth, toDate: now, options: .WrapComponents)
//                    let age = ageComponents.year
//                    sample.age = age
//                    
//                    let gender = try HKHealthStore().biologicalSex().biologicalSex
//                    switch gender{
//                    case HKBiologicalSex.Female:
//                        sample.gender = "Female"
//                    case HKBiologicalSex.Male:
//                        sample.gender = "Male"
//                    default:
//                        break
//                    }
//                }
//                catch {
//                    
//                }
        
        // Mark: Save Data
        do {
            try coreData.privateObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func processQuestionResult(questionResults: [ORKResult]){
        
        let sample = NSEntityDescription.insertNewObjectForEntityForName("QuestionnaireSample", inManagedObjectContext: coreData.privateObjectContext) as! QuestionnaireSample
        sample.id = taskResult.id
        // Process Questionnaire Results
        for stepResult in questionResults as! [ORKStepResult] {
            if stepResult.identifier.containsString("questionnaire") {
                let questionStep = stepResult.results!.first as! ORKChoiceQuestionResult
                if let choices = questionStep.choiceAnswers as! [Int]? {
                    switch stepResult.identifier {
                    case "questionnaire.step1":
                        sample.q1 = choices.first!
                    case "questionnaire.step2":
                        sample.q2 = choices.first!
                    case "questionnaire.step3":
                        sample.q3 = choices.first!
                    case "questionnaire.step4":
                        sample.q4 = choices.first!
                    case "questionnaire.step5":
                        sample.q5 = choices.first!
                    default:
                        break
                    }
                }
            }
        }
        // Mark: Save Data
        do {
            try coreData.privateObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }

    func processFileResult(url: NSURL, type: String) {
        
        // Debugging
        print(type)
        //print(coreData.privateObjectContext.persistentStoreCoordinator?.persistentStores[0].URL)
        //let string = try? NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        //print(string) ///   DEV: Prints entire JSON file contents
        
        if let data = try? NSData(contentsOfURL: url, options: []) {
            let json = JSON(data: data)
            for item in json["items"].arrayValue {
                if type.containsString("pedometer") {
                    let sample = NSEntityDescription.insertNewObjectForEntityForName("WalkingSample", inManagedObjectContext: coreData.privateObjectContext) as! WalkingSample
                    sample.distance = Double(item["distance"].stringValue)!
                    sample.numberOfSteps = Int(item["numberOfSteps"].stringValue)!
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-SSSS"
                    let startDate = dateFormatter.dateFromString(item["startDate"].stringValue)
                    let endDate = dateFormatter.dateFromString(item["endDate"].stringValue)
                    sample.duration = Double(endDate!.timeIntervalSinceDate(startDate!))
                    sample.type = type
                    sample.id = taskResult.id
                }
                else {
                    let sample = NSEntityDescription.insertNewObjectForEntityForName("MotionSample", inManagedObjectContext: coreData.privateObjectContext) as! MotionSample
                    sample.id = taskResult.id
                    sample.timeStamp = Double(item["timestamp"].stringValue)!
                    sample.type = type
                    if type.containsString("otion"){
                        sample.rX = Double(item["rotationRate"]["x"].stringValue)!
                        sample.rY = Double(item["rotationRate"]["y"].stringValue)!
                        sample.rZ = Double(item["rotationRate"]["z"].stringValue)!
                        sample.aX = Double(item["userAcceleration"]["x"].stringValue)!
                        sample.aY = Double(item["userAcceleration"]["y"].stringValue)!
                        sample.aZ = Double(item["userAcceleration"]["z"].stringValue)!
                    }
                    else if type.containsString("acc") {
                        sample.aX = (Double(item["x"].stringValue)!)
                        sample.aY = (Double(item["y"].stringValue)!)
                        sample.aZ = (Double(item["z"].stringValue)!)
                    }
                }
                
                // Mark: Save Data
                do {
                    try coreData.privateObjectContext.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
                
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
    
    func processTappingResult(tapResult: ORKTappingIntervalResult) {
        
        for tappingSample in tapResult.samples! {
            let sample = NSEntityDescription.insertNewObjectForEntityForName("TappingSample", inManagedObjectContext: coreData.privateObjectContext) as! TappingSample
            sample.id = taskResult.id
            sample.timeStamp = tappingSample.timestamp
            sample.loc_x = Double(tappingSample.location.x)
            sample.loc_y = Double(tappingSample.location.y)
            sample.duration = Double(tappingSample.duration)
            if tappingSample.buttonIdentifier == ORKTappingButtonIdentifier.Left {
                sample.button_id = "left"
            }
            else if tappingSample.buttonIdentifier == ORKTappingButtonIdentifier.Right {
                sample.button_id = "right"
            }
            else {
                sample.button_id = "none"
            }
            
            // MARK: Save data
            do {
                try coreData.privateObjectContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        
    }
    
    func fetchTaskId() -> Int {
        let request = NSFetchRequest(entityName: "TaskResult")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.fetchLimit = 1
        do {
            let result = try coreData.privateObjectContext.executeFetchRequest(request)
            if (result.count > 0) {
                let latest_task = result[0] as! TaskResult
                return latest_task.id.integerValue + 1 // 1 after the latest task id
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return 1
    }
}