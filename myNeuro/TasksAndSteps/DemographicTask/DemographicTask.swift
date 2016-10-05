//
//  DemographicTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/23/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import HealthKit

public var DemographicStep: ORKFormStep {
    let demographicStep = ORKFormStep(identifier: "DemographicStep", title: "Demographic", text: "Please fill out the information below")
    
    let agePicker = ORKNumericAnswerFormat(style: ORKNumericAnswerStyle.Integer, unit: "", minimum: 18, maximum: 100)
    let ageItem = ORKFormItem(identifier: "age", text: "Age", answerFormat: agePicker)
    ageItem.placeholder = "Enter Age"
    
    let maleText = ORKTextChoice(text: "Male", value: "Male")
    let femaleText = ORKTextChoice(text: "Female", value: "Female")
    let genderPicker = ORKValuePickerAnswerFormat(textChoices: [maleText, femaleText])
    let genderItem = ORKFormItem(identifier: "gender", text: "Gender", answerFormat: genderPicker)
    genderItem.placeholder = "Choose Gender"
    
    let white = ORKTextChoice(text: "White", value: "White")
    let hispanic = ORKTextChoice(text: "Hispanic or Latino", value: "Hispanic or Latino")
    let black = ORKTextChoice(text: "Black or African American", value: "Black or African American")
    let nativeAm = ORKTextChoice(text: "Native American", value: "Native American")
    let asian = ORKTextChoice(text: "Asian / Pacific Islander", value: "Asian / Pacific Islander")
    let other = ORKTextChoice(text: "Other", value: "Other")
    let ethnicityPicker = ORKValuePickerAnswerFormat(textChoices: [white, hispanic, black, nativeAm, asian, other])
    let ethnicityItem = ORKFormItem(identifier: "ethnicity", text: "Ethnicity", answerFormat: ethnicityPicker)
    ethnicityItem.placeholder = "Choose Ethnicity"
    
    ageItem.optional = false
    genderItem.optional = false
    ethnicityItem.optional = false

    demographicStep.formItems = [ageItem, genderItem, ethnicityItem]
    demographicStep.optional = false
    return demographicStep
}

public var DemographicTask: ORKOrderedTask {
    return ORKOrderedTask(identifier: "DemographicTask", steps: [DemographicStep])
}