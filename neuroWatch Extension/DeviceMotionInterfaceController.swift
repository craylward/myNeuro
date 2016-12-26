//
//  DeviceMotionInterfaceController.swift
//  watchOS2Sampler
//
//  Created by Shuichi Tsutsumi on 2015/08/22.
//  Copyright © 2015 Shuichi Tsutsumi. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

// ONLY COMPATIBLE WITH WATCHOS 3!!!

class DeviceMotionInterfaceController: WKInterfaceController {
    
    
    @IBOutlet weak var labelX: WKInterfaceLabel!
    @IBOutlet weak var labelY: WKInterfaceLabel!
    @IBOutlet weak var labelZ: WKInterfaceLabel!
    
    let motionManager = CMMotionManager()
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        let handler: CMDeviceMotionHandler = {(motion: CMDeviceMotion?, error: NSError?) -> Void in
        } as! CMDeviceMotionHandler
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: handler)
        }
        else {
            labelX.setText("not available")
            labelY.setText("not available")
            labelZ.setText("not available")
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        motionManager.stopDeviceMotionUpdates()
    }
    
}
