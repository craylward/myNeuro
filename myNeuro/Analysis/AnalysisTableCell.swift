//
//  AnalysisTableCell.swift
//  myNeuro
//
//  Created by Charlie Aylward on 7/28/16.
//  Copyright © 2016 SJM. All rights reserved.
//

import Foundation
import UIKit

class AnalysisHeaderRow: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "AnalysisHeaderRow"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updrsLabel: UILabel!
}

class AnalysisSubheaderRow: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "AnalysisSubheaderRow"
    
    @IBOutlet weak var titleLabel: UILabel!
}

class AnalysisInfoRow: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "AnalysisInfoRow"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}

class AnalysisRowSeparator: UITableViewCell {
    // MARK: Properties
    static let reuseIdentifier = "AnalysisRowSeparator"
}