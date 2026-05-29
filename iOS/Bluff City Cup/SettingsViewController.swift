 //
//  SettingsViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/14/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

@objc
protocol SettingsViewControllerDelegate {
    
    @objc optional func toggleTopPanelSettings()
    @objc optional func collapseTopPanelSettings()
    @objc optional func changeViewSettings(_ menu: String)
    @objc optional func handlePanGesture(_ recognizer: UIPanGestureRecognizer)
    @objc optional func changeTournament()
    
}

class SettingsViewController: UIViewController {

    var delegate: SettingsViewControllerDelegate?
    
    var user: User!
    var tournament: Tournament!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIApplication.shared.statusBarStyle = .lightContent
        changeTournamentButton.layer.cornerRadius = 8
        
        
        self.changeTournamentButton.titleLabel?.font = UIFont(name:"Arial", size: self.changeTournamentButton.titleLabel?.font.pointSize ?? 24.0)
        
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var changeTournamentButton: UIButton!
    
    @IBAction func settingsTapped(_ sender: AnyObject) {
        
        delegate?.toggleTopPanelSettings?()
    }
    
    @IBAction func changeTournamentPressed(_ sender: Any) {
        delegate?.collapseTopPanelSettings!()
        delegate?.changeTournament?()
    }
    @IBAction func panHandle(_ sender: UIPanGestureRecognizer) {
        delegate?.handlePanGesture?(sender)
    }
    
}

extension SettingsViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        //Logic to change views?
        
        delegate?.collapseTopPanelSettings?()
        delegate?.changeViewSettings?(menu)
    }
}
