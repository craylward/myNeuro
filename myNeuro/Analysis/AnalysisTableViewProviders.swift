//
//  AnalysisTableViewProviders.swift
//  myNeuro
//
//  Created by Charlie Aylward on 3/30/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import UIKit
import ResearchKit
import MapKit

/**
Create a `protocol<UITableViewDataSource, UITableViewDelegate>` that knows
how to present the metadata for an `ORKResult` instance. Extra metadata is
displayed for specific `ORKResult` types. For example, a table view provider
for an `ORKFileResult` instance will display the `fileURL` in addition to the
standard `ORKResult` properties.

To learn about how to read metadata from the different kinds of `ORKResult`
instances, see the `ResultTableViewProvider` subclasses below. Specifically,
look at their `resultRowsForSection(_:)` implementations which are meant to
enhance the metadata that is displayed for the result table view provider.

Note: since these table view providers are meant to display data for developers
and are not user visible (see description in `ResultViewController`), none
of the properties / content are localized.
*/
func analysisTableViewProviderForResult(result: ORKResult?) -> protocol<UITableViewDataSource, UITableViewDelegate> {
    guard let result = result else {
        /*
        Use a table view provider that shows that there hasn't been a recently
        provided result.
        */
        return NoRecentAnalysisTableViewProvider()
    }
    
    // The type that will be used to create an instance of a table view provider.
    var providerType: AnalysisTableViewProvider.Type
    
    switch result {
        case is ORKTappingIntervalResult:
            providerType = BradykinesiaAnalysisTableViewProvider.self
        
        // All
        case is ORKTaskResult:
            providerType = TaskAnalysisTableViewProvider.self
            let collectionResult = result as! ORKCollectionResult
            
            if let tapStepResult = collectionResult.resultForIdentifier("tapping") as! ORKStepResult? {
                if let tapIntResult = tapStepResult.resultForIdentifier("tapping") as! ORKTappingIntervalResult? {
                    return analysisTableViewProviderForResult(tapIntResult)
                }
            }
        /*
        Refer to the comment near the switch statement for why the
        additional guard is here.
        */
        case is ORKCollectionResult where !(result is ORKTaskResult):
            providerType = CollectionAnalysisTableViewProvider.self
        default:
            fatalError("No AnalysisTableViewProvider defined for \(result.dynamicType).")
    }

    // Return a new instance of the specific `ResultTableViewProvider`.
    return providerType.init(result: result)

}

/**
 A special `protocol<UITableViewDataSource, UITableViewDelegate>` that displays
    a row saying that there's no result.
*/
class NoRecentAnalysisTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource
        
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(AnalysisRow.TableViewCellIdentifier.NoResultSet.rawValue, forIndexPath: indexPath)
    }
}

/**
 An enum representing the data that can be presented in a `UITableViewCell` by
 a `ResultsTableViewProvider` type.
 */
enum AnalysisRow {
    // MARK: Cases
    
    case Text(String, detail: String, selectable: Bool)
    
    // MARK: Types
    
    /**
    Possible `UITableViewCell` identifiers that have been defined in the main
    storyboard.
    */
    enum TableViewCellIdentifier: String {
        case Default =          "Default"
        case NoResultSet =      "NoResultSet"
        case NoChildResults =   "NoChildResults"
    }
    
    // MARK: Initialization
    
    /// Helper initializer for `AnalysisRow.Text`.
    init(text: String, detail: Any?, selectable: Bool = false) {
        /*
        Show the string value if `detail` is not `nil`, otherwise show that
        it's "nil". Use Optional's map method to map the value to a string
        if the detail is not `nil`.
        */
        let detailText = detail.map { String($0) } ?? "nil"
        
        self = .Text(text, detail: detailText, selectable: selectable)
    }
}


// MARK: ResultTableViewProvider and Subclasses

/**
Base class for displaying metadata for an `ORKResult` instance. The metadata
that's displayed are common properties for all `ORKResult` instances (e.g.
`startDate` and `endDate`).
*/
class AnalysisTableViewProvider: NSObject, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    
    let result: ORKResult
    
    // MARK: Initializers
    
    required init(result: ORKResult) {
        self.result = result
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let analysisRows = analysisRowsForSection(section)
        
        // Show an empty row if there isn't any metadata in the rows for this section.
        if analysisRows.isEmpty {
            return 1
        }
        
        return analysisRows.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let analysisRows = analysisRowsForSection(indexPath.section)
        
        // Show an empty row if there isn't any metadata in the rows for this section.
        if analysisRows.isEmpty {
            return tableView.dequeueReusableCellWithIdentifier(ResultRow.TableViewCellIdentifier.NoChildResults.rawValue, forIndexPath: indexPath)
        }
        
        // Fetch the `ResultRow` that corresponds to `indexPath`.
        let analysisRow = analysisRows[indexPath.row]
        
        switch analysisRow {
        case let .Text(text, detail: detailText, selectable):
            let cell = tableView.dequeueReusableCellWithIdentifier(ResultRow.TableViewCellIdentifier.Default.rawValue, forIndexPath: indexPath)
            
            cell.textLabel!.text = text
            cell.detailTextLabel!.text = detailText
            
            /*
            In this sample, the accessory type should be a disclosure
            indicator if the table view cell is selectable.
            */
            cell.selectionStyle = selectable ? .Default : .None
            cell.accessoryType  = selectable ? .DisclosureIndicator : .None
            
            return cell
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Analysis" : nil
    }
    
    // MARK: Overridable Methods
    
    func analysisRowsForSection(section: Int) -> [AnalysisRow] {
        // Default to an empty array.
        guard section == 0 else { return [] }
        
        return [
            // The class name of the result object.
            AnalysisRow(text: "type", detail: result.dynamicType),
            
            /*
            The identifier of the result, which corresponds to the task,
            step or item that generated it.
            */
            AnalysisRow(text: "identifier", detail: result.identifier),
            
            // The start date for the result.
            AnalysisRow(text: "start", detail: result.startDate),
            
            // The end date for the result.
            AnalysisRow(text: "end", detail: result.endDate)
        ]
    }
}


/// Table view provider specific to an `ORKTappingIntervalResult` instance.
class BradykinesiaAnalysisTableViewProvider: AnalysisTableViewProvider {
    // MARK: UITableViewDataSource
    
    // MARK: AnalysisTableViewProvider
    override func analysisRowsForSection(section: Int) -> [AnalysisRow] {
        let questionResult = result as! ORKTappingIntervalResult
        let rows = super.analysisRowsForSection(section)
        let timeStamps = questionResult.samples!.map { tappingSample in
            
            return tappingSample.timestamp
        }
        var timeIntervals = timeStamps
        var index = timeIntervals.count - 1
        while index > 0
        {
            timeIntervals[index] -= timeIntervals[index-1]
            index -= 1
        }
        var timeIntervalsRev = timeIntervals // create new array for finding min
        timeIntervalsRev.removeFirst() // remove 0 element (first tap) for finding minimum tap interval time
        let count = questionResult.samples!.count
        let freq = frequency(timeIntervals, duration: tappingDuration)
        for element in timeIntervals {
            print(element)
        }
        let sd = standardDeviation(timeIntervals)
        let avg = average(timeIntervals)
        
        return rows + [
                // The number of taps
                AnalysisRow(text: "Tap Count", detail: count),
            
                // The duration of time during taps
                AnalysisRow(text: "Duration", detail: tappingDuration),
            
                // The frequency of taps
                AnalysisRow(text: "Frequency", detail: String(format: "%.3f", freq) + " Hz"),
            
                // The average time interval
                AnalysisRow(text: "Avg Time", detail: String(format: "%.3f", avg) + " s"),
            
                // The frequency of taps
                AnalysisRow(text: "Std Deviation", detail: String(format: "%.3f", sd)),
            
                // The min time interval between taps
                AnalysisRow(text: "Min", detail: String(format: "%.3f", timeIntervals.minElement()!)),
            
                // The max time interval between taps
                AnalysisRow(text: "Max", detail: String(format: "%.3f", timeIntervals.maxElement()!))
            ]
    }
}

/// Table view provider specific to an `ORKResult` for Tremor Task instance.
class TremorAnalysisTableViewProvider: AnalysisTableViewProvider {
    // MARK: UITableViewDataSource
    
    // MARK: ResultTableViewProvider
    
    override func analysisRowsForSection(section: Int) -> [AnalysisRow] {
        let rows = super.analysisRowsForSection(section)
        
        return rows
    }
}

/// Table view provider specific to an `ORKTaskResult` instance.
class TaskAnalysisTableViewProvider: CollectionAnalysisTableViewProvider {
    // MARK: ResultTableViewProvider
    
    override func analysisRowsForSection(section: Int) -> [AnalysisRow] {
        let taskResult = result as! ORKTaskResult
        
        let rows = super.analysisRowsForSection(section)
        
        if section == 0 {
            return rows + [
                AnalysisRow(text: "taskRunUUID", detail: taskResult.taskRunUUID.UUIDString),
                AnalysisRow(text: "outputDirectory", detail: taskResult.outputDirectory)
            ]
        }
        
        return rows
    }
}

/// Table view provider specific to an `ORKCollectionResult` instance.
class CollectionAnalysisTableViewProvider: AnalysisTableViewProvider {
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return super.tableView(tableView, titleForHeaderInSection: 0)
        }
        
        return "Analysis"
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    // MARK: ResultTableViewProvider
    
    override func analysisRowsForSection(section: Int) -> [AnalysisRow] {
        let collectionResult = result as! ORKCollectionResult
        
        let rows = super.analysisRowsForSection(section)
        
        
        // Show the child results in section 1.
//        if section == 1 {
//            return rows + collectionResult.results!.map { childResult in
//                let childResultClassName = "\(childResult.dynamicType)"
//                
//                return AnalysisRow(text: childResultClassName, detail: childResult.identifier, selectable: true)
//            }
//        }
        
        return rows
    }
}

