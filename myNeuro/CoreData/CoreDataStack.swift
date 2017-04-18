//
//  CoreDataStack.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/21/16.
//  Copyright © 2016 SJM. All rights reserved.
//

/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import CoreData
import UIKit



class CoreDataStack: NSObject {
    
    static let dbFileName = "myNeuro.sqlite"
    static let uploadFileName = "data.sqlite"
    
    // Shared instance (singleton)
    // Used to create an instance of the CoreDataStack for use throughout the app
    static let coreData = CoreDataStack()
    
    // Properties
    // Used to optimize task creation by eliminating the need for fetching after first fetch
    var latestTaskID: Int { return CoreDataStack.fetchLatestTaskID() }
    var latestUserID: Int { return CoreDataStack.fetchLatestUserID() }
    var currentParticipant: Participant? { return CoreDataStack.fetchCurrentParticipant() }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "myNeuro", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("myNeuro.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSSQLitePragmasOption : ["journal_mode" : "DELETE"]]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var mainObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var privateObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    // Function to save Core Data in the mainObjectContext (Used for UI dependent data)
    func saveContext () {
        if mainObjectContext.hasChanges {
            do {
                try mainObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    // Function to save Core Data in the privateObjectContext
    func savePrivateContext () {
        if privateObjectContext.hasChanges {
            do {
                try privateObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    // MARK: Core Data Fetching Support
    // Fetch any set of data from the Core Data persistent store
    static func fetchData(_ entityName: String, predicate: String?, context: NSManagedObjectContext) -> [AnyObject]? {
        let dataRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        if predicate != nil {
            dataRequest.predicate = NSPredicate(format: predicate!)
        }
        let objects: [AnyObject]?
        do {
            objects = try context.fetch(dataRequest)
            return objects
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return nil
    }
    
    // Fetch the latest user ID
    static func fetchLatestUserID() -> Int {
        guard let participants = fetchData("Participant", predicate: nil, context: CoreDataStack.coreData.privateObjectContext) as! [Participant]? else { print("Could not fetch Participant from CoreData"); return -1}
        let ids = participants.map{Int($0.user_id)}
        if ids.isEmpty {
            print("First Participant!")
            return 0
        }
        return ids.max()!
    }
    
    static func fetchLatestTaskID() -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskResult")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.fetchLimit = 1
        do {
            let result = try CoreDataStack.coreData.privateObjectContext.fetch(request)
            if (result.count > 0) {
                let latest_task = result[0] as! TaskResult
                return latest_task.id.intValue // + 1 // 1 after the latest task id
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return 1
    }
    
    static func fetchCurrentParticipant () -> Participant? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Participant")
        do {
            // Show the most recently joined user in the profile page
            var participants = try CoreDataStack.coreData.privateObjectContext.fetch(request) as! [Participant]
            // Sort Descending (later dates first)
            participants = participants.sorted(by: { $0.joinDate.compare($1.joinDate) == ComparisonResult.orderedDescending })
            
            return participants.first
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return nil
    }
    
    static func createNewTaskResult(type: String) -> TaskResult {
        let taskResult = NSEntityDescription.insertNewObject(forEntityName: "TaskResult", into: CoreDataStack.coreData.privateObjectContext) as! TaskResult
        taskResult.id = NSNumber(value: CoreDataStack.coreData.latestTaskID + 1)
        taskResult.date = Date()
        taskResult.user_id = NSNumber(value: CoreDataStack.coreData.latestUserID)
        taskResult.type = type
        return taskResult
    }
    
    static func createUploadFile() -> URL? {
        let fileManager = FileManager.default
        let sourcePath = CoreDataStack.coreData.privateObjectContext.persistentStoreCoordinator?.persistentStores[0].url
        let destinationPath = CoreDataStack.coreData.applicationDocumentsDirectory.appendingPathComponent(uploadFileName)
        do{
            if fileManager.fileExists(atPath: destinationPath.path) {
                try fileManager.removeItem(atPath: destinationPath.path)
            }
            try fileManager.copyItem(atPath: sourcePath!.path, toPath: destinationPath.path)
        }catch let error as NSError {
            print("error occurred, here are the details:\n \(error)")
            return nil
        }
        return destinationPath
    }
    
    static func removeUploadFile() {
        let fileManager = FileManager.default
        let destinationPath = CoreDataStack.coreData.applicationDocumentsDirectory.appendingPathComponent(uploadFileName)
        do{
            if fileManager.fileExists(atPath: destinationPath.path) {
                try fileManager.removeItem(atPath: destinationPath.path)
            }
        }catch let error as NSError {
            print("error occurred, here are the details:\n \(error)")
        }
    }
}
