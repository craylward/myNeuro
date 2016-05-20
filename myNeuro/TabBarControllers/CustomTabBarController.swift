//
//  CustomTabBarController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/30/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit

// This class holds the data for my model.
class ModelData {
    var result: ORKResult?
}

class CustomTabBarController: UITabBarController {
    
    // Instantiate the one copy of the model data that will be accessed
    // by all of the tabs.
    var model = ModelData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
}