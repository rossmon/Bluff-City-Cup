//
//  MatchLengthCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/4/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

class MatchLengthCell: UITableViewCell {
    
    var tournament: Tournament!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var matchLengthSelector: UISegmentedControl!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func matchLengthChanged(_ sender: Any) {
        
        let segment = (sender as! UISegmentedControl)
        
        if tournament.matchesStarted() {
            if segment.selectedSegmentIndex == 0 {
                segment.selectedSegmentIndex = 1
            }
            else if segment.selectedSegmentIndex == 1 {
                segment.selectedSegmentIndex = 0
            }
            //matchAlreadyStartedAlert()
        }
        else {
            if segment.selectedSegmentIndex == 0 {
                //tournament.setMatchLength(9)
            }
            else if segment.selectedSegmentIndex == 1 {
                //tournament.setMatchLength(18)
            }
            
            Model.sharedInstance.updateTournament(tournament) {() in }
        }
        
    }
    @IBOutlet weak var settingLabel: UILabel!
    
}
