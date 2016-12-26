//
//  InterfaceController.swift
//  neuroWatch Extension
//
//  Created by Charlie Aylward on 7/7/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

let kItemKeyTitle       = "title"
let kItemKeyDetail      = "detail"
let kItemKeyClassPrefix = "prefix"

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }


    @IBOutlet weak var table: WKInterfaceTable!
    var items: [Dictionary<String, String>]!
    

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        // Configure interface objects here.
        items = [
            [
                kItemKeyTitle: "Tremor Task",
                kItemKeyDetail: "Records sensor data related to tremor.",
                kItemKeyClassPrefix: "TremorTask",
            ],
            [
                kItemKeyTitle: "Brady Task",
                kItemKeyDetail: "Finger tapping test for Bradykinesia assessment.",
                kItemKeyClassPrefix: "BradyKinesiaTask",
            ],
//            [
//                kItemKeyTitle: "Tremor",
//                kItemKeyDetail: "Records sensor data related to tremor.",
//                kItemKeyClassPrefix: "Tremor",
//            ],
//            [
//                kItemKeyTitle: "Heart Rate",
//                kItemKeyDetail: "Access to Heart Rate data using HealthKit.",
//                kItemKeyClassPrefix: "HeartRate",
//            ],
//            [
//                kItemKeyTitle: "Accelerometer",
//                kItemKeyDetail: "Access to Accelerometer data using CoreMotion.",
//                kItemKeyClassPrefix: "Accelerometer"
//            ],
//            [
//                kItemKeyTitle: "Gyroscope",
//                kItemKeyDetail: "Access to Gyroscope data using CoreMotion.",
//                kItemKeyClassPrefix: "Gyroscope",
//            ],
//            [
//                kItemKeyTitle: "Device Motion",
//                kItemKeyDetail: "Access to DevicemMotion data using CoreMotion.",
//                kItemKeyClassPrefix: "DeviceMotion",
//            ],
//            [
//                kItemKeyTitle: "Pedometer",
//                kItemKeyDetail: "Counting steps demo using CMPedometer.",
//                kItemKeyClassPrefix: "Pedometer",
//            ]
        ]
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //print("willActivate")
        
        loadTableData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // =========================================================================
    // MARK: Private
    
    fileprivate func loadTableData() {
        
        table.setNumberOfRows(items.count, withRowType: "Cell")
        
        var i=0
        for anItem in items {
            let row = table.rowController(at: i) as! RowController
            row.showItem(anItem[kItemKeyTitle]!, detail: anItem[kItemKeyDetail]!)
            i += 1
        }
    }
    
    // =========================================================================
    // MARK: WKInterfaceTable
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        //print("didSelectRowAtIndex: \(rowIndex)")
        
        let item = items[rowIndex]
        let title = item[kItemKeyClassPrefix]
        
        pushController(withName: title!, context: nil)
    }

}
