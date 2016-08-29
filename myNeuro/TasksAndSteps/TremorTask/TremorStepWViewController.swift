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

class TremorStepWViewController: ORKActiveStepViewController, WCSessionDelegate
{    
    // ORKActiveStepViewController Functions
    static func stepViewControllerClass() -> TremorStepWViewController.Type {
        return TremorStepWViewController.self
    }
    
    var startTime: NSDate?
    var endTime: NSDate?
    var fileURL: NSURL?
    var outputDir: NSURL?
    var fileResult: ORKFileResult?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if session == nil {
            setupConnectivity()
        }        
        outputDir = taskViewController!.outputDirectory
        startTime = NSDate()
        print(self.step!.identifier)
        session!.sendMessage(["command": 2, "type": self.step!.identifier], replyHandler: nil, errorHandler: { error in print(error) })
    }
    
    
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
        }
    }
    override func stepDidFinish() {
        super.stepDidFinish()
        endTime = NSDate()
        session!.sendMessage(["command": 3], replyHandler: nil, errorHandler: { error in print("Session error after recording: \(error)")})
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("Received file. No follow up code.")
    }
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        do {
            session.sendMessage(["command": 9], replyHandler: nil, errorHandler: { error in print("Session error after recording: \(error)")})
            let filePath = outputDir!.URLByAppendingPathComponent(self.step!.identifier + "_accel.json")
            let jsonData = try NSJSONSerialization.dataWithJSONObject(userInfo, options: NSJSONWritingOptions.PrettyPrinted)
            try jsonData.writeToURL(filePath, options: .DataWritingFileProtectionNone)
            session.sendMessage(["command": 10], replyHandler: nil, errorHandler: { error in print("Session error after recording: \(error)")})
            fileResult!.fileURL = filePath
            fileResult!.contentType = "application/json"
            fileResult!.startDate = startTime!
            fileResult!.endDate = endTime!
        }
        catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    
    override var result: ORKStepResult? {
            let sResult = super.result
            var results = sResult?.results
            fileResult = ORKFileResult(identifier: self.step!.identifier)
            results?.append(fileResult!)
            sResult?.results = results
            return sResult

    }

}