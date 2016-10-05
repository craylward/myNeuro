//
//  DynamoDBObjects.swift
//  myNeuro
//
//  Created by Charlie Aylward on 9/2/16.
//  Copyright © 2016 SJM. All rights reserved.
//
// Objects for uploading data samples to the AWS DynamoDB server. Follows the AWSDynamoDBObjectModel for upload rows of data to the DynamoDB tables.
//

import Foundation
import AWSDynamoDB

class QuestionnaireTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var id:NSNumber?
    var user_id:NSNumber?
    //set the default values of scores, wins and losses to 0
    var date:String?
    var q1:NSNumber?
    var q2:NSNumber?
    var q3:NSNumber?
    var q4:NSNumber?
    var q5:NSNumber?
    var pk:NSNumber?
    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "QUESTIONNAIRESAMPLE"
    }
    
    class func hashKeyAttribute() -> String {
        return "id"
    }
    
    class func rangeKeyAttribute() -> String {
        return "pk"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
    }
}

class ParticipantTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var userID:NSNumber?
    
    //set the default values of scores, wins and losses to 0
    var Age:NSNumber?
    var DBSImplant:NSNumber?
    var DBSLeftAnodes: NSNumber? = 0
    var DBSLeftCathodes: NSNumber? = 0
    var DBSRightAnodes: NSNumber? = 0
    var DBSRightCathodes: NSNumber? = 0
    
    var FirstName:String?
    var LastName:String?
    var JoinDate:String?
    var Gender:String?
    var Ethnicity:String?
    var MedsLast24H:String?
    var PDDiagnosis:String?    
    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "PARTICIPANT"
    }
    
    class func hashKeyAttribute() -> String {
        return "userID"
    }
    
    class func rangeKeyAttribute() -> String {
        return "LastName"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
    }
}

class TappingTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var id:NSNumber?
    var user_id:NSNumber?
    //set the default values of scores, wins and losses to 0
    var loc_x:NSNumber?
    var loc_y:NSNumber?
    var button_id:String?
    var duration:NSNumber?
    var timeStamp:NSNumber?
    var pk:NSNumber?
    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "TAPPINGSAMPLE"
    }
    
    class func hashKeyAttribute() -> String {
        return "id"
    }
    
    class func rangeKeyAttribute() -> String {
        return "pk"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
    }
}

class WalkingTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var id:NSNumber?
    var user_id:NSNumber?
    //set the default values of scores, wins and losses to 0
    var numberOfSteps:NSNumber?
    var distance:NSNumber?
    var duration:NSNumber?
    var timeStamp:NSNumber? = 0
    var pk:NSNumber?
    var type:String?
    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "WALKINGSAMPLE"
    }
    
    class func hashKeyAttribute() -> String {
        return "id"
    }
    
    class func rangeKeyAttribute() -> String {
        return "pk"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
    }
}

class AccelTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var id:NSNumber?
    var user_id:NSNumber?
    //set the default values of scores, wins and losses to 0
    var aX:NSNumber?
    var aY:NSNumber?
    var aZ:NSNumber?
    var timeStamp:NSNumber?
    var pk:NSNumber?
    var type:String?
    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "ACCELSAMPLE"
    }
    
    class func hashKeyAttribute() -> String {
        return "id"
    }
    
    class func rangeKeyAttribute() -> String {
        return "pk"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
    }
}

class MotionTableRow :AWSDynamoDBObjectModel ,AWSDynamoDBModeling  {
    
    var id:NSNumber?
    var user_id:NSNumber?
    //set the default values of scores, wins and losses to 0
    var aX:NSNumber?
    var aY:NSNumber?
    var aZ:NSNumber?
    var rX:NSNumber?
    var rY:NSNumber?
    var rZ:NSNumber?
    var timeStamp:NSNumber?
    var pk:NSNumber?
    var type:String?
    
    //should be ignored according to ignoreAttributes
    var internalName:String?
    var internalState:NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "MOTIONSAMPLE"
    }
    
    class func hashKeyAttribute() -> String {
        return "id"
    }
    
    class func rangeKeyAttribute() -> String {
        return "pk"
    }
    
    class func ignoreAttributes() -> [String] {
        return ["internalName", "internalState"]
    }
}