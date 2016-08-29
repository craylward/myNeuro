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
    
    let dbsPicker = ORKNumericAnswerFormat(style: ORKNumericAnswerStyle.Integer, unit: "Hz", minimum: 1, maximum: 1000)
    let dbsItem = ORKFormItem(identifier: "dbsParam", text: "DBS Parameter", answerFormat: dbsPicker)
    dbsItem.placeholder = "(Optional)"
    
    diagnosisItem.optional = false
    medicationItem.optional = false
    dbsItem.optional = true
    
    pdcharacteristicsStep.formItems = [diagnosisItem, medicationItem, dbsItem]
    pdcharacteristicsStep.optional = false
    return pdcharacteristicsStep
}

public var PDCharacteristicsTask: ORKOrderedTask {
    return ORKOrderedTask(identifier: "PDCharacteristicsTask", steps: [PDCharacteristicsStep])
}