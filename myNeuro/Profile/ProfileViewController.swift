/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import ResearchKit
import HealthKit
import CoreData
import AWSS3
import AWSCore

class ProfileViewController: UITableViewController, HealthClientType {
    // MARK: Properties
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var progressBlock: AWSS3TransferUtilityProgressBlock?
    
    let healthObjectTypes = [
        HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
        //HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
        //HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!
    ]
    
    let otherTypes = ["Age", "Gender", "Ethnicity", "PD Diagnosis Date", "Medications", "DBS Implant"] // "Date of Birth"
    
    var healthStore: HKHealthStore?
    
    // @IBOutlets
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet var applicationNameLabel: UILabel!
    @IBOutlet weak var uploadDataButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var fileLabel: UILabel!
    
    // @IBActions
    
    @IBAction func pressUploadData(_ sender: Any) {
        reachable = Reachability().isConnectedToNetwork()
        if reachable == true {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy_h-mma"
            let dateString = dateFormatter.string(from: Date())
            
            
            let file = CoreDataStack.coreData.privateObjectContext.persistentStoreCoordinator?.persistentStores[0].url
            // DEBUG
            print(file!.path)
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: file!.path)
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                print("DB File size: \(fileSize)")
            }
            catch {
                print("Error: \(error)")
            }
            
            if let dbFile = CoreDataStack.createUploadFile() {
                self.present(pleaseWait, animated: true, completion: nil)
                
                S3TransferUtility.uploadFile(file: dbFile as NSURL, fileName: "\(dateString)/\(dbFile.lastPathComponent)", progressBlock: {(task, progress) in
                    DispatchQueue.main.async(execute: {
                        self.progressView.progress = Float(progress.fractionCompleted)
                        self.fileLabel.text = dbFile.lastPathComponent
                    })}, completionBlock: self.completionHandler)
            }
            else {
                print("Error: Could not locate the persisitent store db file.")
                let alert = UIAlertController(title: "Error", message: "Could not locate the persistent store db file.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                self.present(alert, animated: true){}
            }
        }
        else {
            print("Internet connection FAILED")
            let alert = UIAlertController(title: "No Internet Connection", message: "Data cannot be uploaded to database unless connected to the internet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){}
        }
    }
    
    // Deprecated
    public func uploadButtonOn () {
        print("button on")
        uploadDataButton.isEnabled = true
        self.fileLabel.text = ""
    }
    public func uploadButtonOff () {
        print("button off")
        uploadDataButton.isEnabled = false
        self.fileLabel.text = "Waiting for results to finish processing..."
    }
    
    var participant: Participant?
    
    // MARK: UIViewController
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if participant != CoreDataStack.coreData.currentParticipant {
            participant = CoreDataStack.coreData.currentParticipant
            participantNameLabel.text = participant!.firstName + " " + participant!.lastName
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressView.progress = 0.0;
        
        // ready for receiving notification
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self,
                                  selector: #selector(ProfileViewController.uploadButtonOn),
                                  name: NSNotification.Name("finishedProcessing"),
                                  object: nil)
        defaultCenter.addObserver(self,
                                  selector: #selector(ProfileViewController.uploadButtonOff),
                                  name: NSNotification.Name("processingResults"),
                                  object: nil)
        
        self.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                self.progressView.progress = Float(progress.fractionCompleted)
            })
        }
        self.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                CoreDataStack.removeUploadFile()
                pleaseWait.dismiss(animated: false, completion: nil)
                
                self.fileLabel.text = ""
                if ((error) != nil){
                    print("Failed with error")
                    print("Error: %@",error!);
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Upload Failed", message: "Data could not be uploaded: \(error!)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                        self.present(alert, animated: true){}
                    }
                }
                else if(self.progressView.progress != 1.0) {
                    print("Error: Failed - Likely due to invalid region / filename")
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Upload Failed", message: "Error: Failed - Likely due to invalid region / filename", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                        self.present(alert, animated: true){}
                    }
                }
                else{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Upload Successful", message: "Data has been uploaded to a secure cloud storage", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                        self.present(alert, animated: true){}
                    }
                }
                self.progressView.progress = 0.0;
            })
        }
        
        guard let healthStore = healthStore else { fatalError("healthStore not set") }
        participant = CoreDataStack.coreData.currentParticipant
        participantNameLabel.text = participant!.firstName + " " + participant!.lastName
        // Ensure the table view automatically sizes its rows.
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Request authorization to query the health objects that need to be shown.
        let typesToRequest = Set<HKCharacteristicType>(healthObjectTypes) // UseSet<HKObjectType> if healthObjectTypes contains ANY object types
        healthStore.requestAuthorization(toShare: nil, read: typesToRequest) { authorized, error in
            guard authorized else { return }
            
            // Reload the table view cells on the main thread.
            OperationQueue.main.addOperation() {
                //let allRowIndexPaths = self.healthObjectTypes.enumerated().map { IndexPath(row: $0.index, section: 0) }
                let allRowIndexPaths = self.healthObjectTypes.enumerated().map { _,_ in IndexPath(row: 0, section: 0) }
                self.tableView.reloadRows(at: allRowIndexPaths, with: .automatic)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherTypes.count // healthObjectTypes.count +
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileStaticTableViewCell.reuseIdentifier, for: indexPath) as? ProfileStaticTableViewCell else { fatalError("Unable to dequeue a ProfileStaticTableViewCell") }
        let type = otherTypes[indexPath.row]
        
        cell.titleLabel.text = type
        cell.valueLabel.text = "-"
        switch(type) {
        case "Date of Birth":
            configureCellWithDateOfBirth(cell)
        case "Age":
            cell.valueLabel.text = participant?.age?.stringValue
        case "Gender":
            cell.valueLabel.text = participant?.gender
        case "Ethnicity":
            cell.valueLabel.text = participant?.ethnicity
        case "PD Diagnosis Date":
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            cell.valueLabel.text = dateFormatter.string(from: (participant?.pdDiagnosis)! as Date)
        case "Medications":
            cell.valueLabel.text = participant?.medsLast24h
        case "DBS Implant":
            cell.valueLabel.text = (participant!.dbsImplant!.boolValue ? "Yes" : "No")
        default:
            fatalError("Unexpected type for profile cell")
        }
        
        //        let objectType = healthObjectTypes[indexPath.row]
        //
        //        switch(objectType.identifier) {
        //            case HKCharacteristicTypeIdentifierDateOfBirth:
        //                configureCellWithDateOfBirth(cell)
        //
        //            case HKQuantityTypeIdentifierHeight:
        //                let title = NSLocalizedString("Height", comment: "")
        //                configureCell(cell, withTitleText: title, valueForQuantityTypeIdentifier: objectType.identifier)
        //
        //            case HKQuantityTypeIdentifierBodyMass:
        //                let title = NSLocalizedString("Weight", comment: "")
        //                configureCell(cell, withTitleText: title, valueForQuantityTypeIdentifier: objectType.identifier)
        //
        //            default:
        //                fatalError("Unexpected health object type identifier - \(objectType.identifier)")
        //        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Cell configuration
    
    func configureCellWithDateOfBirth(_ cell: ProfileStaticTableViewCell) {
        // Set the default cell content.
        cell.titleLabel.text = NSLocalizedString("Date of Birth", comment: "")
        cell.valueLabel.text = NSLocalizedString("-", comment: "")
        // Update the value label with the date of birth from the health store.
        guard let healthStore = healthStore else { return }
        do {
            let dateOfBirth = try healthStore.dateOfBirth()
            /* Converts DoB to Age */
            //            let now = NSDate()
            //            let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: dateOfBirth, toDate: now, options: .WrapComponents)
            //            let age = ageComponents.year
            //            cell.valueLabel.text = "\(age)"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            // US English Locale (en_US)
            dateFormatter.locale = Locale(identifier: "en_US")// Jan 2, 2001
            cell.valueLabel.text = dateFormatter.string(from: dateOfBirth)
        }
        catch {
        }
    }
    
    //    func configureCell(cell: ProfileStaticTableViewCell, withTitleText titleText: String, valueForQuantityTypeIdentifier identifier: String) {
    //        // Set the default cell content.
    //        cell.titleLabel.text = titleText
    //        cell.valueLabel.text = NSLocalizedString("-", comment: "")
    //
    //        /*
    //            Check a health store has been set and a `HKQuantityType` can be
    //            created with the identifier provided.
    //        */
    //        guard let healthStore = healthStore, quantityType = HKQuantityType.quantityTypeForIdentifier(identifier) else { return }
    //
    //        // Get the most recent entry from the health store.
    //        healthStore.mostRecentQauntitySampleOfType(quantityType) { quantity, _ in
    //            guard let quantity = quantity else { return }
    //
    //            // Update the cell on the main thread.
    //            NSOperationQueue.mainQueue().addOperationWithBlock() {
    //                guard let indexPath = self.indexPathForObjectTypeIdentifier(identifier) else { return }
    //                guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ProfileStaticTableViewCell else { return }
    //
    //
    //                cell.valueLabel.text = "\(quantity)"
    //            }
    //        }
    //    }
    
    // MARK: Convenience
    
    func indexPathForObjectTypeIdentifier(_ identifier: String) -> IndexPath? {
        for (index, objectType) in healthObjectTypes.enumerated() where objectType.identifier == identifier {
            return IndexPath(row: index, section: 0)
        }
        
        return nil
    }
}
