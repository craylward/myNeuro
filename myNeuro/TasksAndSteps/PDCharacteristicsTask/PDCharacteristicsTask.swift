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
    
    let diagnosisPicker = ORKDateAnswerFormat(style: ORKDateAnswerStyle.Date)
    let diagnosisItem = ORKFormItem(identifier: "pdDiagnosis", text: "PD Diagnosis Date", answerFormat: diagnosisPicker)
    diagnosisItem.placeholder = "Enter Date"
    
    let levodopa = ORKTextChoice(text: "Carbidopa/Levodopa", value: "Carbidopa/Levodopa")
    let dopamine = ORKTextChoice(text: "Dopamine agonists", value: "Dopamine agonists")
    let anticholinergics = ORKTextChoice(text: "Anticholinergics", value: "Anticholinergics")
    let maob = ORKTextChoice(text: "MAO-B Inhibitors", value: "MAO-B Inhibitors")
    let comt = ORKTextChoice(text: "COMT Inhibitors", value: "COMT Inhibitors")
    let none = ORKTextChoice(text: "None", value: "None")
    let medicationPicker = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.MultipleChoice, textChoices: [levodopa, dopamine, anticholinergics, maob, comt, none])
    let medicationItem = ORKFormItem(identifier: "medsLast24h", text: "Medications taken in the last 24 hours", answerFormat: medicationPicker)
    
    let dbsPicker = ORKBooleanAnswerFormat()
    let dbsItem = ORKFormItem(identifier: "dbsImplant", text: "Do you have a deep brain stimulation (DBS) system implanted?", answerFormat: dbsPicker)
    
    diagnosisItem.optional = false
    medicationItem.optional = false
    dbsItem.optional = false
    
    pdcharacteristicsStep.formItems = [diagnosisItem, medicationItem, dbsItem]
    pdcharacteristicsStep.optional = false
    return pdcharacteristicsStep
}

public var PDCharacteristicsTask: ORKOrderedTask {
    return ORKOrderedTask(identifier: "PDCharacteristicsTask", steps: [PDCharacteristicsStep])
}

public var DBSConfigurationStep: ORKFormStep {
    let dbsStep = ORKFormStep(identifier: "dbsConfigurationStep", title: "DBS Configuration", text: "Enter the lead configurations below. For example, if using electrodes 1, 5, and 8, enter '158'. Enter 'C' if using the IPG case as a return electrode (i.e., ‘158C').")
    
    let leadAnswer = ORKNumericAnswerFormat(style: .Integer, unit: nil, minimum: 1, maximum: 1234568)
    
    let left = ORKFormItem(sectionTitle: "Left DBS Lead Configuration")
    let leftAnodes = ORKFormItem(identifier: "leftAnodes", text: "Anodes(+)", answerFormat: leadAnswer, optional: false)
    let leftCathodes = ORKFormItem(identifier: "leftCathodes", text: "Cathodes(-)", answerFormat: leadAnswer, optional: false)
    let right = ORKFormItem(sectionTitle: "Right DBS Lead Configuration")
    let rightAnodes = ORKFormItem(identifier: "rightAnodes", text: "Anodes(+)", answerFormat: leadAnswer, optional: false)
    let rightCathodes = ORKFormItem(identifier: "rightCathodes", text: "Cathodes(-)", answerFormat: leadAnswer, optional: false)

    leftAnodes.placeholder = "i.e. 1358"
    leftCathodes.placeholder = "i.e. 1358"
    rightAnodes.placeholder = "i.e. 1358"
    rightCathodes.placeholder = "i.e. 1358"
    
    dbsStep.formItems = [left, leftAnodes, leftCathodes, right, rightAnodes, rightCathodes]
    dbsStep.optional = false
    return dbsStep
}