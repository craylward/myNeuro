//
//  ProcessConsent.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/16/17.
//  Copyright © 2017 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreData

func processConsent(_ consentResults: [ORKResult]) {
    let taskResult = CoreDataStack.createNewTaskResult(type: "Consent")
    
    let sample = NSEntityDescription.insertNewObject(forEntityName: "Participant", into: CoreDataStack.coreData.privateObjectContext) as! Participant
    
    sample.joinDate = taskResult.date
    //CoreDataStack.coreData.latestUserID += 1
    sample.user_id = NSNumber(value: CoreDataStack.coreData.latestUserID + 1)
    taskResult.user_id = NSNumber(value: CoreDataStack.coreData.latestUserID + 1)
    
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
    CoreDataStack.coreData.savePrivateContext()
}
