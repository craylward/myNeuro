//
//  RowController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/7/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import WatchKit

class RowController: NSObject {
    
    @IBOutlet weak var textLabel: WKInterfaceLabel!
    @IBOutlet weak var detailLabel: WKInterfaceLabel!
    
    func showItem(_ title: String, detail: String) {
        
        textLabel.setText(title)
        detailLabel.setText(detail)
    }
}
