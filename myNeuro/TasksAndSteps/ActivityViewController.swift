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
import CoreData

// Used to simulate heart rate for simulator
var simHeartRate = false;
let tappingDuration = TimeInterval(5)
var reachable = false
var tryInternet = true
var uploadDataEnabled = true

enum Activity: Int {
    case questionnaire, tremor, bradykinesia, gait, tremorWatch, bradykinesiaWatch  //, HeartRate
    
    static var allValues: [Activity] {
        var idx = 0
        return Array(AnyIterator{ let temp = self.init(rawValue: idx); idx += 1; return temp})
    }
    
    var title: String {
        switch self {
            case .questionnaire:
                return "Questionnaire"
            case .tremor:
                return "Tremor"
            case .bradykinesia:
                return "Bradykinesia"
            case .gait:
                return "Gait"
            case .tremorWatch:
                return "Tremor (Watch)"
            case .bradykinesiaWatch:
                return "Bradykinesia (Watch)"
//            case .HeartRate:
//                return "Heart Rate"

        }
    }
    
    var subtitle: String {
        switch self {
            case .questionnaire:
                return "Questionnaire"
            case .tremor:
                return "Test Tremor"
            case .bradykinesia:
                return "Test Bradykinesia"
            case .gait:
                return "Test gait and balance"
            case .tremorWatch:
                return "Test Tremor (Apple Watch)"
            case .bradykinesiaWatch:
                return "Test Bradykinesia (Apple Watch)"
            // Developing
//            case .HeartRate:
//                return "Heart rate test"
        }
    }
}

class ActivityViewController: UITableViewController, WCSessionDelegate {
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {

    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        
    }
    
    // MARK: Properties
    var result: ORKResult?
    let defaultFileManager = FileManager.default

    //Watch Connectivity
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    /**
     When a task is completed, the `TaskListViewController` calls this closure
     with the created task.
     */
    var taskResultFinishedCompletionHandler: ((ORKResult) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        return Activity.allValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        
        if let activity = Activity(rawValue: indexPath.row) {
            cell.textLabel?.text = activity.title
            cell.detailTextLabel?.text = activity.subtitle
        }

        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activity = Activity(rawValue: indexPath.row) else { return }
        
        let taskViewController: ORKTaskViewController

        switch activity {
            case .questionnaire:
                taskViewController = ORKTaskViewController(task: QuestionnaireTask, taskRun: UUID())
            case .bradykinesia:
                taskViewController = ORKTaskViewController(task: BradykinesiaTask, taskRun: UUID())
            case .tremor:
                taskViewController = ORKTaskViewController(task: TremorTask, taskRun: UUID())
            case .gait:
                taskViewController = ORKTaskViewController(task: GaitTask, taskRun: UUID())
            case .bradykinesiaWatch:
                taskViewController = ORKTaskViewController(task: BradyTaskW, taskRun: UUID())
            case .tremorWatch:
                taskViewController = ORKTaskViewController(task: TremorTaskW, taskRun: UUID())
            
//            case .HeartRate:
//                taskViewController = ORKTaskViewController(task: StudyTasks.heartRateTask, taskRunUUID: NSUUID())
//                simHeartRate = true;

        }
        
        do {
            // Identify the documents directory.
            let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // Create a directory based on the `taskRunUUID` to store output from the task.
            let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
            try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
            
            print("url = %@",outputDirectory)
            taskViewController.outputDirectory = outputDirectory
        }
        catch let error as NSError {
            fatalError("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
        }
        taskViewController.delegate = self
        navigationController?.present(taskViewController, animated: true, completion: nil)
        if simHeartRate == true {
            HealthDataStep.startMockHeartData()
        }
    }
}

extension ActivityViewController : ORKTaskViewControllerDelegate {
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
     */
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        // Handle results using taskViewController.result
        if reason == .failed {
            print(error!.localizedDescription)
        }
            // Developing: used to simulate a heart beat
            //        if simHeartRate == true {
            //            HealthDataStep.stopMockHeartData()
            //            simHeartRate = false
            //        }
            
            // MARK: Update results and analysis tabs
        else if reason == .completed {
            coreData.privateObjectContext.perform { () -> Void in
                coreData.mainObjectContext.perform {
                    NotificationCenter.default.post(name: NSNotification.Name("processingResults"), object: nil)
                }
                ResultProcessor().processResult(taskViewController.result)
                coreData.savePrivateContext()
                coreData.mainObjectContext.perform {
                    NotificationCenter.default.post(name: NSNotification.Name("finishedProcessing"), object: nil)
                }

            }
            //print("Updating results tabs...")
            //let customTabBarController = self.tabBarController as! CustomTabBarController
            //let navResult = customTabBarController.viewControllers![2] as! UINavigationController
            //let resultViewController = navResult.topViewController as! ResultViewController
            //resultViewController.result = taskViewController.result
            
        }
        taskViewController.dismiss(animated: true, completion: nil)
        
    }
}
