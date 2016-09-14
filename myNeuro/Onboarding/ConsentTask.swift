//
//  ConsentTask.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/25/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit

public var ConsentTask: ORKNavigableOrderedTask {
    
    var steps = [ORKStep]()
    
    //TODO: Add VisualConsentStep
    let consentDocument = ConsentDocument
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    
    //TODO: Add ConsentReviewStep
    let signature = consentDocument.signatures!.first! // only one signature in consent document
    
    let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, inDocument: consentDocument)
    
    reviewConsentStep.text = "Review the consent form."
    reviewConsentStep.reasonForConsent = "Consent to join study"
    
    let consentFailedStep = ConsentFailedStep(identifier: "ConsentFailedStep")
    
    let healthDataStep = HealthDataStep(identifier: "Health")
    
    let passcodeStep = ORKPasscodeStep(identifier: "Passcode")
    passcodeStep.text = "Now you will create a passcode to identify yourself to the app and protect access to information you've entered."
    
    
    let completionStep = ORKCompletionStep(identifier: "CompletionStep")
    completionStep.title = "Welcome aboard."
    completionStep.text = "Thank you for joining this study."
    
    steps += [visualConsentStep, reviewConsentStep, consentFailedStep, DemographicStep, PDCharacteristicsStep, healthDataStep, passcodeStep, completionStep]
    
    let task = ORKNavigableOrderedTask(identifier: "ConsentTask", steps: steps)
    
    let reviewSelector = ORKResultSelector(stepIdentifier: "ConsentReviewStep", resultIdentifier: "ConsentDocumentParticipantSignature")
    let reviewPredicate = ORKResultPredicate.predicateForConsentWithResultSelector(reviewSelector, didConsent: true)
    let reviewConsent = ORKPredicateStepNavigationRule(resultPredicates: [reviewPredicate], destinationStepIdentifiers: ["DemographicStep"], defaultStepIdentifier: nil, validateArrays: true)
    task.setNavigationRule(reviewConsent, forTriggerStepIdentifier: "ConsentReviewStep")
    
    return task
}

class ConsentFailedStep: ORKWaitStep {
    
    static func stepViewControllerClass() -> ConsentFailedViewController.Type {
        return ConsentFailedViewController.self
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        indicatorType = ORKProgressIndicatorType.None
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ConsentFailedViewController: ORKWaitStepViewController
{
    static func stepViewControllerClass() -> ConsentFailedViewController.Type {
        return ConsentFailedViewController.self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateText("You must agree to the consent form to join the study.")
    }
}
    