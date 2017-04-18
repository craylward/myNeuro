//
//  EligibleViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/24/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit
import CoreData

class EligibleViewController: UIViewController {
    // MARK: IB actions
    @IBAction func continuePressed(_ sender: UIButton) {
        let orderedTask = ConsentTask
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = "Back"
    }
}

extension EligibleViewController : ORKTaskViewControllerDelegate {
    /**
     Tells the delegate that the task has finished.
     
     The task view controller calls this method when an unrecoverable error occurs,
     when the user has canceled the task (with or without saving), or when the user
     completes the last step in the task.
     
     In most circumstances, the receiver should dismiss the task view controller
     in response to this method, and may also need to collect and process the results
     of the task.
     
     @param taskViewController  The `ORKTaskViewController `instance that is returning the result.
     @param reason              An `ORKTaskViewControllerFinishReason` value indicating how the user chose to complete the task.
     @param error               If failure occurred, an `NSError` object indicating the reason for the failure. The value of this parameter is `nil` if `result` does not indicate failure.
     
     reachable = Reachability.isConnectedToNetwork()
     
     
     */
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            CoreDataStack.coreData.privateObjectContext.perform { () -> Void in
                processConsent(taskViewController.result.results!)
                CoreDataStack.coreData.savePrivateContext()
            }
            performSegue(withIdentifier: "unwindToStudy", sender: nil)
            
        case .discarded, .failed, .saved:
            dismiss(animated: true, completion: nil)
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        if step is HealthDataStep {
            let healthStepViewController = HealthDataStepViewController(step: step)
            return healthStepViewController
        }
        return nil
    }
    
}
