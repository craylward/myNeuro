//
//  WatchSample.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/11/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation

class WatchSample {
    
    var accX: Double
    var accY: Double
    var accZ: Double
    
    
    init(accX: Double = 0.0, accY: Double = 0.0, accZ: Double = 0.0) {
        self.accX = accX
        self.accY = accY
        self.accZ = accZ
    }
    
    
    func exportAsCommaSeparatedValues() -> String {
        let csv = "\(accX),\(accY),\(accZ)\n"
        
        return csv
    }
    
}