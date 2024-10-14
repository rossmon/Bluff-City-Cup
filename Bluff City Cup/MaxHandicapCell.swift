//
//  DrinkCartNumberCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/4/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class MaxHandicapCell: UITableViewCell {
    
    var tournament: Tournament!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func maxHandicapChange(_ sender: UITextField) {
        
        tournament.setMaxHandicap(Int(sender.text!)!)
        
        Model.sharedInstance.updateTournament(tournament) {() in }
    }
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var maxHandicapField: UITextField!
}
