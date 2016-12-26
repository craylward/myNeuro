//
//  AccelerometerInterfaceController.swift
//  myNeuro
//
//  Created by Shuichi Tsutsumi on 2015/06/13.
//  Copyright © 2015 Shuichi Tsutsumi. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity


class AccelerometerInterfaceController: WKInterfaceController {
    
    
    @IBOutlet weak var labelX: WKInterfaceLabel!
    @IBOutlet weak var labelY: WKInterfaceLabel!
    @IBOutlet weak var labelZ: WKInterfaceLabel!
    
    let motionManager = CMMotionManager()
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        motionManager.accelerometerUpdateInterval = 0.1
    }
    
    override func didAppear() {
        super.didAppear()
        // 1
        if WCSession.isSupported() {
            // 2
            session = WCSession.default()
            // 3
            session!.sendMessage(["accelerometer": "accelerometer"], replyHandler: { (response) -> Void in
                // 4
                if let response = response["accelReply"] as? Data {
                    print(response)
                }
                }, errorHandler: { (error) -> Void in
                    // 6
                    print(error)
            })
        }
    }

    
    override func willActivate() {
        super.willActivate()
        
        if motionManager.isAccelerometerAvailable {
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                self.labelX.setText(String(format: "%.2f", data!.acceleration.x))
                self.labelY.setText(String(format: "%.2f", data!.acceleration.y))
                self.labelZ.setText(String(format: "%.2f", data!.acceleration.z))
            } as! CMAccelerometerHandler
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: handler)
        }
        else {
            labelX.setText("not available")
            labelY.setText("not available")
            labelZ.setText("not available")
        }
    }
    
    override func didDeactivate() {
        
        super.didDeactivate()
        
        motionManager.stopAccelerometerUpdates()
    }
}

extension AccelerometerInterfaceController: WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    
}
