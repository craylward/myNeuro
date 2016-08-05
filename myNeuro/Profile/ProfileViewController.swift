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

class ProfileViewController: UITableViewController, HealthClientType {
    // MARK: Properties

    let healthObjectTypes = [
        HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
        HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!
    ]
    
    let otherTypes = ["Date of Birth", "Age", "Gender", "Ethnicity", "PD Diagnosis Date", "Medications", "DBS Parameter"]
    
    var healthStore: HKHealthStore?
    
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet var applicationNameLabel: UILabel!
    
    lazy var mainContext: NSManagedObjectContext = {
        var coreDataStack = CoreDataStack()
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coreDataStack.persistentStoreCoordinator
        return context
    }()
    
    var participant: Participant?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let healthStore = healthStore else { fatalError("healthStore not set") }
        let request = NSFetchRequest(entityName: "Participant")
        do {
            participant = try mainContext.executeFetchRequest(request).first as? Participant
            participantNameLabel.text = participant!.firstName + " " + participant!.lastName
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        // Ensure the table view automatically sizes its rows.
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        // Request authorization to query the health objects that need to be shown.
        let typesToRequest = Set<HKObjectType>(healthObjectTypes)
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: typesToRequest) { authorized, error in
            guard authorized else { return }
            
            // Reload the table view cells on the main thread.
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                let allRowIndexPaths = self.healthObjectTypes.enumerate().map { NSIndexPath(forRow: $0.index, inSection: 0) }
                self.tableView.reloadRowsAtIndexPaths(allRowIndexPaths, withRowAnimation: .Automatic)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherTypes.count // healthObjectTypes.count +
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(ProfileStaticTableViewCell.reuseIdentifier, forIndexPath: indexPath) as? ProfileStaticTableViewCell else { fatalError("Unable to dequeue a ProfileStaticTableViewCell") }
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
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .NoStyle
            cell.valueLabel.text = dateFormatter.stringFromDate((participant?.pdDiagnosis)!)
        case "Medications":
            cell.valueLabel.text = participant?.medsLast24h as? String
        case "DBS Parameter":
            if participant?.dbsParam != nil {
                cell.valueLabel.text = (participant?.dbsParam?.stringValue)! + " Hz"
            }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Cell configuration
    
    func configureCellWithDateOfBirth(cell: ProfileStaticTableViewCell) {
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
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .NoStyle
            // US English Locale (en_US)
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")// Jan 2, 2001
            cell.valueLabel.text = dateFormatter.stringFromDate(dateOfBirth)
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
    
    func indexPathForObjectTypeIdentifier(identifier: String) -> NSIndexPath? {
        for (index, objectType) in healthObjectTypes.enumerate() where objectType.identifier == identifier {
            return NSIndexPath(forRow: index, inSection: 0)
        }
        
        return nil
    }
}
