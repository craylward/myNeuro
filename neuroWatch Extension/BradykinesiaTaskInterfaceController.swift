//
//  FingerTappingInterfaceController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 8/15/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import WatchKit
import Foundation
import WatchConnectivity

class BradykinesiaTaskInterfaceController: WKInterfaceController {
    

    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var leftButtonOutlet: WKInterfaceButton!
    @IBOutlet var rightButtonOutlet: WKInterfaceButton!
    
    var myTimer : Timer?  //internal timer to keep track
    var isPaused = true //flag to determine if timer has started or not
    var startTime = TimeInterval()
    var duration : TimeInterval = 10.0 //arbitrary start number.
    var leftClickTime : UserDefaults = UserDefaults.standard
    var leftFirst = false
    var rightFirst = false
    var count : Double = 0
    var totalSeconds : Double = 0
    var totalMilSeconds : Int = 0
    var samples: [NSDictionary] = []
    
    override func didAppear() {
        label.setText("Waiting...")
        super.didAppear()
        leftButtonOutlet.setEnabled(false)
        rightButtonOutlet.setEnabled(false)
        setupConnectivity()
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
            session!.sendMessage(["command": 1], replyHandler: nil, errorHandler: { error in print(error) })
        }
    }

    @IBAction func leftButton() {
        if isPaused {
            label.setText("")
            initTimer()
            rightFirst = true
        }
        
        let timestamp = calculateTimeDifference()
        samples.append(["timestamp": timestamp, "button_id": "left"])
    }
    
    @IBAction func rightButton() {
        if isPaused {
            label.setText("")
            initTimer()
            leftFirst = true
        }
        
        let timestamp = calculateTimeDifference()
        samples.append(["timestamp": timestamp, "button_id": "right"])
    }
    
    func initTimer() {
        myTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.finish), userInfo: nil, repeats: false)
        timer.setDate(Date(timeIntervalSinceNow: duration ))
        timer.start()
        isPaused = false
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    func calculateTimeDifference() -> Double {
        if (count != 0) {
            let currentTime = Date.timeIntervalSinceReferenceDate
            let elapsedTime: TimeInterval = currentTime - startTime
            
            totalSeconds += Double(elapsedTime)
            startTime = Date.timeIntervalSinceReferenceDate
        }
        count += 1
        return totalSeconds
    }
    
    func finish() {
        label.setText("Done!")
        rightButtonOutlet.setEnabled(false)
        leftButtonOutlet.setEnabled(false)
        session!.transferUserInfo(["samples": samples])
    }
}

extension BradykinesiaTaskInterfaceController: WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        let command = message["command"] as? Int
        if command == 11 {
            replyHandler(["response": 11])
        }
        else {
            print("Message received with replyHandler")
        }
    }
    
    // Use if replyHandler from sender is nil
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let command = message["command"] as? Int
        if command == 12 {
            label.setText("Begin!")
            rightButtonOutlet.setEnabled(true)
            leftButtonOutlet.setEnabled(true)
        }
        else {
            print("Message received with no replyHandler")
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        //print(userInfoTransfer.userInfo)
        if error != nil {
            print("error: ", error!)
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("error: ", error!)
    }
}
