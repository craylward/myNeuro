//
//  InclusionCriteriaViewController.swift
//  myNeuro
//
//  Created by Charlie Aylward on 5/24/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit

class EligibilityViewController: UITableViewController {
    // MARK: IB actions
    @IBOutlet weak var question1Label: UILabel!
    @IBOutlet weak var question2Label: UILabel!
    @IBOutlet weak var question3Label: UILabel!
    @IBOutlet weak var question1Answer: UISegmentedControl!
    @IBOutlet weak var question2Answer: UISegmentedControl!
    @IBOutlet weak var question3Answer: UISegmentedControl!
    @IBAction func next(sender: UIBarButtonItem) {
        if (question1Answer.selectedSegmentIndex==0 && question2Answer.selectedSegmentIndex==0 && question3Answer.selectedSegmentIndex==0)
        {
            performSegueWithIdentifier("toEligible", sender: nil)
        }
        else if question1Answer.selectedSegmentIndex==1 || question2Answer.selectedSegmentIndex==1 || question3Answer.selectedSegmentIndex==1
        {
            performSegueWithIdentifier("toIneligible", sender: nil)
        }
        else
        {
            NSLog("ERROR")
        }
    }
    
    var question1Answered = false
    var question2Answered = false
    var question3Answered = false
    
    @IBAction func answerChanged(sender: UISegmentedControl) {
        
        switch question1Answer.selectedSegmentIndex
        {
        case 0:
            question1Answered = true
        case 1:
            question1Answered = true
        default:
            break
        }
        switch question2Answer.selectedSegmentIndex
        {
        case 0:
            question2Answered = true
        case 1:
            question2Answered = true
        default:
            break
        }
        switch question3Answer.selectedSegmentIndex
        {
        case 0:
            question3Answered = true
        case 1:
            question3Answered = true
        default:
            break
        }
        if (question1Answered && question2Answered && question3Answered)
        {
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.enabled = false
        
    }
}