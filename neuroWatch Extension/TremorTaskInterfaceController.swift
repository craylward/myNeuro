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
    var myTimer : Timer?  //internal timer to keep track
    var startTime = Date()
    var duration : TimeInterval = 10.0 //arbitrary number. 5 seconds
    var dataSent = false
    var started = false
    var connected = false
    
    // Need workout session object to keep recording while watch display is off
    var workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.other, locationType: HKWorkoutSessionLocationType.unknown)
    
    override func didAppear() {
        super.didAppear()
        label.setText("Connecting...")
        timer.setDate(Date(timeIntervalSinceNow: duration))
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
                session.activate()
            }
        }
    }
    
    private func setupConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default()
            session!.activate()
            session!.sendMessage(["command": 1], replyHandler: nil, errorHandler: { error in print(error) })
        }
    }
    
    func initTimer() {
        label.setText("Recording...")
        started = true
        dataSent = false
        myTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.finish), userInfo: nil, repeats: false)
        timer.setDate(Date(timeIntervalSinceNow: duration))
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
        case .notStarted:
            healthStore.start(workoutSession)
        case .running:
            healthStore.end(workoutSession)
        case .ended:
            workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.other, locationType: HKWorkoutSessionLocationType.unknown)
            workoutSession.delegate = self
            healthStore.start(workoutSession)
        default:
            break
        }
    }
    
    func startMotionManager() {
        WKInterfaceDevice.current().play(.start)
        self.arrayOfDicts = []
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: Error?) -> Void in
                self.arrayOfDicts.append([
                    "timestamp":data!.timestamp,
                    "x":data!.acceleration.x,
                    "y":data!.acceleration.y,
                    "z":data!.acceleration.z
                    ])
                //print("timestamp: ", data!.timestamp, ", x: ", data!.acceleration.x, ", y: ", data!.acceleration.y, ", z: ", data!.acceleration.z)
            }
            motionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler: handler)
        }
    }
    
    func stopMotionManager() {
        WKInterfaceDevice.current().play(.stop)
        motionManager.stopAccelerometerUpdates()
        if session != nil {
            session!.transferUserInfo(["items" : arrayOfDicts])
        }
    }    
}

extension TremorTaskInterfaceController: HKWorkoutSessionDelegate, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    
    // Workout session changed state
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            startMotionManager()
        case .ended:
            stopMotionManager()
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    // Error workoutSession
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Do nothing for now
        NSLog("Workout error: \(error._userInfo)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
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
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let command = message["command"] as? Int
        if command == 1 {
            print("First message sent with no reply handler")
        }
        else if command == 2 { // If command == 2, start timer
            type = message["type"] as? String
            DispatchQueue.main.async {
                self.initTimer()
            }
        }
        else {
            print("Message received. Unknown command")
        }
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if error != nil {
            print("error: ", error!)
        }
        else {
            print("Data sent!")
            dataSent = true
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        print("error: ", error!)
    }
}
