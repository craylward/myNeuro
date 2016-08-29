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
    // ORKWaitStepViewController Functions
    static func stepViewControllerClass() -> BradyStepWViewController.Type {
        return BradyStepWViewController.self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let command = message["command"] as? Int
        if command == 2 {
            goForward()
        }
    }
}