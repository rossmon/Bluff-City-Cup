//
//  IndividualMatchTableViewCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/16/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class IndividualMatchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.playerName.font = UIFont(name:"Arial", size: playerName.font.pointSize)
        self.playerScore.font = UIFont(name:"Arial", size: playerScore.font.pointSize)
        self.scoreLabel.font = UIFont(name:"Arial", size: scoreLabel.font.pointSize)
        
        self.cellView.layer.cornerRadius = 7.0
        self.shadowView.layer.backgroundColor = UIColor.clear.cgColor
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowOffset = .zero
        self.shadowView.layer.shadowRadius = 4
        self.cellView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var playerScore: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
}
