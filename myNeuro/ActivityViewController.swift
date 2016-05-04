/*
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import ResearchKit

// Used to simulate heart rate for simulator
var simHeartRate = false;

enum Activity: Int {
    case Survey, Microphone, Tapping, Walking, Reaction, HeartRate, Watch, Questionnaire
    
    static var allValues: [Activity] {
        var idx = 0
        let array = Array(AnyGenerator{ return self.init(rawValue: idx)})
        idx += 1
        return array
    }
    

    
    var title: String {
        switch self {
            case .Survey:
                return "Survey"
            case .Microphone:
                return "Microphone"
            case .Tapping:
                return "Tapping"
            case .Walking:
                return "Walking"
            case .Reaction:
                return "Reaction"
            case .HeartRate:
                return "Heart Rate"
            case .Watch:
                return "Watch"
            case .Questionnaire:
                return "Questionnaire"
        }
    }
    
    var subtitle: String {
        switch self {
            case .Survey:
                return "Answer 6 short questions"
            case .Microphone:
                return "Voice evaluation"
            case .Tapping:
                return "Test tapping speed"
            case .Walking:
                return "Test gait and balance"
            case .Reaction:
                return "Reaction speed test"
            // Developing
            case .HeartRate:
                return "Heart rate test"
            case .Watch:
                return "Watch data test"
            case .Questionnaire:
                return "Questionnaire"
        }
    }
}

class ActivityViewController: UITableViewController {
    
    // MARK: Properties
    
    var result: ORKResult?
    
    /**
     When a task is completed, the `TaskListViewController` calls this closure
     with the created task.
     */
    var taskResultFinishedCompletionHandler: (ORKResult -> Void)?
    
    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        
        return Activity.allValues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activityCell", forIndexPath: indexPath)
        
        if let activity = Activity(rawValue: indexPath.row) {
            cell.textLabel?.text = activity.title
            cell.detailTextLabel?.text = activity.subtitle
        }

        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let activity = Activity(rawValue: indexPath.row) else { return }
        
        let taskViewController: ORKTaskViewController

        switch activity {
            case .Survey:
                taskViewController = ORKTaskViewController(task: StudyTasks.surveyTask, taskRunUUID: NSUUID())
            case .Microphone:
                taskViewController = ORKTaskViewController(task: StudyTasks.microphoneTask, taskRunUUID: NSUUID())
            case .Tapping:
                taskViewController = ORKTaskViewController(task: StudyTasks.tappingTask, taskRunUUID: NSUUID())
            case .Walking:
                taskViewController = ORKTaskViewController(task: StudyTasks.walkingTask, taskRunUUID: NSUUID())
            case .Reaction:
                taskViewController = ORKTaskViewController(task: StudyTasks.reactionTask, taskRunUUID: NSUUID())
            case .HeartRate:
                taskViewController = ORKTaskViewController(task: StudyTasks.heartRateTask, taskRunUUID: NSUUID())
                simHeartRate = true;
            case .Watch:
                taskViewController = ORKTaskViewController(task: StudyTasks.watchTask, taskRunUUID: NSUUID())
                simHeartRate = true;
            case .Questionnaire:
                taskViewController = ORKTaskViewController(task: QuestionnaireTask, taskRunUUID: NSUUID())
        }
        
        do {
            let defaultFileManager = NSFileManager.defaultManager()
            
            // Identify the documents directory.
            let documentsDirectory = try defaultFileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            
            // Create a directory based on the `taskRunUUID` to store output from the task.
            let outputDirectory = documentsDirectory.URLByAppendingPathComponent(taskViewController.taskRunUUID.UUIDString)
            try defaultFileManager.createDirectoryAtURL(outputDirectory, withIntermediateDirectories: true, attributes: nil)
            
            taskViewController.outputDirectory = outputDirectory
        }
        catch let error as NSError {
            fatalError("The output directory for the task with UUID: \(taskViewController.taskRunUUID.UUIDString) could not be created. Error: \(error.localizedDescription)")
        }
        
        taskViewController.delegate = self
        navigationController?.presentViewController(taskViewController, animated: true, completion: nil)
        if simHeartRate == true {
            HealthDataStep.startMockHeartData()
        }
    }
}

extension ActivityViewController : ORKTaskViewControllerDelegate {
    
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        // Handle results using taskViewController.result
        if reason == .Failed {
            print(error!.localizedDescription)
        }
        if simHeartRate == true {
            HealthDataStep.stopMockHeartData()
            simHeartRate = false
        }
        let customTabBarController = self.tabBarController as! CustomTabBarController
        let model = customTabBarController.model
        model.result = taskViewController.result
        let navResult = customTabBarController.viewControllers![2] as! UINavigationController
        let resultViewController = navResult.topViewController as! ResultViewController
        let navAnalysis = customTabBarController.viewControllers![4] as! UINavigationController
        let analysisViewController = navAnalysis.topViewController as! AnalysisViewController
        print("Updating results/analysis tabs...")
        resultViewController.result = model.result
        analysisViewController.result = model.result
        
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
