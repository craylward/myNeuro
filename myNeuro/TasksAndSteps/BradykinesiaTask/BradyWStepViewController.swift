//
//  BradyWStepViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 8/16/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreMotion
import WatchConnectivity

class BradyStepWViewController: ORKWaitStepViewController, WCSessionDelegate
{
    
    var fileURL: NSURL?
    var outputDir: NSURL?
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
    
    // ORKWaitStepViewController Functions
    static func stepViewControllerClass() -> BradyStepWViewController.Type {
        return BradyStepWViewController.self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        outputDir = taskViewController!.outputDirectory
        updateText("Waiting for task to finish")
        if session == nil {
            setupConnectivity()
        }
    }
    
    // Watch Connectivity
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    private func setupConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            print("WCSession is supported")
            if !(session!.paired) {
                print("Apple Watch is not paired")
            }
            if !(session!.watchAppInstalled) {
                print("Apple Watch app is not installed")
            }
        } else {
            print("Apple Watch connectivity is not supported on this device")
        }
    }
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        do {
            session.sendMessage(["command": 9], replyHandler: nil, errorHandler: { error in print("Session error after recording: \(error)")})
            let filePath = outputDir!.URLByAppendingPathComponent(self.step!.identifier + "_fingertapping.json")
            let jsonData = try NSJSONSerialization.dataWithJSONObject(userInfo, options: NSJSONWritingOptions.PrettyPrinted)
            try jsonData.writeToURL(filePath, options: .DataWritingFileProtectionNone)
            let json = JSON(data: jsonData)
            let tappingResult = ORKTappingIntervalResult(identifier: "tappingW")
            tappingResult.samples = []
            for sample in json["samples"].arrayValue {
                let newSample = ORKTappingSample()
                newSample.timestamp = Double(sample["timestamp"].stringValue)!
                // IMPLEMENT DURATION CALCUATION ON THE WATCH: newSample.duration = Double(sample["duration"].stringValue)!
                switch sample["button_id"].stringValue {
                case "right":
                    newSample.buttonIdentifier = ORKTappingButtonIdentifier.Right
                case "left":
                    newSample.buttonIdentifier = ORKTappingButtonIdentifier.Left
                default:
                    print("button_id Not Recognized")
                }
                tappingResult.samples!.append(newSample)
            }
            
            let stepResult = super.result
            stepResult?.results?.append(tappingResult)
            result = stepResult
            
            
            session.sendMessage(["command": 10], replyHandler: nil, errorHandler: { error in print("Session error after recording: \(error)")})
            
        }
        catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let command = message["command"] as? Int
        if command == 2 {
            goForward()
        }
    }
}