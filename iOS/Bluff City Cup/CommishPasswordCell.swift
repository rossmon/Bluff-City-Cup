//
//  DrinkCartNumberCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/4/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class CommishPasswordCell: UITableViewCell {
    
    var tournament: Tournament!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func commishPasswordChange(_ sender: UITextField) {
        
        tournament.setCommissionerPassword(sender.text!)
        
        Model.sharedInstance.updateTournament(tournament) {() in }
    }
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var commishPasswordField: UITextField!
}
