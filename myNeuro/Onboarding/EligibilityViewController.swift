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
    @IBOutlet weak var question1Yes: UIButton!
    @IBOutlet weak var question1No: UIButton!
    @IBOutlet weak var question2Label: UILabel!
    @IBOutlet weak var question2Yes: UIButton!
    @IBOutlet weak var question2No: UIButton!
    @IBOutlet weak var question3Label: UILabel!
    @IBOutlet weak var question3Yes: UIButton!
    @IBOutlet weak var question3No: UIButton!

    @IBAction func question1Yespressed(sender: UIButton) {
        sender.selected = true
        question1No.selected = false
    }
    @IBAction func question1NoPressed(sender: UIButton) {
        sender.selected = true
        question1Yes.selected = false
    }
    @IBAction func question2YesPressed(sender: UIButton) {
        sender.selected = true
        question2No.selected = false
    }
    @IBAction func question2NoPressed(sender: UIButton) {
        sender.selected = true
        question2Yes.selected = false
    }
    @IBAction func question3YesPressed(sender: UIButton) {
        sender.selected = true
        question3No.selected = false
    }
    @IBAction func question3NoPressed(sender: UIButton) {
        sender.selected = true
        question3Yes.selected = false
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            // handling code
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.enabled = false
        
    }
}

extension EligibilityViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        switch reason {
        case .Completed:
            performSegueWithIdentifier("unwindToStudy", sender: nil)
            
        case .Discarded, .Failed, .Saved:
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

}