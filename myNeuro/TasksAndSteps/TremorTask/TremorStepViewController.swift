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

class TremorStepViewController: ORKActiveStepViewController, WCSessionDelegate
{
    var label = UILabel(frame: CGRectMake(0, 0, 200, 21))
    
    // ORKActiveStepViewController Functions
    static func stepViewControllerClass() -> TremorStepViewController.Type {
        return TremorStepViewController.self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConnectivity()
        
        label.center = CGPointMake(self.view.frame.size.width  / 2, self.view.frame.size.height / 2);
        label.textAlignment = NSTextAlignment.Center
        label.text = "Waiting for watch app..."
        self.view.addSubview(label)
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
    
    lazy var watchSamples = [WatchSample]()
    
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
        dispatch_async(dispatch_get_main_queue()) {
            self.label.text = "received"
            print(self.watchSamples)
            let sampleMessageText = "Received \(sampleCount) samples from watch. What do you want to do?"
            var replyText = ""
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
            let replyValues = ["status": replyText]
            replyHandler(replyValues)
        }
    }

}