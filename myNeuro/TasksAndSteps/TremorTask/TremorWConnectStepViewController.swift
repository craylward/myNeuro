//
//  TremorWConnectStepViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 8/12/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreMotion
import WatchConnectivity

class TremorWConnectStepViewController: ORKWaitStepViewController, WCSessionDelegate
{
    var label = UILabel(frame: CGRectMake(0, 0, 200, 21))
    
    // ORKWaitStepViewController Functions
    static func stepViewControllerClass() -> TremorWConnectStepViewController.Type {
        return TremorWConnectStepViewController.self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        label.center = CGPointMake(self.view.frame.size.width  / 2, self.view.frame.size.height / 2);
//        label.textAlignment = NSTextAlignment.Center
//        label.text = "Waiting for watch app..."
//        self.view.addSubview(label)
        updateText("Waiting for Watch app")
//        setProgress(0.1, animated: true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupConnectivity()
        firstMessage()
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
    
    func firstMessage() {
        guard session != nil else { print("Can't send message! No session!"); return }
        if session!.reachable {
            session!.sendMessage(["command": 1], replyHandler: {reply in
                if reply["response"] as? Int == 1 {
                    self.goForward()
                }
                else {
                    print("Error starting task")
                }
                }, errorHandler: { error in print("Session error: \(error)")})
        } else {
            print("WCSession on Watch not reachable")
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let command = message["command"] as? Int
        if command == 1 {
            firstMessage()
        }
    }
}