//
//  ScorecardViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 1/2/17.
//  Copyright © 2017 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

protocol ScorecardViewControllerDelegate {
    func closeScorecard()
}


class ScorecardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var match: Match!
    var user: User = User.sharedInstance
    @IBOutlet weak var titleLabel: UILabel!
    var delegate: ScorecardViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scorecardTable.delegate = self
        scorecardTable.dataSource = self
        
        titleLabel.text = "Match Handicap Strokes - " + match.getCourseName()
        
        //self.tableView.register(ScorecardCell.classForCoder(), forCellReuseIdentifier: "ScorecardCell")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    @IBOutlet var scorecardTable: UITableView!
    
    @IBAction func cancelScorecard(_ sender: Any) {
        delegate?.closeScorecard()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if match.doubles() {
            if match.getFormat() == "Best Ball" {
                return 8
            }
            else {
                return 5
            }
        }
        else {
            return 8
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ScorecardCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ScorecardCell
        
        var front9 = true
        if match.getCurrentHole() > 9 {
            front9 = false
        }
        if match.getCurrentHole() == 10 && Model.sharedInstance.getTournament().getMatchLength() == 9 && match.getStartingHole() == 1 {
            front9 = true
        }
        
        if indexPath.row == 0 {
            cell.setHoleNumber(front9: front9)
            //cell.setYards(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
        }
        else if indexPath.row == 1 {
            cell.setHandicap(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
        }
        else if indexPath.row == 2 {
            cell.setParNumber(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            //cell.setHoleNumber(front9: front9)
        }
        else if indexPath.row == 3 {
            cell.backgroundColor = UIColorFromRGB(0x0F296B)
            
            if match.getFormat() == "Best Ball" {
                
                cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
            else if match.doubles() {
                cell.doublesCell(team: "Blue", match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
            else {
                //SINGLES MATCH
                cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
        }
        else if indexPath.row == 4 {
            
            if match.getFormat() == "Best Ball" {
                cell.backgroundColor = UIColorFromRGB(0x0F296B)
                
                cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
            else if match.doubles() {
                cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                cell.doublesCell(team: "Red", match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
            else {
                //SINGLES MATCH
                cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
        }
        else if indexPath.row == 5 {
            cell.blankCellFormatting()
        }
        else if indexPath.row == 6 {
            cell.backgroundColor = UIColorFromRGB(0x0F296B)
            
            if match.getFormat() == "Best Ball" {
                cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                
                cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
            else {
                //SINGLES MATCH
                let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                
                cell.playerBestBallOrSinglesCell(player: singlesMatches[1].blueTeamPlayerOne(), match: singlesMatches[1], tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
        }
        else if indexPath.row == 7 {
            cell.backgroundColor = UIColorFromRGB(0xB70A1C)
            
            if match.getFormat() == "Best Ball" {
                
                cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
            else {
                //SINGLES MATCH
                let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                
                cell.playerBestBallOrSinglesCell(player: singlesMatches[1].redTeamPlayerOne(), match: singlesMatches[1], tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
        }
        
        return cell
    }
    
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeLeft
    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
