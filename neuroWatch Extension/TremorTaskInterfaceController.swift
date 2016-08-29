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
    @IBOutlet var recordButton: WKInterfaceButton!

    let accelManager = CMSensorRecorder()
    let motionManager = CMMotionManager()
    var arrayOfDicts:[NSDictionary] = []
    var type: String?
    let healthStore = HKHealthStore()
    
    // Need workout session object to keep recording while watch display is off
    var workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Other, locationType: HKWorkoutSessionLocationType.Unknown)

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
    
//    @IBAction func recordPressed() {
//        toggleCollecting()
//    }
    
    func toggleCollecting() {
        workoutSession.delegate = self
        switch workoutSession.state {
        case .NotStarted:
            healthStore.startWorkoutSession(workoutSession)
        case .Running:
            healthStore.endWorkoutSession(workoutSession)
        case .Ended:
            workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Other, locationType: HKWorkoutSessionLocationType.Unknown)
            healthStore.startWorkoutSession(workoutSession)
        }
    }
    
    func startMotionManager() {
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
        if command == 1 {
            if type == nil {
                replyHandler(["response": 1])
            }
            else {
                replyHandler(["response": 4])
            }
        }
        else if command == 2 {
            print("Second message sent with a reply handler")
        }
    }
    
    // Use if replyHandler from sender is nil
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let command = message["command"] as? Int
        
        print(command)
        if command == 1 {
            print("First message sent with no reply handler")
        }
        else if command == 2  || command == 3 {
            if command == 2 {
                type = message["type"] as? String
            }
            toggleCollecting()
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