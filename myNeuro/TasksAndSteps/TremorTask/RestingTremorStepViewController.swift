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
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {

    }
}