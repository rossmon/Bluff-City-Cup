//
//  MenuTableViewCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/24/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.menuTitle.font = UIFont(name:"Arial", size: self.menuTitle.font.pointSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var menuTitle: UILabel!
}
