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
import CoreData

/**
 The purpose of this view controller is to show you the kinds of data
 you can fetch from a specific `ORKResult`. The intention is for this view
 controller to be purely for demonstration and testing purposes--specifically,
 it should not ever be shown to a user. Because of this, the UI for this view
 controller is not localized.
 */
class AnalysisViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    // MARK: Types
    @IBOutlet weak var bradyUpdrs: UILabel!
    @IBOutlet weak var tremorUpdrs: UILabel!
    @IBOutlet weak var gaitUpdrs: UILabel!
    @IBOutlet weak var brady_cvDuration: UILabel!
    @IBOutlet weak var brady_intervalAvg: UILabel!
    @IBOutlet weak var tremor_r_RMS: UILabel!
    @IBOutlet weak var tremor_r_K: UILabel!
    @IBOutlet weak var tremor_p_RMS: UILabel!
    @IBOutlet weak var tremor_p_K: UILabel!
    @IBOutlet weak var tremor_k_RMS: UILabel!
    @IBOutlet weak var tremor_k_K: UILabel!
    @IBOutlet weak var gait_walkingSpeed: UILabel!
    @IBOutlet weak var gait_strideLength: UILabel!
    @IBOutlet weak var gait_stepIntReg: UILabel!
    @IBOutlet weak var gait_cycleTime: UILabel!
    
    let emptyResult = "-"
    
    var bradyFetchedResults: BradyAnalysis?
    var tremorFetchedResults: TremorAnalysis?
    var gaitFetchedResults: GaitAnalysis?
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        let alert = UIAlertController(title: "Notice", message: "Analysis does not currently include accelerometer/device motion calculations.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        self.present(alert, animated: true){}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchResults(CoreDataStack.coreData.latestUserID)
    }
    

    
    func fetchResults (_ currentID: Int){
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        // Brady
        let bradyRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BradyAnalysis")
        bradyRequest.predicate = NSPredicate(format: "user_id == \(currentID)")
        bradyRequest.sortDescriptors = [dateSort]
        bradyRequest.fetchLimit = 1
        // Tremor
        let tremorRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TremorAnalysis")
        tremorRequest.predicate = NSPredicate(format: "user_id == \(currentID)")
        tremorRequest.sortDescriptors = [dateSort]
        tremorRequest.fetchLimit = 1
        // Gait
        let gaitRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GaitAnalysis")
        gaitRequest.predicate = NSPredicate(format: "user_id == \(currentID)")
        gaitRequest.sortDescriptors = [dateSort]
        gaitRequest.fetchLimit = 1
        
        do {
            let bradyResult = try CoreDataStack.coreData.mainObjectContext.fetch(bradyRequest)
            let tremorResult = try CoreDataStack.coreData.mainObjectContext.fetch(tremorRequest)
            let gaitResult = try CoreDataStack.coreData.mainObjectContext.fetch(gaitRequest)
            if (bradyResult.count > 0) {
                
                bradyFetchedResults = bradyResult[0] as? BradyAnalysis
                bradyUpdrs.text = String(format: "%d", bradyFetchedResults!.updrs as! Int)
                brady_cvDuration.text = String(format: "%.4f", bradyFetchedResults!.brady_cvDuration as! Double)
                brady_intervalAvg.text = String(format: "%.4f", bradyFetchedResults!.brady_intervalAvg as! Double)
            }
            if (tremorResult.count > 0) {
                tremorFetchedResults = tremorResult[0] as? TremorAnalysis
                tremorUpdrs.text = String(format: "%d", tremorFetchedResults!.updrs as! Int)
                tremor_r_RMS.text = String(format: "%.4f", tremorFetchedResults!.tremor_r_RMS as! Double)
                tremor_r_K.text = String(format: "%.4f", tremorFetchedResults!.tremor_r_K as! Double)
                tremor_p_RMS.text = String(format: "%.4f", tremorFetchedResults!.tremor_p_RMS as! Double)
                tremor_p_K.text = String(format: "%.4f", tremorFetchedResults!.tremor_p_K as! Double)
                tremor_k_RMS.text = String(format: "%.4f", tremorFetchedResults!.tremor_k_RMS as! Double)
                tremor_k_K.text = String(format: "%.4f", tremorFetchedResults!.tremor_k_K as! Double)
            }
            if (gaitResult.count > 0) {
                gaitFetchedResults = gaitResult[0] as? GaitAnalysis
                gaitUpdrs.text = String(format: "%d", gaitFetchedResults!.updrs as! Int)
                gait_cycleTime.text = String(format: "%.4f s", gaitFetchedResults!.gait_cycleTime as! Double)
                gait_strideLength.text = String(format: "%.4f m", gaitFetchedResults!.gait_strideLength as! Double)
                gait_walkingSpeed.text = String(format: "%.4f m/s", gaitFetchedResults!.gait_walkingSpeed as! Double)
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

    }
    
}
