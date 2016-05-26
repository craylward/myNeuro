//
//  ConsentTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/25/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit

public var ConsentTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    //TODO: Add VisualConsentStep
    let consentDocument = ConsentDocument
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    
    //TODO: Add ConsentReviewStep
    let signature = consentDocument.signatures!.first! // only one signature in consent document
    
    let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, inDocument: consentDocument)
    
    reviewConsentStep.text = "Review the consent form."
    reviewConsentStep.reasonForConsent = "Consent to join study"
    
    
    let healthDataStep = HealthDataStep(identifier: "Health")
    
    let passcodeStep = ORKPasscodeStep(identifier: "Passcode")
    passcodeStep.text = "Now you will create a passcode to identify yourself to the app and protect access to information you've entered."
    
    let completionStep = ORKCompletionStep(identifier: "CompletionStep")
    completionStep.title = "Welcome aboard."
    completionStep.text = "Thank you for joining this study."
    
    steps += [visualConsentStep, reviewConsentStep, healthDataStep, passcodeStep, completionStep]
    
    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}