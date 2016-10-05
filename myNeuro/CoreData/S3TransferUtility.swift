//
//  S3TransferManager.swift
//  myNeuro
//
//  Created by Charlie Aylward on 9/13/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import AWSCore
import AWSS3
import AWSCognito
import AWSCognitoIdentityProvider

    let S3BucketName: String = "myneuro"

class S3TransferUtility {    
    class func uploadFile(file: NSURL, fileName: String, progressBlock: AWSS3TransferUtilityProgressBlock?, completionBlock: AWSS3TransferUtilityUploadCompletionHandlerBlock?) -> AWSTask {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        return transferUtility.uploadFile(file,
            bucket: S3BucketName,
            key: fileName,
            contentType: "text/plain",
            expression: expression,
            completionHander: completionBlock) .continueWithBlock { (task) -> AnyObject! in
                if let error = task.error {
                    NSLog("Error: %@",error.localizedDescription);
                }
                if let exception = task.exception {
                    NSLog("Exception: %@",exception.description);
                }
                if let _ = task.result {
                    NSLog("Upload Starting!")
                    // Do something with uploadTask.
                }                
                return task;
        }
    }
}