//
//  EditDetailTableViewCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 6/12/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class MatchViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBOutlet weak var playersName: UILabel!
 
    @IBOutlet weak var roundMatchGroup: UILabel!
}
