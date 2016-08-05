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
    @IBAction func continuePressed(sender: UIButton) {
        let orderedTask = ConsentTask
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRunUUID: nil)
        taskViewController.delegate = self
        presentViewController(taskViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem?.title = "Back"
    }
    
    lazy var privateContext: NSManagedObjectContext = {
        var coreDataStack = CoreDataStack()
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = coreDataStack.persistentStoreCoordinator
        return context
    }()
}

extension EligibleViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        switch reason {
        case .Completed:
            let resultProcessor = ResultProcessor(context: privateContext)
            privateContext.performBlock { () -> Void in
                resultProcessor.processResult(taskViewController.result)
            }            
            performSegueWithIdentifier("unwindToStudy", sender: nil)
            
        case .Discarded, .Failed, .Saved:
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func taskViewController(taskViewController: ORKTaskViewController, viewControllerForStep step: ORKStep) -> ORKStepViewController? {
        if step is HealthDataStep {
            let healthStepViewController = HealthDataStepViewController(step: step)
            return healthStepViewController
        }
        return nil
    }
    
}