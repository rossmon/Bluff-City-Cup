//
//  RoundCourseCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/7/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

class RoundCourseCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    @IBOutlet weak var courseNameLabel: UILabel!
    
    @IBOutlet weak var roundNumberLabel: UILabel!
    
}
