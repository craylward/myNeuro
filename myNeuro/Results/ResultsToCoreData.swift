//
//  ResultsToCoreData.swift
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
    
    let taskResult = NSEntityDescription.insertNewObject(forEntityName: "TaskResult", into: CoreDataStack.sharedInstance().privateObjectContext) as! TaskResult
    
    func processResult(_ result: ORKTaskResult) {
        guard result.results != nil else {
            return
        }
        
        taskResult.id = NSNumber(value: fetchTaskId())
        taskResult.date = result.startDate
        taskResult.user_id = NSNumber(value: fetchLatestUserID(coreData.privateObjectContext))
        
        for stepResult in result.results as! [ORKStepResult] { // Iterate through TaskResult child results (Cast as step results)
            // Process Tremor Results
            if stepResult.identifier.lowercased().contains("tremor") { // pick out the tremor steps
                for fileResult in stepResult.results as! [ORKFileResult] { // Iterate through the child results of the tremor steps (file results)
                    let typeResult = stepResult.identifier + "." + fileResult.identifier  // i.e "tremor.handInLap.right" + "." + "ac1_acc"
                    processFileResult(fileResult.fileURL!, type: typeResult)
                }
            }
            // Process Bradykinesia Results
            else if stepResult.identifier.contains("tapping") {
                for childResult in stepResult.results! {
                    if let grandChildResult = childResult as? ORKTappingIntervalResult {
                        processTappingResult(grandChildResult)
                    }
                    else if let grandChildResult = childResult as? ORKFileResult {
                        if grandChildResult.identifier.contains("accelerometer"){
                            let typeResult = "bradykinesia.acc"
                            processFileResult(grandChildResult.fileURL!, type: typeResult)
                        }
                        else {
                            let typeResult = "bradykinesia.touch"
                            processFileResult(grandChildResult.fileURL!, type: typeResult)
                        }
                    }
                }
            }
            // Process Gait Results
            else if stepResult.identifier.contains("walking") { // pick out the gait steps
                for fileResult in stepResult.results as! [ORKFileResult] { // Iterate through the child results of the gait steps (file results)
                    let typeResult = stepResult.identifier + "." + fileResult.identifier  // i.e "walking.outbound" + "." + "pedometer"
                    processFileResult(fileResult.fileURL!, type: typeResult)
                }
            }
        }
        
        // Follow up after saving to Core Data
        // Consent Task (includes save to CoreData)
        if result.identifier.contains("ConsentTask") {
            processConsentResult(result.results!)
            taskResult.type = "Consent"
        }
        // Questionnaire Task (includes save to CoreData)
        else if result.identifier.contains("QuestionnaireTask") {
            processQuestionResult(result.results!)
            taskResult.type = "Questionnaire"
        }
        else if result.identifier.contains("BradykinesiaTask") {
            taskResult.type = "Bradykinesia"
            bradyAnalysis(Int(taskResult.id))
        }
        else if result.identifier.contains("TremorTask") {
            taskResult.type = "Tremor"
            tremorAnalysis(Int(taskResult.id))
        }
        else if result.identifier.contains("GaitTask") {
            taskResult.type = "Gait"
            gaitAnalysis(Int(taskResult.id))
        }
        else {
            print("ResultsToCoreData: NO ANALYSIS PERFORMED")
        }
//        coreData.savePrivateContext()
    }
    
    func processConsentResult(_ consentResults: [ORKResult]) {
        
        let sample = NSEntityDescription.insertNewObject(forEntityName: "Participant", into: coreData.privateObjectContext) as! Participant
        sample.joinDate = taskResult.date
        for stepResult in consentResults as! [ORKStepResult] {
            if stepResult.identifier.contains("ConsentReviewStep") {
                if let signatureResult = stepResult.result(forIdentifier: "ConsentDocumentParticipantSignature") as! ORKConsentSignatureResult? {
                    sample.firstName = signatureResult.signature!.givenName!
                    sample.lastName = signatureResult.signature!.familyName!
                }
            }
            else if stepResult.identifier.contains("DemographicStep") {
                if let ageResult = stepResult.result(forIdentifier: "age") as! ORKNumericQuestionResult? {
                    sample.age = ageResult.numericAnswer
                }
                if let genderResult = stepResult.result(forIdentifier: "gender") as! ORKChoiceQuestionResult? {
                    sample.gender = genderResult.choiceAnswers?.first as? String
                }
                if let ethnicityResult = stepResult.result(forIdentifier: "ethnicity") as! ORKChoiceQuestionResult? {
                    sample.ethnicity = ethnicityResult.choiceAnswers?.first as? String
                }
            }
            else if stepResult.identifier.contains("PDCharacteristicsStep") {
                if let pddiagnosisResult = stepResult.result(forIdentifier: "pdDiagnosis") as! ORKDateQuestionResult? {
                    sample.pdDiagnosis = pddiagnosisResult.dateAnswer
                }
                if let medicationResult = stepResult.result(forIdentifier: "medsLast24h") as! ORKChoiceQuestionResult? {
                    let meds = medicationResult.choiceAnswers as! [String]
                    sample.medsLast24h = meds.joined(separator: ", ")
                }
                if let dbsResult = stepResult.result(forIdentifier: "dbsImplant") as! ORKBooleanQuestionResult? {
                    sample.dbsImplant = dbsResult.booleanAnswer
                }
            }
            else if stepResult.identifier.contains("dbsConfigurationStep") {
                if let leftAnodesResult = stepResult.result(forIdentifier: "leftAnodes") as! ORKTextQuestionResult? {
                    sample.dbsLeftAnodes = leftAnodesResult.textAnswer
                }
                if let leftCathodesResult = stepResult.result(forIdentifier: "leftCathodes") as! ORKTextQuestionResult? {
                    sample.dbsLeftCathodes = leftCathodesResult.textAnswer
                }
                if let rightAnodesResult = stepResult.result(forIdentifier: "rightAnodes") as! ORKTextQuestionResult?  {
                    sample.dbsRightAnodes = rightAnodesResult.textAnswer
                }
                if let rightCathodesResult = stepResult.result(forIdentifier: "rightCathodes") as! ORKTextQuestionResult?  {
                    sample.dbsRightCathodes = rightCathodesResult.textAnswer
                }
            }
        }
        sample.user_id = NSNumber(value: fetchLatestUserID(coreData.privateObjectContext) + 1)
        taskResult.user_id = sample.user_id
        
        // coreData.savePrivateContext()
    }
    
    func processQuestionResult(_ questionResults: [ORKResult]){
        let sample = NSEntityDescription.insertNewObject(forEntityName: "QuestionnaireSample", into: coreData.privateObjectContext) as! QuestionnaireSample
        sample.id = taskResult.id
        sample.user_id = taskResult.user_id
        sample.date = taskResult.date
        // Process Questionnaire Results
        for stepResult in questionResults as! [ORKStepResult] {
            if stepResult.identifier.contains("questionnaire") {
                let questionStep = stepResult.results!.first as! ORKChoiceQuestionResult
                if let choices = questionStep.choiceAnswers as! [Int]? {
                    switch stepResult.identifier {
                    case "questionnaire.step1":
                        sample.q1 = NSNumber(value: choices.first!)
                    case "questionnaire.step2":
                        sample.q2 = NSNumber(value: choices.first!)
                    case "questionnaire.step3":
                        sample.q3 = NSNumber(value: choices.first!)
                    case "questionnaire.step4":
                        sample.q4 = NSNumber(value: choices.first!)
                    case "questionnaire.step5":
                        sample.q5 = NSNumber(value: choices.first!)
                    default:
                        break
                    }
                }
            }
        }
//        coreData.savePrivateContext()
    }
    
    func processFileResult(_ url: URL, type: String) {
        
        // Debugging
        print(type)
        //print(coreData.privateObjectContext.persistentStoreCoordinator?.persistentStores[0].URL)
        //let string = try? NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        //print(string) ///   DEV: Prints entire JSON file contents
        
        if let data = try? Data(contentsOf: url, options: []) {
            let json = JSON(data: data)
            for item in json["items"].arrayValue {
                if type.contains("pedometer") {
                    let sample = NSEntityDescription.insertNewObject(forEntityName: "WalkingSample", into: coreData.privateObjectContext) as! WalkingSample
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
                    let sample = NSEntityDescription.insertNewObject(forEntityName: "MotionSample", into: coreData.privateObjectContext) as! MotionSample
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
                    let sample = NSEntityDescription.insertNewObject(forEntityName: "AccelSample", into: coreData.privateObjectContext) as! AccelSample
                    sample.id = taskResult.id
                    sample.user_id = taskResult.user_id
                    sample.timeStamp = NSNumber(value: Double(item["timestamp"].stringValue)!)
                    sample.type = type
                    sample.aX = (NSNumber(value: Double(item["x"].stringValue)!))
                    sample.aY = (NSNumber(value: Double(item["y"].stringValue)!))
                    sample.aZ = (NSNumber(value: Double(item["z"].stringValue)!))
                    sample.isBacked = 0
                }
//                coreData.savePrivateContext()
                
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
    
    func processTappingResult(_ tapResult: ORKTappingIntervalResult) {
        for tappingSample in tapResult.samples! {
            let sample = NSEntityDescription.insertNewObject(forEntityName: "TappingSample", into: coreData.privateObjectContext) as! TappingSample
            sample.id = taskResult.id
            sample.user_id = taskResult.user_id
            sample.isBacked = 0
            sample.timeStamp = NSNumber(value: tappingSample.timestamp)
            sample.loc_x = NSNumber(value: Double(tappingSample.location.x))
            sample.loc_y = NSNumber(value: Double(tappingSample.location.y))
            sample.duration = NSNumber(value: Double(tappingSample.duration))
            if tappingSample.buttonIdentifier == ORKTappingButtonIdentifier.left {
                sample.button_id = "left"
            }
            else if tappingSample.buttonIdentifier == ORKTappingButtonIdentifier.right {
                sample.button_id = "right"
            }
            else {
                sample.button_id = "none"
            }
//            coreData.savePrivateContext()
        }
    }
}

func fetchTaskId() -> Int {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskResult")
    request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
    request.fetchLimit = 1
    do {
        let result = try coreData.privateObjectContext.fetch(request)
        if (result.count > 0) {
            let latest_task = result[0] as! TaskResult
            return latest_task.id.intValue + 1 // 1 after the latest task id
        }
    } catch {
        let fetchError = error as NSError
        print(fetchError)
    }
    return 1
}
