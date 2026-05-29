//
//  AddPlayerView.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/5/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

class AddPlayerView: UIViewController {

    @IBOutlet weak var navBar: UINavigationItem!
    var player: Player!
    var match: Match!
    var editType: String!
    @IBOutlet weak var playerNameField: UITextField!
    @IBOutlet weak var playerHandicap: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editType == "AddPlayer" {
            self.navBar.title = "Add Player"
            self.deleteButton.isHidden = true
        }
        else if editType == "AddMatch" {
            self.navBar.title = "Add Match"
            self.deleteButton.isHidden = true
        }
        
        
        

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

