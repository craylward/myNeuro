//
//  TremorInterfaceController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/11/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation
import CoreMotion
import HealthKit

class TremorTaskInterfaceController: WKInterfaceController {

    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var label: WKInterfaceLabel!
    let accelManager = CMSensorRecorder()
    let motionManager = CMMotionManager()
    var arrayOfDicts:[NSDictionary] = []
    var type: String?
    let healthStore = HKHealthStore()
    var myTimer : NSTimer?  //internal timer to keep track
    var startTime = NSDate()
    var duration : NSTimeInterval = 10.0 //arbitrary number. 5 seconds
    var dataSent = false
    var started = false
    var connected = false
    
    // Need workout session object to keep recording while watch display is off
    var workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Other, locationType: HKWorkoutSessionLocationType.Unknown)
    
    override func didAppear() {
        super.didAppear()
        label.setText("Connecting...")
        timer.setDate(NSDate(timeIntervalSinceNow: duration))
        setupConnectivity()
    }
    
    override func willActivate() {
        super.willActivate()
        if started == true && dataSent == true {
            label.setText("Done!")
        }
        else if started == true && dataSent == false {
            label.setText("Recording...")
        }
        else if started == false && dataSent == false && connected == true {
            label.setText("Connected!")
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
            session!.sendMessage(["command": 1], replyHandler: nil, errorHandler: { error in print(error) })
        }
    }
    
    func initTimer() {
        label.setText("Recording...")
        started = true
        dataSent = false
        myTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(self.finish), userInfo: nil, repeats: false)
        timer.setDate(NSDate(timeIntervalSinceNow: duration))
        timer.start()
        toggleCollecting() // ON
        
    }
    
    func finish() {
        toggleCollecting() // OFF
        label.setText("Done!")
    }
    
    func toggleCollecting() {
        workoutSession.delegate = self
        switch workoutSession.state {
        case .NotStarted:
            healthStore.startWorkoutSession(workoutSession)
        case .Running:
            healthStore.endWorkoutSession(workoutSession)
        case .Ended:
            workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Other, locationType: HKWorkoutSessionLocationType.Unknown)
            workoutSession.delegate = self
            healthStore.startWorkoutSession(workoutSession)
        }
    }
    
    func startMotionManager() {
        WKInterfaceDevice.currentDevice().playHaptic(.Start)
        self.arrayOfDicts = []
        if motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                self.arrayOfDicts.append([
                    "timestamp":data!.timestamp,
                    "x":data!.acceleration.x,
                    "y":data!.acceleration.y,
                    "z":data!.acceleration.z
                    ])
                //print("timestamp: ", data!.timestamp, ", x: ", data!.acceleration.x, ", y: ", data!.acceleration.y, ", z: ", data!.acceleration.z)
            }
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: handler)
        }
    }
    
    func stopMotionManager() {
        WKInterfaceDevice.currentDevice().playHaptic(.Stop)
        motionManager.stopAccelerometerUpdates()
        if session != nil {
            session!.transferUserInfo(["items" : arrayOfDicts])
        }
    }    
}

extension TremorTaskInterfaceController: HKWorkoutSessionDelegate, WCSessionDelegate {
    
    // Workout session changed state
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        switch toState {
        case .Running:
            startMotionManager()
        case .Ended:
            stopMotionManager()
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    // Error workoutSession
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        NSLog("Workout error: \(error.userInfo)")
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let command = message["command"] as? Int
        if command == 1 { // If command == 1, watch is connected
            if type == nil {
                replyHandler(["response": 1])
                label.setText("Connected!")
                connected = true
            }
        }
        else if command == 2 {
            print("Second message sent with a reply handler")
        }
        else {
            print("Message received. Unknown command")
        }
    }
    
    // Use if replyHandler from sender is nil
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let command = message["command"] as? Int
        if command == 1 {
            print("First message sent with no reply handler")
        }
        else if command == 2 { // If command == 2, start timer
            type = message["type"] as? String
            dispatch_async(dispatch_get_main_queue()) {
                self.initTimer()
            }
        }
        else {
            print("Message received. Unknown command")
        }
    }
    
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        if error != nil {
            print("error: ", error)
        }
        else {
            print("Data sent!")
            dataSent = true
        }
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        print("error: ", error)
    }
}