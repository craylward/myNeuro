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

    @IBOutlet weak var table: WKInterfaceTable!
    var items: [Dictionary<String, String>]!
    

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
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
    
    private func loadTableData() {
        
        table.setNumberOfRows(items.count, withRowType: "Cell")
        
        var i=0
        for anItem in items {
            let row = table.rowControllerAtIndex(i) as! RowController
            row.showItem(anItem[kItemKeyTitle]!, detail: anItem[kItemKeyDetail]!)
            i += 1
        }
    }
    
    // =========================================================================
    // MARK: WKInterfaceTable
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        
        //print("didSelectRowAtIndex: \(rowIndex)")
        
        let item = items[rowIndex]
        let title = item[kItemKeyClassPrefix]
        
        pushControllerWithName(title!, context: nil)
    }

}
