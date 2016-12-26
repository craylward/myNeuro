//
//  WatchConnectStepViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 8/12/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreMotion
import WatchConnectivity

class BradyConnectWStepViewController: ORKWaitStepViewController, WCSessionDelegate
{
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {

    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
    }

    var label = UILabel(frame: CGRect(x:0, y:0, width:200, height:21))
    
    // ORKWaitStepViewController Functions
    static func stepViewControllerClass() -> BradyConnectWStepViewController.Type {
        return BradyConnectWStepViewController.self
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupConnectivity()
        firstMessage()
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
    fileprivate func setupConnectivity() {
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
            let alert = UIAlertController(title: "Error", message: "Apple Watch connectivity is not supported on this device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){}
        }
    }
    
    func firstMessage() {
        guard session != nil else { print("Can't send message! No session!"); return }
        if session!.isReachable {
            session!.sendMessage(["command": 11], replyHandler: {reply in
                if reply["response"] as? Int == 11 {
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let command = message["command"] as? Int
        if command == 1 {
            firstMessage()
        }
    }
}
