//
//  DynamoDBManager.swift
//  myNeuro
//
//  Created by Charlie Aylward on 9/2/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import AWSDynamoDB

let dynamoDB = AWSDynamoDB.defaultDynamoDB()
let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
let queryExpression = AWSDynamoDBScanExpression()

class DynamoDBManager : NSObject {
    // Function for uploading any set of data to the AWS DynamoDB server.
    class func uploadSamples(sampleType: String, ddbHashKey: String, ddbRangeKey: String, ddbAttrS: [String], ddbAttrN: [String]) {
        // First check that there is Core Data of the specified sampleType that has not been backed up
        guard let samples = fetchData(sampleType, predicate: "isBacked == 0", context: coreData.privateObjectContext) as! [NSManagedObject]? else { print("All \(sampleType) backed"); return }
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput.tableName = sampleType.uppercaseString
        dynamoDB.describeTable(describeTableInput) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            // If the test table doesn't exist, create one.
            if (task.error != nil && task.error!.domain == AWSDynamoDBErrorDomain) && (task.error!.code == AWSDynamoDBErrorType.ResourceNotFound.rawValue) {
                return DynamoDBManager.createTable(sampleType.uppercaseString, hashKeyAttr: ddbHashKey, rangeKeyAttr: ddbRangeKey, attrS: ddbAttrS, attrN: ddbAttrN) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
                    //Handle erros.
                    if ((task.error) != nil) {
                        print("Error: \(task.error)")
                        print("Failed to setup new \(sampleType) table.")
                    }
                    return nil
                })
            }
            print("Table exists.")
            return nil
        }) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            switch sampleType{
            case "TappingSample":
                return uploadTappingData(samples)
            case "WalkingSample":
                return uploadWalkingData(samples)
            case "MotionSample":
                return uploadMotionData(samples)
            case "AccelSample":
                return uploadAccelData(samples)
            case "QuestionnaireSample":
                return uploadAccelData(samples)
            case "Participant":
                return uploadParticipantData(samples)
            default:
                print("Unknown sampleType")
                return nil
            }
        }) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            print("Finished uploading \(sampleType)")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            return nil
        })
        
    }
    
    class func uploadQuestionnaireData(samples: [NSManagedObject]) -> AWSTask {
        let questionnaireSamples = samples as! [QuestionnaireSample]
        var pk = 1
        return dynamoDBObjectMapper.scan(QuestionnaireTableRow.self, expression: queryExpression) .continueWithBlock ({ (task:AWSTask!) -> AnyObject! in
            if task.result != nil {
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                let items = paginatedOutput.items as! [QuestionnaireTableRow]
                let pks = items.map{Int($0.pk!)}
                if !pks.isEmpty {
                    pk = pks.maxElement()! + 1
                }
            }
            var task = AWSTask(result: nil)
            for sample in questionnaireSamples {
                let tableRow = QuestionnaireTableRow()
                tableRow.q1 = sample.q1
                tableRow.q2 = sample.q2
                tableRow.q3 = sample.q3
                tableRow.q4 = sample.q4
                tableRow.q5 = sample.q5
                tableRow.id = sample.id
                tableRow.user_id = sample.user_id
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
                dateFormatter.timeStyle = .MediumStyle
                tableRow.date = dateFormatter.stringFromDate(sample.date)
                if sample.pk == 0 {
                    sample.pk = pk
                }
                tableRow.pk = sample.pk
                task = task .continueWithSuccessBlock({ (task:AWSTask!) -> AnyObject! in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    return dynamoDBObjectMapper.save(tableRow) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
                        if ((task.error) != nil) {
                            print("Error: \(task.error)")
                            print("Failed to add questionnaire sample.")
                        }
                        else {
                            sample.isBacked = 1
                        }
                        return nil
                    })
                })
                pk += 1
            }
            return task
        }) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            coreData.savePrivateContext()
            return nil
        })
    }
    
    class func uploadTappingData(samples: [NSManagedObject]) -> AWSTask {
        let tappingSamples = samples as! [TappingSample]
        var pk = 1
        return dynamoDBObjectMapper.scan(TappingTableRow.self, expression: queryExpression) .continueWithBlock ({ (task:AWSTask!) -> AnyObject! in
            if task.result != nil {
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                let items = paginatedOutput.items as! [TappingTableRow]
                let pks = items.map{Int($0.pk!)}
                if !pks.isEmpty {
                    pk = pks.maxElement()! + 1
                }
            }
            var task = AWSTask(result: nil)
            for sample in tappingSamples {
                let tableRow = TappingTableRow()
                tableRow.loc_x = sample.loc_x
                tableRow.loc_y = sample.loc_y
                tableRow.button_id = sample.button_id
                tableRow.duration = sample.duration
                tableRow.id = sample.id
                tableRow.user_id = sample.user_id
                tableRow.timeStamp = sample.timeStamp
                if sample.pk == 0 {
                    sample.pk = pk
                }
                tableRow.pk = sample.pk
                task = task .continueWithSuccessBlock({ (task:AWSTask!) -> AnyObject! in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    return dynamoDBObjectMapper.save(tableRow) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
                        if ((task.error) != nil) {
                            print("Error: \(task.error)")
                            print("Failed to add tapping sample.")
                        }
                        else {
                            sample.isBacked = 1
                        }
                        return nil
                    })
                })
                pk += 1
            }
            return task
        }) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            coreData.savePrivateContext()
            return nil
        })
    }
    
    class func uploadWalkingData(samples: [NSManagedObject]) -> AWSTask {
        let walkingSamples = samples as! [WalkingSample]
        // Get the most recent particpant userID from the dynamoDB
        var pk = 1
        return dynamoDBObjectMapper.scan(WalkingTableRow.self, expression: queryExpression) .continueWithBlock ({ (task:AWSTask!) -> AnyObject! in
            if task.result != nil {
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                let items = paginatedOutput.items as! [WalkingTableRow]
                let pks = items.map{Int($0.pk!)}
                if !pks.isEmpty {
                    pk = pks.maxElement()! + 1
                }
            }
            var task = AWSTask(result: nil)
            for sample in walkingSamples {
                let tableRow = WalkingTableRow()
                tableRow.numberOfSteps = sample.numberOfSteps
                tableRow.distance = sample.distance
                tableRow.duration = sample.duration
                tableRow.id = sample.id
                tableRow.user_id = sample.user_id
                tableRow.timeStamp = sample.timeStamp
                tableRow.type = sample.type
                if sample.pk == 0 {
                    sample.pk = pk
                }
                tableRow.pk = pk
                task = task .continueWithSuccessBlock({ (task:AWSTask!) -> AnyObject! in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    return dynamoDBObjectMapper.save(tableRow) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
                        if ((task.error) != nil) {
                            print("Error: \(task.error)")
                            print("Failed to add walking sample.")
                        }
                        else {
                            sample.isBacked = 1
                        }
                        return nil
                    })
                })
                pk += 1
            }
            return task
        }) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            coreData.savePrivateContext()
            return nil
        })
    }
    
    class func uploadAccelData(samples: [NSManagedObject]) -> AWSTask {
        let accelSamples = samples as! [AccelSample]
        return dynamoDBObjectMapper.scan(AccelTableRow.self, expression: queryExpression) .continueWithBlock ({ (task:AWSTask!) -> AnyObject! in
            var pk = 1
            if task.result != nil {
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                let items = paginatedOutput.items as! [AccelTableRow]
                let pks = items.map{Int($0.pk!)}
                if !pks.isEmpty {
                    pk = pks.maxElement()! + 1
                }
            }
            var task = AWSTask(result: nil)
            for sample in accelSamples {
                let tableRow = AccelTableRow()
                tableRow.aX = sample.aX
                tableRow.aY = sample.aY
                tableRow.aZ = sample.aZ
                tableRow.id = sample.id
                tableRow.user_id = sample.user_id
                tableRow.timeStamp = sample.timeStamp
                tableRow.type = sample.type
                if sample.pk == 0 {
                    sample.pk = pk
                }
                tableRow.pk = sample.pk
                task = task .continueWithSuccessBlock({ (task:AWSTask!) -> AnyObject! in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    return dynamoDBObjectMapper.save(tableRow) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
                        if ((task.error) != nil) {
                            print("Error: \(task.error)")
                            print("Failed to add accel sample.")
                        }
                        else {
                            sample.isBacked = 1
                        }
                        return nil
                    })
                })
                pk += 1
            }
            return task
        }) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            coreData.savePrivateContext()
            return nil
        })
    }
    
    
    class func uploadMotionData(samples: [NSManagedObject]) -> AWSTask {
        let motionSamples = samples as! [MotionSample]
        return dynamoDBObjectMapper.scan(MotionTableRow.self, expression: queryExpression) .continueWithBlock ({ (task:AWSTask!) -> AnyObject! in
            var pk = 1
            if task.result != nil {
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                let items = paginatedOutput.items as! [MotionTableRow]
                let pks = items.map{Int($0.pk!)}
                if !pks.isEmpty {
                    pk = pks.maxElement()! + 1
                }
            }
            var task = AWSTask(result: nil)
            for sample in motionSamples {
                let tableRow = MotionTableRow()
                tableRow.aX = sample.aX
                tableRow.aY = sample.aY
                tableRow.aZ = sample.aZ
                tableRow.rX = sample.rX
                tableRow.rY = sample.rY
                tableRow.rZ = sample.rZ
                tableRow.id = sample.id
                tableRow.user_id = sample.user_id
                tableRow.timeStamp = sample.timeStamp
                tableRow.type = sample.type
                if sample.pk == 0 {
                    sample.pk = pk
                }
                tableRow.pk = sample.pk
                task = task .continueWithSuccessBlock({ (task:AWSTask!) -> AnyObject! in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    return dynamoDBObjectMapper.save(tableRow) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
                        if ((task.error) != nil) {
                            print("Error: \(task.error)")
                            print("Failed to add motion sample.")
                        }
                        else {
                            sample.isBacked = 1
                        }
                        return nil
                    })
                })
                pk += 1
            }
            return task
        }) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            coreData.savePrivateContext()
            return nil
        })
    }

    
    class func uploadParticipantData(samples: [NSManagedObject]) -> AWSTask {
        let participants = samples as! [Participant]
        return dynamoDBObjectMapper.scan(ParticipantTableRow.self, expression: queryExpression) .continueWithBlock ({ (task:AWSTask!) -> AnyObject! in
            var currentID = fetchLatestUserID(coreData.privateObjectContext)
            if task.result != nil {
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                let items = paginatedOutput.items as! [ParticipantTableRow]
                let existingIds = items.map{Int($0.userID!)}
                if !existingIds.isEmpty {
                    currentID = existingIds.maxElement()! + 1
                }
            }
            var task = AWSTask(result: nil)
            for participant in participants {
                // Change the CoreData participant ID to an unused ID
                updateTaskResultUserIDs(Int(participant.user_id), newID: currentID)
                participant.user_id = currentID
                let tableRow = ParticipantTableRow()
                
                tableRow.userID = participant.user_id
                tableRow.Age = participant.age
                if participant.dbsParam != nil {
                    tableRow.DBSParam = participant.dbsParam
                }
                tableRow.Ethnicity = participant.ethnicity
                tableRow.FirstName = participant.firstName
                tableRow.Gender = participant.gender
                tableRow.LastName = participant.lastName
                tableRow.MedsLast24H = participant.medsLast24h
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
                tableRow.PDDiagnosis = dateFormatter.stringFromDate(participant.pdDiagnosis!)
                tableRow.JoinDate = dateFormatter.stringFromDate(participant.joinDate)
                task = task .continueWithSuccessBlock({ (task:AWSTask!) -> AnyObject! in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    return dynamoDBObjectMapper.save(tableRow) .continueWithBlock ({ (task:AWSTask!) -> AnyObject! in
                        if (task.error != nil) {
                            print("Error saving participant table row")
                        }
                        else {
                            participant.isBacked = 1
                            print("ParticipantID: " + String(participant.user_id))
                        }
                        print(tableRow)
                        return nil
                    })
                })
                currentID += 1
            }
            return task
        }) .continueWithBlock({ (task:AWSTask!) -> AnyObject! in
            coreData.savePrivateContext()
            return nil
        })
        
    }
    
    class func createTable (tableName: String, hashKeyAttr: String, rangeKeyAttr: String?, attrS: [String], attrN: [String]) -> AWSTask {
        var keySchemaElems: [AWSDynamoDBKeySchemaElement] = []
        var attrDefs: [AWSDynamoDBAttributeDefinition] = []
        
        // Add key attributes
        let keyAttributeDefinition = AWSDynamoDBAttributeDefinition()
        keyAttributeDefinition.attributeName = hashKeyAttr
        keyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeType.N
        attrDefs.append(keyAttributeDefinition)
        
        let keySchemaElement = AWSDynamoDBKeySchemaElement()
        keySchemaElement.attributeName = hashKeyAttr
        keySchemaElement.keyType = AWSDynamoDBKeyType.Hash
        keySchemaElems.append(keySchemaElement)
        
        // add attributes of String type
        for attribute in attrS {
            let attrDef = AWSDynamoDBAttributeDefinition()
            attrDef.attributeName = attribute
            attrDef.attributeType = AWSDynamoDBScalarAttributeType.S
            attrDefs.append(attrDef)
        }
        // add attributes of Int type
        for attribute in attrN {
            let attrDef = AWSDynamoDBAttributeDefinition()
            attrDef.attributeName = attribute
            attrDef.attributeType = AWSDynamoDBScalarAttributeType.N
            attrDefs.append(attrDef)
        }
        let provisionedThroughput = AWSDynamoDBProvisionedThroughput()
        provisionedThroughput.readCapacityUnits = 20
        provisionedThroughput.writeCapacityUnits = 20
        
        let createTableInput = AWSDynamoDBCreateTableInput()
        if rangeKeyAttr != nil {
            let rangeKeyAttributeDefinition = AWSDynamoDBAttributeDefinition()
            rangeKeyAttributeDefinition.attributeName = rangeKeyAttr
            if tableName.containsString("PARTICIPANT"){ // Participant uses LastName (String). Everything else uses pk (Number)
                rangeKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeType.S
            }
            else {
                rangeKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeType.N
            }
            attrDefs.append(rangeKeyAttributeDefinition)
            let rangeKeySchemaElement = AWSDynamoDBKeySchemaElement()
            rangeKeySchemaElement.attributeName = rangeKeyAttr
            rangeKeySchemaElement.keyType = AWSDynamoDBKeyType.Range
            keySchemaElems.append(rangeKeySchemaElement)
            //Create Global Secondary Index
            let rangeKeyArray = attrS + attrN
            var gsiArray:[AWSDynamoDBGlobalSecondaryIndex]?
            if rangeKeyArray.count > 0 {
                gsiArray = [AWSDynamoDBGlobalSecondaryIndex]()
            }
            for rangeKey in rangeKeyArray {
                let gsi = AWSDynamoDBGlobalSecondaryIndex()
                
                let gsiHashKeySchema = AWSDynamoDBKeySchemaElement()
                gsiHashKeySchema.attributeName = rangeKeyAttr
                gsiHashKeySchema.keyType = AWSDynamoDBKeyType.Hash
                
                let gsiRangeKeySchema = AWSDynamoDBKeySchemaElement()
                gsiRangeKeySchema.attributeName = rangeKey
                gsiRangeKeySchema.keyType = AWSDynamoDBKeyType.Range
                
                let gsiProjection = AWSDynamoDBProjection()
                gsiProjection.projectionType = AWSDynamoDBProjectionType.All;
                
                gsi.keySchema = [gsiHashKeySchema,gsiRangeKeySchema];
                gsi.indexName = rangeKey;
                gsi.projection = gsiProjection;
                gsi.provisionedThroughput = provisionedThroughput;
                
                gsiArray?.append(gsi)
            }
            createTableInput.globalSecondaryIndexes = gsiArray
        }
        
        createTableInput.tableName = tableName;
        createTableInput.attributeDefinitions = attrDefs
        createTableInput.keySchema = keySchemaElems
        createTableInput.provisionedThroughput = provisionedThroughput
        
        
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        return dynamoDB.createTable(createTableInput).continueWithSuccessBlock({ task -> AnyObject? in
            var localTask = task
            
            if ((localTask.result) != nil) {
                // Wait for up to 4 minutes until the table becomes ACTIVE.
                let describeTableInput = AWSDynamoDBDescribeTableInput()
                describeTableInput.tableName = tableName;
                localTask = dynamoDB.describeTable(describeTableInput)
                
                for _ in 0...15 {
                    localTask = localTask.continueWithSuccessBlock({ task -> AnyObject? in
                        let describeTableOutput:AWSDynamoDBDescribeTableOutput = task.result as! AWSDynamoDBDescribeTableOutput
                        let tableStatus = describeTableOutput.table!.tableStatus
                        if tableStatus == AWSDynamoDBTableStatus.Active {
                            return task
                        }
                        sleep(15)
                        return dynamoDB .describeTable(describeTableInput)
                    })
                }
            }
            return localTask
        })
    }
}






