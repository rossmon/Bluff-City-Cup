//
//  CommishSettingsCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 3/11/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class CommishSettingsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingStatus: UILabel!
}
