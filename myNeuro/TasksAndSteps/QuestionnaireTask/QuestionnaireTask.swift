//
//  SurveyTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/23/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit

public var QuestionnaireTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    //TODO: add instructions step
    let instructionStep = ORKInstructionStep(identifier: "IntroStep")
    instructionStep.title = "Parkinson's Disease Questionnaire"
    instructionStep.text = "The following questions will provide more information regarding your health. Please answer to the best of your ability."
    steps += [instructionStep]
    
    //TODO: add 'How have you felt during the last week?' question
    let questionStepTitle1 = "How have you felt during the last week?"
    let questionStepTitle2 = "Due to having Parkinson’s disease, how often have you had difficulty performing daily activities during the last week?"
    let questionStepTitle3 = "How often have you felt depressed or anxious during the last week?"
    let questionStepTitle4 = "How often have you had cognitive difficulties  during the last week? "
    let questionStepTitle5 = "How often have you had impulsive behaviors during the last week?"
    
    let textChoices1 = [
        ORKTextChoice(text: "Excellent", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
        ORKTextChoice(text: "Very good", value: 1 as NSCoding & NSCopying & NSObjectProtocol),
        ORKTextChoice(text: "Good", value: 2 as NSCoding & NSCopying & NSObjectProtocol),
        ORKTextChoice(text: "Poor", value: 3 as NSCoding & NSCopying & NSObjectProtocol),
        ORKTextChoice(text: "Very poor", value: 4 as NSCoding & NSCopying & NSObjectProtocol)
    ]
    let textChoices2 = [
        ORKTextChoice(text: "Never", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
        ORKTextChoice(text: "Occasionally", value: 1 as NSCoding & NSCopying & NSObjectProtocol),
        ORKTextChoice(text: "Sometimes", value: 2 as NSCoding & NSCopying & NSObjectProtocol),
        ORKTextChoice(text: "Often", value: 3 as NSCoding & NSCopying & NSObjectProtocol),
        ORKTextChoice(text: "Always", value: 4 as NSCoding & NSCopying & NSObjectProtocol)
    ]
    let textAnswerFormat1: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices1)
    let textAnswerFormat2: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices2)
    let questionStep1 = ORKQuestionStep(identifier: "questionnaire.step1", title: questionStepTitle1, answer: textAnswerFormat1)
    let questionStep2 = ORKQuestionStep(identifier: "questionnaire.step2", title: questionStepTitle2, answer: textAnswerFormat2)
    let questionStep3 = ORKQuestionStep(identifier: "questionnaire.step3", title: questionStepTitle3, answer: textAnswerFormat2)
    let questionStep4 = ORKQuestionStep(identifier: "questionnaire.step4", title: questionStepTitle4, answer: textAnswerFormat2)
    let questionStep5 = ORKQuestionStep(identifier: "questionnaire.step5", title: questionStepTitle5, answer: textAnswerFormat2)
    questionStep2.text = "e.g. housework, leisure activities, exercise"
    questionStep4.text = "e.g. concentration or memory problems"
    
    steps += [questionStep1]
    steps += [questionStep2]
    steps += [questionStep3]
    steps += [questionStep4]
    steps += [questionStep5]
    
    //TODO: add summary step
    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Thanks!"
    summaryStep.text = "Your answers have been recorded"
    steps += [summaryStep]
    
    return ORKOrderedTask(identifier: "QuestionnaireTask", steps: steps)
}
