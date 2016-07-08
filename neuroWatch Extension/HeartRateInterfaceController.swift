//
//  HeartRateInterfaceController.swift
//  watchOS2Sampler
//
//  Created by Yusuke Kita (kitasuke) on 2015/10/11.
//  Copyright © 2015 Yusuke Kita. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class HeartRateInterfaceController: WKInterfaceController {
    
    
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var startBtn: WKInterfaceButton!
    let healthStore = HKHealthStore()
    let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
    let heartRateUnit = HKUnit(fromString: "count/min")
    var heartRateQuery: HKQuery?
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() else {
            label.setText("not available")
            return
        }
        
        let dataTypes = Set([heartRateType])
        
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) -> Void in
            guard success else {
                self.label.setText("not allowed")
                return
            }
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    // =========================================================================
    // MARK: - Actions
    
    @IBAction func fetchBtnTapped() {
        guard heartRateQuery == nil else { return }
        
        if heartRateQuery == nil {
            // start
            heartRateQuery = self.createStreamingQuery()
            healthStore.executeQuery(self.heartRateQuery!)
            startBtn.setTitle("Stop")
        }
        else {
            // stop
            healthStore.stopQuery(self.heartRateQuery!)
            heartRateQuery = nil
            startBtn.setTitle("Start")
        }
    }
    
    
    // =========================================================================
    // MARK: - Private
    
    private func createStreamingQuery() -> HKQuery {
        let predicate = HKQuery.predicateForSamplesWithStartDate(NSDate(), endDate: nil, options: .None)
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples)
        }
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) -> Void in
            self.addSamples(samples)
        }
        
        return query
    }
    
    private func addSamples(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        guard let quantity = samples.last?.quantity else { return }
        label.setText("\(quantity.doubleValueForUnit(heartRateUnit))")
    }
}
