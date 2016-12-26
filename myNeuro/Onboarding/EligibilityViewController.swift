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
    @IBOutlet weak var question4Answer: UISegmentedControl!
    @IBOutlet weak var question5Answer: UISegmentedControl!
    @IBOutlet weak var question6Answer: UISegmentedControl!
    @IBOutlet weak var question7Answer: UISegmentedControl!
    @IBAction func next(_ sender: UIBarButtonItem) {
        if (question1Answer.selectedSegmentIndex==0 &&
            question2Answer.selectedSegmentIndex==0 &&
            question3Answer.selectedSegmentIndex==1 &&
            question4Answer.selectedSegmentIndex==0 &&
            question5Answer.selectedSegmentIndex==1 &&
            question6Answer.selectedSegmentIndex==0 &&
            question7Answer.selectedSegmentIndex==0) {
            performSegue(withIdentifier: "toEligible", sender: nil)
        }
        else {
            performSegue(withIdentifier: "toIneligible", sender: nil)
        }
    }
    
    var question1Answered = false
    var question2Answered = false
    var question3Answered = false
    var question4Answered = false
    var question5Answered = false
    var question6Answered = false
    var question7Answered = false
    
    @IBAction func answerChanged(_ sender: UISegmentedControl) {
        
        switch question1Answer.selectedSegmentIndex {
        case 0, 1:
            question1Answered = true
        default:
            break
        }
        switch question2Answer.selectedSegmentIndex {
        case 0, 1:
            question2Answered = true
        default:
            break
        }
        switch question3Answer.selectedSegmentIndex {
        case 0, 1:
            question3Answered = true
        default:
            break
        }
        switch question3Answer.selectedSegmentIndex {
        case 0, 1:
            question3Answered = true
        default:
            break
        }
        switch question4Answer.selectedSegmentIndex {
        case 0, 1:
            question4Answered = true
        default:
            break
        }
        switch question5Answer.selectedSegmentIndex {
        case 0, 1:
            question5Answered = true
        default:
            break
        }
        switch question6Answer.selectedSegmentIndex {
        case 0, 1:
            question6Answered = true
        default:
            break
        }
        switch question7Answer.selectedSegmentIndex {
        case 0, 1:
            question7Answered = true
        default:
            break
        }
        if (question1Answered && question2Answered && question3Answered && question4Answered && question5Answered && question6Answered && question7Answered) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
}
