//
//  AccelerometerStepViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/4/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import CoreMotion

class AccelerometerStepViewController: ORKActiveStepViewController
{

    var movementManager = CMMotionManager()
    var count = 0
    
    // ORKActiveStepViewController Functions
    static func stepViewControllerClass() -> AccelerometerStepViewController.Type {
        return AccelerometerStepViewController.self
    }
    
    override func start() {
        super.start()
        
        movementManager.gyroUpdateInterval = 0.1
        movementManager.accelerometerUpdateInterval = 0.01
        
        //Start Recording Data
        
        movementManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.outputAccData(accelerometerData!.acceleration)
            self.count += 1
            if(NSError != nil) {
                print("\(NSError)")
            }
        }
        
        movementManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            self.outputRotData(gyroData!.rotationRate)
            if (NSError != nil){
                print("\(NSError)")
            }
            
            
        })
    }
        
    override func stepDidFinish() {
        super.stepDidFinish()
        movementManager.stopDeviceMotionUpdates()
        movementManager.stopAccelerometerUpdates()
        movementManager.stopGyroUpdates()
    }
    
    
    //Instance Variables
    
    var currentMaxAccelX: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    
    
    //Outlets
    
    @IBOutlet var accX: UILabel!
    @IBOutlet var accY: UILabel!
    @IBOutlet var accZ: UILabel!
    @IBOutlet var maxAccX: UILabel!
    @IBOutlet var maxAccY: UILabel!
    @IBOutlet var maxAccZ: UILabel!
    
    @IBOutlet var rotX: UILabel!
    @IBOutlet var rotY: UILabel!
    @IBOutlet var rotZ: UILabel!
    @IBOutlet var maxRotX: UILabel!
    @IBOutlet var maxRotY: UILabel!
    @IBOutlet var maxRotZ: UILabel!
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
//        var paintView = UIView(frame:CGRectZero)
//        paintView.backgroundColor = UIColor.blueColor()
//        // let container = self.view
//        let container = paintView
//        customView = paintView
//        customView?.translatesAutoresizingMaskIntoConstraints = false


    }

    
    func outputAccData(acceleration: CMAcceleration){
        
        // accX?.text = "\(acceleration.x)g"
        if fabs(acceleration.x) > fabs(currentMaxAccelX)
        {
            currentMaxAccelX = acceleration.x
        }
        
        // accY?.text = "\(acceleration.y)g"
        if fabs(acceleration.y) > fabs(currentMaxAccelY)
        {
            currentMaxAccelY = acceleration.y
        }
        
        // accZ?.text = "\(acceleration.z)g"
        if fabs(acceleration.z) > fabs(currentMaxAccelZ)
        {
            currentMaxAccelZ = acceleration.z
        }
        
        
        // maxAccX?.text = "\(currentMaxAccelX)"
        // maxAccY?.text = "\(currentMaxAccelY)"
        // maxAccZ?.text = "\(currentMaxAccelZ)"
        let output = "x:" + String(acceleration.x) + " y: " + String(acceleration.y) + " z: " + String(acceleration.z)
        print(output)
    }
    
    func outputRotData(rotation: CMRotationRate){
        
        
        rotX?.text = "\(rotation.x)r/s"
        if fabs(rotation.x) > fabs(currentMaxRotX)
        {
            currentMaxRotX = rotation.x
        }
        
        rotY?.text = "\(rotation.y)r/s"
        if fabs(rotation.y) > fabs(currentMaxRotY)
        {
            currentMaxRotY = rotation.y
        }
        
        rotZ?.text = "\(rotation.z)r/s"
        if fabs(rotation.z) > fabs(currentMaxRotZ)
        {
            currentMaxRotZ = rotation.z
        }
        
        maxRotX?.text = "\(currentMaxRotX)"
        maxRotY?.text = "\(currentMaxRotY)"
        maxRotZ?.text = "\(currentMaxRotZ)"
        
        
    }

}