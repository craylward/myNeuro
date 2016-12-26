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
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        
    }


    var fileURL: URL?
    var outputDir: URL?
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.continueButtonTitle = nil
        outputDir = taskViewController!.outputDirectory
        updateText("Waiting for task to finish")
        if session == nil {
            setupConnectivity()
        }
        session!.sendMessage(["command": 12], replyHandler: nil, errorHandler: { error in print("Session error after recording: \(error)")})
    }
    
    // Watch Connectivity
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
            print("WCSession is supported")
            if !(session!.isPaired) {
                print("Apple Watch is not paired")
            }
            if !(session!.isWatchAppInstalled) {
                print("Apple Watch app is not installed")
            }
        } else {
            print("Apple Watch connectivity is not supported on this device")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        do {
            let filePath = outputDir!.appendingPathComponent("tapping.json")
            let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: JSONSerialization.WritingOptions.prettyPrinted)
            try jsonData.write(to: filePath, options: .noFileProtection)
            let json = JSON(data: jsonData)
            let tappingResult = ORKTappingIntervalResult(identifier: "tappingW")
            tappingResult.samples = []
            for sample in json["samples"].arrayValue {
                let newSample = ORKTappingSample()
                newSample.timestamp = Double(sample["timestamp"].stringValue)!
                // IMPLEMENT DURATION CALCUATION ON THE WATCH: newSample.duration = Double(sample["duration"].stringValue)!
                switch sample["button_id"].stringValue {
                case "right":
                    newSample.buttonIdentifier = ORKTappingButtonIdentifier.right
                case "left":
                    newSample.buttonIdentifier = ORKTappingButtonIdentifier.left
                default:
                    print("button_id Not Recognized")
                }
                tappingResult.samples!.append(newSample)
            }
            
            let stepResult = super.result
            stepResult?.results?.append(tappingResult)
            result = stepResult
            
            goForward()
        }
        catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Message received but no follow up action")
    }
}
