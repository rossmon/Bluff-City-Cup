//
//  MatchScorecardViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 1/31/17.
//  Copyright © 2017 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

enum SideShowing {
    case front9
    case back9
}

enum ScorecardView {
    case score
    case handicapStrokes
}

protocol MatchScorecardViewControllerDelegate {
    func closeMatchScorecard()
}

class MatchScorecardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scorecardTable: UITableView!

    @IBOutlet weak var frontButton: UIButton!
    var match: Match!
    var user: User = User.sharedInstance
    @IBOutlet weak var titleLabel: UILabel!
    var delegate: MatchScorecardViewControllerDelegate?
    @IBOutlet weak var strokeHcpButton: UIButton!
    var sideShowing: SideShowing = .front9
    var scorecardView: ScorecardView = .score
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frontButton.layer.cornerRadius = 5
        frontButton.layer.borderWidth = 1
        frontButton.layer.borderColor = UIColor.black.cgColor
        
        strokeHcpButton.layer.cornerRadius = 5
        strokeHcpButton.layer.borderWidth = 1
        strokeHcpButton.layer.borderColor = UIColor.black.cgColor
        strokeHcpButton.setTitle("Show Handicap Strokes", for: .normal)
        
        match = Model.sharedInstance.tournament.getCurrentMatch(user.getPlayer()!)
        
        if Model.sharedInstance.tournament.getMatchLength() == 9 {
            frontButton.isHidden = true
        }
        else {
            frontButton.isHidden = false
            
            if match.getCurrentHole() < 10 {
                frontButton.setTitle("View Back 9", for: .normal)
            }
            else {
                frontButton.setTitle("View Front 9", for: .normal)
            }
        }
        
        scorecardTable.delegate = self
        scorecardTable.dataSource = self
        
        titleLabel.text = "Match Scorecard - " + match.getCourseName()
        
        var front9 = true
        if match.getCurrentHole() > 9 {
            front9 = false
        }
        if match.getCurrentHole() == 10 && Model.sharedInstance.getTournament().getMatchLength() == 9 && match.getStartingHole() == 1 {
            front9 = true
        }
        
        if front9 { sideShowing = .front9 }
        else { sideShowing = .back9 }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
        
    @IBAction func frontButtonPressed(_ sender: Any) {
        
        if sideShowing == .front9 {
            sideShowing = .back9
            frontButton.setTitle("View Front 9", for: .normal)
        }
        else {
            sideShowing = .front9
            frontButton.setTitle("View Back 9", for: .normal)
        }
        
        self.scorecardTable.reloadData()
    }
    
    @IBAction func scoreHcpStrokesButtonPressed(_ sender: Any) {
        
        if scorecardView == .score {
            scorecardView = .handicapStrokes
            strokeHcpButton.setTitle("Show Hole Scores", for: .normal)
        }
        else {
            scorecardView = .score
            strokeHcpButton.setTitle("Show Handicap Strokes", for: .normal)
        }
        self.scorecardTable.reloadData()
    }

    @IBAction func cancelScorecard(_ sender: Any) {
        delegate?.closeMatchScorecard()
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
        if scorecardView == .score {
            let cellIdentifier = "MatchScorecardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchScorecardCell
            
            var front9 = true
            if sideShowing != .front9 {
                front9 = false
            }
            
            if indexPath.row == 0 {
                //cell.setYards(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.setHoleNumber(front9: front9)
            }
            else if indexPath.row == 1 {
                cell.setHandicap(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
            else if indexPath.row == 2 {
                //cell.setHoleNumber(front9: front9)
                cell.setParNumber(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
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
                    
                    //cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                    
                    let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    cell.playerBestBallOrSinglesCell(player: singlesMatches[0].blueTeamPlayerOne(), match: singlesMatches[0], tournament: Model.sharedInstance.getTournament(), front9: front9)
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
                    //cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                    
                    let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    cell.playerBestBallOrSinglesCell(player: singlesMatches[0].redTeamPlayerOne(), match: singlesMatches[0], tournament: Model.sharedInstance.getTournament(), front9: front9)
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
                    let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player! ,round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    cell.playerBestBallOrSinglesCell(player: singlesMatches[1].redTeamPlayerOne(), match: singlesMatches[1], tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
            }
            
            cell.setSizes(front9)
            
            return cell
        }
        else {
            /*
            let cellIdentifier = "MatchScorecardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchScorecardCell
            */
 
            let cellIdentifier = "ScorecardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ScorecardCell
            
            var front9 = true
            if sideShowing != .front9 {
                front9 = false
            }
            
            /*
            var front9 = true
            if match.getCurrentHole() > 9 {
                front9 = false
            }
            if match.getCurrentHole() == 10 && Model.sharedInstance.getTournament().getMatchLength() == 9 && match.getStartingHole() == 1 {
                front9 = true
            }*/
            
            if indexPath.row == 0 {
                //cell.setYards(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.setHoleNumber(front9: front9)
            }
            else if indexPath.row == 1 {
                cell.setHandicap(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
            }
            else if indexPath.row == 2 {
                //cell.setHoleNumber(front9: front9)
                cell.setParNumber(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
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
                    //cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                    
                    let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player! ,round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    cell.playerBestBallOrSinglesCell(player: singlesMatches[0].blueTeamPlayerOne(), match: singlesMatches[0], tournament: Model.sharedInstance.getTournament(), front9: front9)
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
                    //cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                    
                    let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    cell.playerBestBallOrSinglesCell(player: singlesMatches[0].redTeamPlayerOne(), match: singlesMatches[0], tournament: Model.sharedInstance.getTournament(), front9: front9)
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
            
            cell.setSizes(front9)
            
            return cell
        }
        
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
