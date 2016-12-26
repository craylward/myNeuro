//
//  TremorStepViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/11/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreMotion
import WatchConnectivity

class TremorStepWViewController: ORKWaitStepViewController, WCSessionDelegate //ORKActiveStepViewController
{
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    // ORKActiveStepViewController Functions
    static func stepViewControllerClass() -> TremorStepWViewController.Type {
        return TremorStepWViewController.self
    }
    
    var startTime: Date?
    var endTime: Date?
    var fileURL: URL?
    var outputDir: URL?
    var fileResult: ORKFileResult?
    var _result: ORKStepResult?
    override var result: ORKStepResult? {
        get {
            if _result == nil {
                return super.result
            }
            else {
                return _result
            }
        }
        set {
            _result = newValue
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if session == nil {
            setupConnectivity()
        }        
        outputDir = taskViewController!.outputDirectory
        startTime = Date()
        print(self.step!.identifier)
        session!.sendMessage(["command": 2, "type": self.step!.identifier], replyHandler: nil, errorHandler: { error in print(error) })
        //start()
    }
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }
    private func setupConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default()
            session?.activate()
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("Received file. No follow up code.")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        do {            
            let filePath = outputDir!.appendingPathComponent(self.step!.identifier + "_accel.json")
            let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
            try jsonData.write(to: filePath, options: .noFileProtection)
            endTime = Date()
            let fileResult = ORKFileResult(identifier:"acc")
            fileResult.fileURL = outputDir!.appendingPathComponent(self.step!.identifier + "_accel.json")
            fileResult.contentType = "application/json"
            fileResult.startDate = startTime!
            fileResult.endDate = endTime!
            
            let stepResult = super.result
            stepResult?.results?.append(fileResult)
            result = stepResult
            
            goForward()
        }
        catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    


}
