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
    let questionStepTitle2 = "Due to having Parkinson’s disease, how often have you had difficulty performing daily activities (e.g., housework, leisure activities, exercise) during the last week?"
    let questionStepTitle3 = "How often have you felt depressed or anxious during the last week?"
    let questionStepTitle4 = "How often have you had cognitive difficulties (e.g., concentration or memory problems) during the last week? "
    let questionStepTitle5 = "How often have you had impulsive behaviors during the last week?"
    
    let textChoices1 = [
        ORKTextChoice(text: "Excellent", value: 0),
        ORKTextChoice(text: "Very good", value: 1),
        ORKTextChoice(text: "Good", value: 2),
        ORKTextChoice(text: "Poor", value: 3),
        ORKTextChoice(text: "Very poor", value: 4)
    ]
    let textChoices2 = [
        ORKTextChoice(text: "Never", value: 0),
        ORKTextChoice(text: "Occasionally", value: 1),
        ORKTextChoice(text: "Sometimes", value: 2),
        ORKTextChoice(text: "Often", value: 3),
        ORKTextChoice(text: "Always", value: 4)
    ]
    let textAnswerFormat1: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: textChoices1)
    let textAnswerFormat2: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: textChoices2)
    let questionStep1 = ORKQuestionStep(identifier: "TextChoiceQuestionStep1", title: questionStepTitle1, answer: textAnswerFormat1)
    let questionStep2 = ORKQuestionStep(identifier: "TextChoiceQuestionStep2", title: questionStepTitle2, answer: textAnswerFormat2)
    let questionStep3 = ORKQuestionStep(identifier: "TextChoiceQuestionStep3", title: questionStepTitle3, answer: textAnswerFormat2)
    let questionStep4 = ORKQuestionStep(identifier: "TextChoiceQuestionStep4", title: questionStepTitle4, answer: textAnswerFormat2)
    let questionStep5 = ORKQuestionStep(identifier: "TextChoiceQuestionStep5", title: questionStepTitle5, answer: textAnswerFormat2)
    
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