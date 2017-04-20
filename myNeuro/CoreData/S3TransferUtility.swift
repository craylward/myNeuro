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
    @discardableResult
    class func uploadFile(file: NSURL, fileName: String, progressBlock: AWSS3TransferUtilityProgressBlock?, completionBlock: AWSS3TransferUtilityUploadCompletionHandlerBlock?) -> AWSTask<AnyObject> {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock
        
        let transferUtility = AWSS3TransferUtility.default()
        
        return transferUtility.uploadFile(file as URL,
            bucket: S3BucketName,
            key: fileName,
            contentType: "text/plain",
            expression: expression,
            completionHandler: completionBlock) .continueWith (block: { (task) -> AnyObject! in
            if let error = task.error {
                print("Error: %@",error.localizedDescription);
            }
            if let _ = task.result {
                print("Upload Starting!")
            // Do something with uploadTask.
            }
            return task;
        })
    }
}
