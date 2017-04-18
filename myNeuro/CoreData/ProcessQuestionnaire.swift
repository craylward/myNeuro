//
//  ProcessQuestionnaire.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/16/17.
//  Copyright © 2017 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreData

func processQuestionnaire(_ questionResults: [ORKResult]){
    let taskResult = CoreDataStack.createNewTaskResult(type: "Questionnaire")
    
    let sample = NSEntityDescription.insertNewObject(forEntityName: "QuestionnaireSample", into: CoreDataStack.coreData.privateObjectContext) as! QuestionnaireSample
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
    //        CoreDataStack.coreData.savePrivateContext()
}
