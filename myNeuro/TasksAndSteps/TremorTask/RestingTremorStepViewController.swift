//
//  RestingTremorStepViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 6/29/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreMotion
import WatchConnectivity

class RestingTremorStepViewController: ORKActiveStepViewController
{
    
    lazy var watchSamples = [WatchSample]()
    
    // Watch Connectivity
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    // ORKActiveStepViewController Functions
    static func stepViewControllerClass() -> RestingTremorStepViewController.Type {
        return RestingTremorStepViewController.self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session?.sendMessage(["accelerometer":"start"], replyHandler: nil, errorHandler: nil)
        }
        
        print("test")
    }
    
}

extension RestingTremorStepViewController: WCSessionDelegate {
    // MARK:- Apple Watch connection
    
    
    private func setupConnectivity() {
        
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            print("WCSession is supported")
            
            if !session.paired {
                print("Apple Watch is not paired")
            }
            
            if !session.watchAppInstalled {
                print("Apple Watch app is not installed")
            }
        } else {
            print("Apple Watch connectivity is not supported on this device")
        }
    }
    
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        let receivedWatchSamples = message as! [String: [Double]]
        let accX = receivedWatchSamples["accX"]
        let accY = receivedWatchSamples["accY"]
        let accZ = receivedWatchSamples["accZ"]
        let sampleCount = accX!.count // TODO: make independent of one single variable
        
        for i in 0..<sampleCount {
            let watchSample = WatchSample(accX: accX![i], accY: accY![i], accZ: accZ![i])
            watchSamples.append(watchSample)
        }
        
        let sampleMessageText = "Received \(sampleCount) samples from watch. What do you want to do?"
        var replyText = ""
        
        dispatch_async(dispatch_get_main_queue() ) {
            
            if self.watchSamples.count > 0 {
                replyText = "Data sent!"
                //self.showAlertAfterRecording("Watch Data received", messageText: sampleMessageText, showContinueOption: false, useWatchSamples: true)
            } else {
                replyText = "Error sending data"
                let alertController = UIAlertController(title: "No data received", message: "Tremor samples could not be loaded from Apple Watch", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        let replyValues = ["status": replyText]
        replyHandler(replyValues)
    }

}