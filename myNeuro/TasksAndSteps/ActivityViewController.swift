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
import WatchConnectivity

// Used to simulate heart rate for simulator
var simHeartRate = false;
let tappingDuration = NSTimeInterval(5)

enum Activity: Int {
    case Questionnaire, Tremor, Bradykinesia, Gait, TremorWatch, BradykinesiaWatch  //, HeartRate
    
    static var allValues: [Activity] {
        var idx = 0
        return Array(AnyGenerator{ return self.init(rawValue: idx++)})
    }
    
    var title: String {
        switch self {
            case .Questionnaire:
                return "Questionnaire"
            case .Tremor:
                return "Tremor"
            case .Bradykinesia:
                return "Bradykinesia"
            case .Gait:
                return "Gait"
            case .TremorWatch:
                return "Tremor (Watch)"
            case .BradykinesiaWatch:
                return "Bradykinesia (Watch)"
//            case .HeartRate:
//                return "Heart Rate"

        }
    }
    
    var subtitle: String {
        switch self {
            case .Questionnaire:
                return "Questionnaire"
            case .Tremor:
                return "Test Tremor"
            case .Bradykinesia:
                return "Test Bradykinesia"
            case .Gait:
                return "Test gait and balance"
            case .TremorWatch:
                return "Test Tremor (Apple Watch)"
            case .BradykinesiaWatch:
                return "Test Bradykinesia (Apple Watch)"
            // Developing
//            case .HeartRate:
//                return "Heart rate test"
        }
    }
}

class ActivityViewController: UITableViewController, WCSessionDelegate {
    
    // MARK: Properties
    
    var result: ORKResult?
    
    //Watch Connectivity
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
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
        
        // WatchConnectivity
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
        }

        switch activity {
            case .Questionnaire:
                taskViewController = ORKTaskViewController(task: QuestionnaireTask, taskRunUUID: NSUUID())
            case .Bradykinesia:
                taskViewController = ORKTaskViewController(task: BradykinesiaTask, taskRunUUID: NSUUID())
            case .Tremor:
                taskViewController = ORKTaskViewController(task: TremorTask, taskRunUUID: NSUUID())
            case .Gait:
                taskViewController = ORKTaskViewController(task: GaitTask, taskRunUUID: NSUUID())
            case .BradykinesiaWatch:
                taskViewController = ORKTaskViewController(task: BradykinesiaTask, taskRunUUID: NSUUID())
            case .TremorWatch:
                taskViewController = ORKTaskViewController(task: TremorTaskWatch, taskRunUUID: NSUUID())
//            case .HeartRate:
//                taskViewController = ORKTaskViewController(task: StudyTasks.heartRateTask, taskRunUUID: NSUUID())
//                simHeartRate = true;


        }
        
        do {
            let defaultFileManager = NSFileManager.defaultManager()
            
            // Identify the documents directory.
            let documentsDirectory = try defaultFileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            
            // Create a directory based on the `taskRunUUID` to store output from the task.
            let outputDirectory = documentsDirectory.URLByAppendingPathComponent(taskViewController.taskRunUUID.UUIDString)
            try defaultFileManager.createDirectoryAtURL(outputDirectory, withIntermediateDirectories: true, attributes: nil)
            
            NSLog("url = %@",outputDirectory)
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
        // Developing: used to simulate a heart beat
//        if simHeartRate == true {
//            HealthDataStep.stopMockHeartData()
//            simHeartRate = false
//        }
        
        // MARK: Update results and analysis tabs
        else if reason == .Completed {
            if taskViewController.task?.identifier == "TremorTask" {
                processTremorFiles(ResultParser.findFiles(taskViewController.result))
            }
            else if taskViewController.task?.identifier == "BradykinesiaTask" {
                processBradykinesia(taskViewController.result)
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
        }
        // MARK: Save results
        

        
        taskViewController.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
