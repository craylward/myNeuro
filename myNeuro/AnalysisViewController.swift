//
//  AnalysisViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/30/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import ResearchKit
import UIKit

/**
 The purpose of this view controller is to show you the kinds of data
 you can fetch from a specific `ORKResult`. The intention is for this view
 controller to be purely for demonstration and testing purposes--specifically,
 it should not ever be shown to a user. Because of this, the UI for this view
 controller is not localized.
 */
class AnalysisViewController: UITableViewController {
    // MARK: Types
    
    enum SegueIdentifier: String {
        case ShowTaskAnalysis = "ShowTaskAnalysis"
    }
    
    // MARK: Properties
    
    var result: ORKResult?
    
    var currentResult: ORKResult?
    
    var analysisTableViewProvider: protocol<UITableViewDataSource, UITableViewDelegate>?
    
    // MARK: View Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
            Don't update the UI if there hasn't been a change between the currently
            displayed result, and the result that has been most recently set on
            the `AnalysisViewController`.
        */
        
        guard result != currentResult || currentResult == nil else { return }
        
        // Update the currently displayed result.
        currentResult = result
    
        /*
            Display result specific metadata, done by a result table view provider.
            Although we're not going to use `analysisTableViewProvider` directly,
            we need to maintain a reference to it so that it can remain "alive"
            while its the table view's delegate and data source.
        */
        if result is ORKCollectionResult {
            print("Collection Result")
        }
        if result is ORKTaskResult {
            print("Task Result")
        }
        if result is ORKTappingIntervalResult {
            print("Tapping Result")
        }
        analysisTableViewProvider = analysisTableViewProviderForResult(result)
        tableView.dataSource = analysisTableViewProvider
        tableView.delegate = analysisTableViewProvider
    }
}
