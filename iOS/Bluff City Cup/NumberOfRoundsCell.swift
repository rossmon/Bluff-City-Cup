//
//  NumberOfRoundsCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/4/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

class NumberOfRoundsCell: UITableViewCell {
    
    var tournament: Tournament!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBOutlet weak var numberOfRoundsSelector: UISegmentedControl!
    @IBOutlet weak var settingLabel: UILabel!
    
    @IBAction func numberOfRoundsChanged(_ sender: Any) {
        
        let segment = (sender as! UISegmentedControl)
        let segmentTitle = segment.titleForSegment(at: segment.selectedSegmentIndex)
        
        if tournament.matchesStarted() {
            self.numberOfRoundsSelector.selectedSegmentIndex = tournament.getNumberOfRounds() - 1
            //matchAlreadyStartedAlert()
        }
        else {
            self.tournament.setNumberOfRounds(Int(segmentTitle!)!)
            
            Model.sharedInstance.updateTournament(tournament) {() in }
        }
        
        
        
        
    }
}
