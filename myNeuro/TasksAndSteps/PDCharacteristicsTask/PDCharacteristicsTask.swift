//
//  PDCharacteristicsTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/23/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import HealthKit

public var PDCharacteristicsStep: ORKFormStep {
    let pdcharacteristicsStep = ORKFormStep(identifier: "PDCharacteristicsStep", title: "PD Characteristics", text: "Please fill out the information below")
    
    let diagnosisPicker = ORKDateAnswerFormat(style: ORKDateAnswerStyle.date)
    let diagnosisItem = ORKFormItem(identifier: "pdDiagnosis", text: "PD Diagnosis Date", answerFormat: diagnosisPicker)
    diagnosisItem.placeholder = "Enter Date"
    
    let levodopa = ORKTextChoice(text: "Carbidopa/Levodopa", value: "Carbidopa/Levodopa" as NSCoding & NSCopying & NSObjectProtocol)
    let dopamine = ORKTextChoice(text: "Dopamine agonists", value: "Dopamine agonists" as NSCoding & NSCopying & NSObjectProtocol)
    let anticholinergics = ORKTextChoice(text: "Anticholinergics", value: "Anticholinergics" as NSCoding & NSCopying & NSObjectProtocol)
    let maob = ORKTextChoice(text: "MAO-B Inhibitors", value: "MAO-B Inhibitors" as NSCoding & NSCopying & NSObjectProtocol)
    let comt = ORKTextChoice(text: "COMT Inhibitors", value: "COMT Inhibitors" as NSCoding & NSCopying & NSObjectProtocol)
    let none = ORKTextChoice(text: "None", value: "None" as NSCoding & NSCopying & NSObjectProtocol)
    let medicationPicker = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.multipleChoice, textChoices: [levodopa, dopamine, anticholinergics, maob, comt, none])
    let medicationItem = ORKFormItem(identifier: "medsLast24h", text: "Medications taken in the last 24 hours", answerFormat: medicationPicker)
    
    let dbsPicker = ORKBooleanAnswerFormat()
    let dbsItem = ORKFormItem(identifier: "dbsImplant", text: "Do you have a deep brain stimulation (DBS) system implanted?", answerFormat: dbsPicker)
    
    diagnosisItem.isOptional = false
    medicationItem.isOptional = false
    dbsItem.isOptional = false
    
    pdcharacteristicsStep.formItems = [diagnosisItem, medicationItem, dbsItem]
    pdcharacteristicsStep.isOptional = false
    return pdcharacteristicsStep
}

public var PDCharacteristicsTask: ORKOrderedTask {
    return ORKOrderedTask(identifier: "PDCharacteristicsTask", steps: [PDCharacteristicsStep])
}

public var DBSConfigurationStep: ORKFormStep {
    let dbsStep = ORKFormStep(identifier: "dbsConfigurationStep", title: "DBS Configuration", text: "Enter the lead configurations below. For example, if using electrodes 1, 5, and 8, enter '158'. Enter 'C' if using the IPG case as a return electrode (i.e., ‘158C').")
    
    let leadAnswer = ORKTextAnswerFormat(validationRegex: "^[0-9|C|c]{1,10}$", invalidMessage: "Invalid input")
    leadAnswer.multipleLines = false
    leadAnswer.maximumLength = 10
    
    let left = ORKFormItem(sectionTitle: "Left DBS Lead Configuration")
    let leftAnodes = ORKFormItem(identifier: "leftAnodes", text: "Anodes(+)", answerFormat: leadAnswer, optional: true)
    let leftCathodes = ORKFormItem(identifier: "leftCathodes", text: "Cathodes(-)", answerFormat: leadAnswer, optional: true)
    let right = ORKFormItem(sectionTitle: "Right DBS Lead Configuration")
    let rightAnodes = ORKFormItem(identifier: "rightAnodes", text: "Anodes(+)", answerFormat: leadAnswer, optional: true)
    let rightCathodes = ORKFormItem(identifier: "rightCathodes", text: "Cathodes(-)", answerFormat: leadAnswer, optional: true)

    leftAnodes.placeholder = "i.e. 1358"
    leftCathodes.placeholder = "i.e. 1358"
    rightAnodes.placeholder = "i.e. 1358"
    rightCathodes.placeholder = "i.e. 1358"
    
    dbsStep.formItems = [left, leftAnodes, leftCathodes, right, rightAnodes, rightCathodes]
    dbsStep.isOptional = true
    return dbsStep
}
