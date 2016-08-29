//
//  FingerTappingInterfaceController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 8/15/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
//
//  InterfaceController.swift
//  Park_App_v6 WatchKit Extension
//
//  Created by Classroom Tech User on 2/28/16.
//  Copyright © 2016 CalPolyCPE461. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class FingerTappingInterfaceController: WKInterfaceController {
    

    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var leftButtonOutlet: WKInterfaceButton!
    @IBOutlet var rightButtonOutlet: WKInterfaceButton!
    
    var myTimer : NSTimer?  //internal timer to keep track
    var isPaused = true //flag to determine if timer has started or not
    var startTime = NSTimeInterval()
    var duration : NSTimeInterval = 10.0 //arbitrary start number.
    var leftClickTime : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var leftFirst = false
    var rightFirst = false
    var count : Double = 0
    var totalSeconds : Double = 0
    var totalMilSeconds : Int = 0
    var samples: [NSDictionary] = []
    
    override func didAppear() {
        super.didAppear()
        setupConnectivity()
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
            session!.sendMessage(["command": 1], replyHandler: nil, errorHandler: { error in print(error) })
        }
    }

    @IBAction func leftButton() {
        if isPaused {
            initTimer()
            rightFirst = true
        }
        
        let timestamp = calculateTimeDifference()
        rightButtonOutlet.setEnabled(true)
        leftButtonOutlet.setEnabled(false)
        samples.append(["timestamp": timestamp, "button_id": "left"])
    }
    
    @IBAction func rightButton() {
        if isPaused {
            initTimer()
            leftFirst = true
        }
        
        let timestamp = calculateTimeDifference()
        rightButtonOutlet.setEnabled(false)
        leftButtonOutlet.setEnabled(true)
        samples.append(["timestamp": timestamp, "button_id": "right"])
    }
    
    func initTimer() {
        myTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(self.finish), userInfo: nil, repeats: false)
        timer.setDate(NSDate(timeIntervalSinceNow: duration ))
        timer.start()
        isPaused = false
        label.setText("Begin!")
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func calculateTimeDifference() -> Double {
        if (count++ != 0) {
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime: NSTimeInterval = currentTime - startTime
            
            totalSeconds += Double(elapsedTime)
            startTime = NSDate.timeIntervalSinceReferenceDate()
            
        }
        return totalSeconds
    }
    
    func finish() {
        rightButtonOutlet.setEnabled(false)
        leftButtonOutlet.setEnabled(false)
        session!.transferUserInfo(["samples": samples])
        session!.sendMessage(["command":2], replyHandler: nil, errorHandler: { error in print(error)})
    }
}

extension FingerTappingInterfaceController: WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let command = message["command"] as? Int
        if command == 1 {
            replyHandler(["response": 1])
        }
        else if command == 2 {
            print("Second message sent with a reply handler")
        }
    }
    
    // Use if replyHandler from sender is nil
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let command = message["command"] as? Int
        if command == 1 {
            print("First message sent with no reply handler")
        }
        else if command == 2  || command == 3 {
            print(command)
        }
        else {
            print(command)
        }
    }
    
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        //print(userInfoTransfer.userInfo)
        if error != nil {
            print("error: ", error)
        }
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        print("error: ", error)
    }
}
