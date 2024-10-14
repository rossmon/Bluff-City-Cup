//
//  MatchTableViewCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/16/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.blueTeamView.layer.cornerRadius = 8.0
        self.redTeamView.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var holeTitle: UILabel!
    @IBOutlet weak var blueTeamSinglesLabel: UILabel!
    @IBOutlet weak var holeNumber: UILabel!
    
    
    @IBOutlet weak var blueTeamView: UIView!
    @IBOutlet weak var redTeamSinglesLabel: UILabel!
    @IBOutlet weak var blueTeamPlayerOneLabel: UILabel!
    @IBOutlet weak var blueTeamPlayerTwoLabel: UILabel!
    @IBOutlet weak var blueTeamMatchScore: UILabel!
    
    
    @IBOutlet weak var redTeamView: UIView!
    @IBOutlet weak var redTeamPlayerOneLabel: UILabel!
    @IBOutlet weak var redTeamPlayerTwoLabel: UILabel!
    @IBOutlet weak var redTeamMatchScore: UILabel!
}
