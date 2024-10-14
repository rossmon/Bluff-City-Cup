//
//  DrinkCartOnCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/4/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

class DrinkCartOnCell: UITableViewCell {
    
    var tournament: Tournament!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // Configure the view for the selected state
    }
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var drinkCartSwitch: UISwitch!
    
    @IBAction func drinkCartChanged(_ sender: Any) {
        
        let segment = (sender as! UISwitch)

        tournament.setDrinkCart(segment.isOn)
        
        Model.sharedInstance.updateTournament(tournament) {() in }
    }
}
