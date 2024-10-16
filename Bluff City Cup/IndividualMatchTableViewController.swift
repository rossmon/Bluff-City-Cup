//
//  IndividualMatchTableViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/16/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

protocol IndividualMatchTableViewControllerDelegate {
    func updateTeamHoleScores(_ current_match: Match)
    func selectedRow(_ cell: IndividualMatchTableViewCell, tableView: UITableView, indexPath: IndexPath)
}

class IndividualMatchTableViewController: UITableViewController {

    var tournament: Tournament!
    var match: Match!
    var viewingHoleNumber: Int!
    var user: User!
    
    var delegate: IndividualMatchTableViewControllerDelegate?
    
    var selectedStroke: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.individualMatchTableView.backgroundColor = UIColorFromRGB(0xAAAAAA)
        
        self.individualMatchTableView.rowHeight = 80
        
        delegate?.updateTeamHoleScores(match)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    
    }
    
    @IBOutlet var individualMatchTableView: UITableView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if match.getFormat() == "Singles" {
            return 4
        }
        
        else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if match.getFormat() == "Two Man Scramble" || match.getFormat() == "Alternate Shot" || match.getFormat() == "Singles" {
            return 1
        }
        else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let customCell = cell as? IndividualMatchTableViewCell {
            if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble"{
                if (indexPath as NSIndexPath).row == 0 {
                    if (indexPath as NSIndexPath).section == 0 {
                        customCell.cellView.backgroundColor = UIColorFromRGB(0x0F296B)
                    }
                    else if (indexPath as NSIndexPath).section == 1 {
                        customCell.cellView.backgroundColor = UIColorFromRGB(0xB70A1C)
                    }
                }
                else if (indexPath as NSIndexPath).row == 1 {
                    if (indexPath as NSIndexPath).section == 0 {
                        customCell.cellView.backgroundColor = UIColorFromRGB(0x0F296B)
                    }
                    else if (indexPath as NSIndexPath).section == 1 {
                        customCell.cellView.backgroundColor = UIColorFromRGB(0xB70A1C)
                    }
                }
            }
            else if match.getFormat() == "Alternate Shot" || match.getFormat() == "Two Man Scramble" {
                if (indexPath as NSIndexPath).section == 0 {
                    customCell.cellView.backgroundColor = UIColorFromRGB(0x0F296B)
                }
                else if (indexPath as NSIndexPath).section == 1 {
                    customCell.cellView.backgroundColor = UIColorFromRGB(0xB70A1C)
                }
            }
            else if match.getFormat() == "Singles" {
                
                if (indexPath as NSIndexPath).section == 0 {
                    customCell.cellView.backgroundColor = UIColorFromRGB(0x0F296B)
                }
                else if (indexPath as NSIndexPath).section == 2 {
                    customCell.cellView.backgroundColor = UIColorFromRGB(0x0F296B)
                }
                else if (indexPath as NSIndexPath).section == 1 {
                    customCell.cellView.backgroundColor = UIColorFromRGB(0xB70A1C)
                }
                else if (indexPath as NSIndexPath).section == 3 {
                    customCell.cellView.backgroundColor = UIColorFromRGB(0xB70A1C)
                }
            }
        }
        
        

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "IndividualMatchTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! IndividualMatchTableViewCell
        
        var matchHole = match.getCurrentHole()
        if matchHole > 18 || matchHole == 10 && match.getMatchLength() == 9 {
            matchHole = matchHole - 1
        }
        
        if match.getFormat() == "Best Ball" {
            if (indexPath as NSIndexPath).row == 0 {
                if (indexPath as NSIndexPath).section == 0 {
                    cell.playerName.text = "\(match.blueTeamPlayerOne().getName()) (\(match.blueTeamPlayerOne().getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                    if match.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                        cell.playerScore.text = ""
                    }
                    else {
                        cell.playerScore.text = String(match.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                        
                    }
                }
                else if (indexPath as NSIndexPath).section == 1 {
                    cell.playerName.text = "\(match.redTeamPlayerOne().getName()) (\(match.redTeamPlayerOne().getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                    if match.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                        cell.playerScore.text = ""
                    }
                    else {
                        cell.playerScore.text = String(match.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                    }
                }
            }
            else if (indexPath as NSIndexPath).row == 1 {
                if (indexPath as NSIndexPath).section == 0 {
                    cell.playerName.text = "\(match.blueTeamPlayerTwo()!.getName()) (\(match.blueTeamPlayerTwo()!.getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                    if match.blueTeamPlayerTwo()?.getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                        cell.playerScore.text = ""
                    }
                    else {
                        cell.playerScore.text = String(match.blueTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: match.getRound()))
                    }
                }
                else if (indexPath as NSIndexPath).section == 1 {
                    cell.playerName.text = "\(match.redTeamPlayerTwo()!.getName()) (\(match.redTeamPlayerTwo()!.getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                    if match.redTeamPlayerTwo()?.getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                        cell.playerScore.text = ""
                    }
                    else {
                        cell.playerScore.text = String(match.redTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: match.getRound()))
                    }
                }
            }
        }
        else if match.getFormat() == "Shamble" {
            if (indexPath as NSIndexPath).row == 0 {
                if (indexPath as NSIndexPath).section == 0 {
                    cell.playerName.text = "\(match.blueTeamPlayerOne().getName()) (\(match.blueTeamPlayerOne().shambleHandicap(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                    if match.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                        cell.playerScore.text = ""
                    }
                    else {
                        cell.playerScore.text = String(match.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                        
                    }
                }
                else if (indexPath as NSIndexPath).section == 1 {
                    cell.playerName.text = "\(match.redTeamPlayerOne().getName()) (\(match.redTeamPlayerOne().shambleHandicap(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                    if match.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                        cell.playerScore.text = ""
                    }
                    else {
                        cell.playerScore.text = String(match.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                    }
                }
            }
            else if (indexPath as NSIndexPath).row == 1 {
                if (indexPath as NSIndexPath).section == 0 {
                    cell.playerName.text = "\(match.blueTeamPlayerTwo()!.getName()) (\(match.blueTeamPlayerTwo()!.shambleHandicap(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                    if match.blueTeamPlayerTwo()?.getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                        cell.playerScore.text = ""
                    }
                    else {
                        cell.playerScore.text = String(match.blueTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: match.getRound()))
                    }
                }
                else if (indexPath as NSIndexPath).section == 1 {
                    cell.playerName.text = "\(match.redTeamPlayerTwo()!.getName()) (\(match.redTeamPlayerTwo()!.shambleHandicap(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                    if match.redTeamPlayerTwo()?.getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                        cell.playerScore.text = ""
                    }
                    else {
                        cell.playerScore.text = String(match.redTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: match.getRound()))
                    }
                }
            }
        }
        else if match.getFormat() == "Alternate Shot" || match.getFormat() == "Two Man Scramble" {
            
            let teamHandicaps = match.getTeamHandicap()
            
            if (indexPath as NSIndexPath).section == 0 {
                let bluePlayer1Name = match.blueTeamPlayerOne().getName().split{$0 == " "}.map(String.init)
                let bluePlayer2Name = match.blueTeamPlayerTwo()!.getName().split{$0 == " "}.map(String.init)
                
                cell.playerName.text = "\(bluePlayer1Name[1])/\(bluePlayer2Name[1]) (\(teamHandicaps.blueTeamHandicap))"
                if match.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                    cell.playerScore.text = ""
                }
                else {
                    cell.playerScore.text = String(match.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                }
            }
            else if (indexPath as NSIndexPath).section == 1 {
                let redPlayer1Name = match.redTeamPlayerOne().getName().split{$0 == " "}.map(String.init)
                let redPlayer2Name = match.redTeamPlayerTwo()!.getName().split{$0 == " "}.map(String.init)
                
                cell.playerName.text = "\(redPlayer1Name[1])/\(redPlayer2Name[1]) (\(teamHandicaps.redTeamHandicap))"
                if match.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                    cell.playerScore.text = ""
                }
                else {
                    cell.playerScore.text = String(match.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                }
            }
        }
        else if match.getFormat() == "Singles" {
            
            let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
            
            if (indexPath as NSIndexPath).section == 0 {
                cell.playerName.text = "\(singlesMatches[0].blueTeamPlayerOne().getName()) (\(singlesMatches[0].blueTeamPlayerOne().getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                if singlesMatches[0].blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                    cell.playerScore.text = ""
                }
                else {
                    cell.playerScore.text = String(singlesMatches[0].blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                }
            }
            else if (indexPath as NSIndexPath).section == 2 {
                cell.playerName.text = "\(singlesMatches[1].blueTeamPlayerOne().getName()) (\(singlesMatches[1].blueTeamPlayerOne().getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                if singlesMatches[1].blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                    cell.playerScore.text = ""
                }
                else {
                    cell.playerScore.text = String(singlesMatches[1].blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                }
            }
            else if (indexPath as NSIndexPath).section == 1 {
                cell.playerName.text = "\(singlesMatches[0].redTeamPlayerOne().getName()) (\(singlesMatches[0].redTeamPlayerOne().getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                if singlesMatches[0].redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: singlesMatches[0].getRound()) == 0 {
                    cell.playerScore.text = ""
                }
                else {
                    cell.playerScore.text = String(singlesMatches[0].redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: singlesMatches[0].getRound()))
                }
            }
            else if (indexPath as NSIndexPath).section == 3 {
                cell.playerName.text = "\(singlesMatches[1].redTeamPlayerOne().getName()) (\(singlesMatches[1].redTeamPlayerOne().getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())))"
                if singlesMatches[1].redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()) == 0 {
                    cell.playerScore.text = ""
                }
                else {
                    cell.playerScore.text = String(singlesMatches[1].redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: match.getRound()))
                }
            }
        }
        
        
        return cell
    }
    
    
    /*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let title: UILabel = UILabel()
        
        if section == 0 {
            title.backgroundColor = UIColorFromRGB(0x0F296B)
            if match.getFormat() == "Singles" {
                title.text = "Blue Team - Match 1"
            }
            else {
                title.text = "Blue Team"
            }
            title.textColor = UIColor.white
            title.font = UIFont(name: "Avenir Next Condensed Regular", size: 15.0)
        }
        else if section == 1 {
            title.backgroundColor = UIColorFromRGB(0xB70A1C)
            if match.getFormat() == "Singles" {
                title.text = "Red Team - Match 1"
            }
            else {
                title.text = "Red Team"
            }
            title.textColor = UIColor.white
            title.font = UIFont(name: "Avenir Next Condensed Regular", size: 15.0)
        }
        else if section == 2 {
            title.backgroundColor = UIColorFromRGB(0x0F296B)
            if match.getFormat() == "Singles" {
                title.text = "Blue Team - Match 2"
            }
            else {
                title.text = "Blue Team"
            }
            title.textColor = UIColor.white
            title.font = UIFont(name: "Avenir Next Condensed Regular", size: 15.0)
        }
        else if section == 3 {
            title.backgroundColor = UIColorFromRGB(0xB70A1C)
            if match.getFormat() == "Singles" {
                title.text = "Red Team - Match 2"
            }
            else {
                title.text = "Red Team"
            }

            title.textColor = UIColor.white
            title.font = UIFont(name: "Avenir Next Condensed Regular", size: 15.0)
        }
        
        
        return title
        
    }
    */
 
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: IndividualMatchTableViewCell = tableView.cellForRow(at: indexPath) as! IndividualMatchTableViewCell
        
        delegate?.selectedRow(cell, tableView: tableView, indexPath: indexPath)

    }
    
    func updateCellWithScore(_ cell: IndividualMatchTableViewCell, tableView: UITableView, indexPath: IndexPath, score: Int, viewingHoleNumber: Int) {
        
        cell.playerScore.text = String(score)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath as NSIndexPath).row == 0 {
            if (indexPath as NSIndexPath).section == 0 {
                match.blueTeamPlayerOne().setHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), score: score, round: match.getRound())
                if match.getFormat() == "Alternate Shot" || match.getFormat() == "Two Man Scramble" {
                    match.blueTeamPlayerTwo()!.setHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), score: score, round: match.getRound())
                }
            }
            else if (indexPath as NSIndexPath).section == 1 {
                match.redTeamPlayerOne().setHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), score: score, round: match.getRound())
                if match.getFormat() == "Alternate Shot" || match.getFormat() == "Two Man Scramble" {
                    match.redTeamPlayerTwo()!.setHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), score: score, round: match.getRound())
                }
            }
        }
        else if (indexPath as NSIndexPath).row == 1 {
            if (indexPath as NSIndexPath).section == 0 {
                match.blueTeamPlayerTwo()?.setHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), score: score, round: match.getRound())
            }
            else if (indexPath as NSIndexPath).section == 1 {
                match.redTeamPlayerTwo()?.setHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), score: score, round: match.getRound())
            }
        }
        
        delegate?.updateTeamHoleScores(match)
    }
    
    func updateCellStrokes(_ viewingHoleNumber: Int) {
        let doubles = tournament.getCurrentMatch(user.getPlayer()!)?.doubles()
        
        if doubles == true {
            for i in 0...(individualMatchTableView.numberOfSections-1) {
                for j in 0...(individualMatchTableView.numberOfRows(inSection: i)-1) {
                    if j == 0 {
                        if i == 0 {
                            if match.blueTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()) == 0 {
                                (individualMatchTableView.cellForRow(at: IndexPath(row: j, section: i)) as! IndividualMatchTableViewCell).playerScore.text = ""
                            }
                            else {
                                (individualMatchTableView.cellForRow(at: IndexPath(row: j, section: i)) as! IndividualMatchTableViewCell).playerScore.text = String(match.blueTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()))
                                
                            }
                        }
                        else if i == 1 {
                            if match.redTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()) == 0 {
                                (individualMatchTableView.cellForRow(at: IndexPath(row: j, section: i)) as! IndividualMatchTableViewCell).playerScore.text = ""
                            }
                            else {
                                (individualMatchTableView.cellForRow(at: IndexPath(row: j, section: i)) as! IndividualMatchTableViewCell).playerScore.text = String(match.redTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()))
                            }
                        }
                    }
                    else if j == 1 {
                        if i == 0 {
                            if match.blueTeamPlayerTwo()?.getHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()) == 0 {
                                (individualMatchTableView.cellForRow(at: IndexPath(row: j, section: i)) as! IndividualMatchTableViewCell).playerScore.text = ""
                            }
                            else {
                                (individualMatchTableView.cellForRow(at: IndexPath(row: j, section: i)) as! IndividualMatchTableViewCell).playerScore.text = String(match.blueTeamPlayerTwo()!.getHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()))
                            }
                        }
                        else if i == 1 {
                            if match.redTeamPlayerTwo()?.getHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()) == 0 {
                                (individualMatchTableView.cellForRow(at: IndexPath(row: j, section: i)) as! IndividualMatchTableViewCell).playerScore.text = ""
                            }
                            else {
                                (individualMatchTableView.cellForRow(at: IndexPath(row: j, section: i)) as! IndividualMatchTableViewCell).playerScore.text = String(match.redTeamPlayerTwo()!.getHoleScore(tournament.getCourseWithName(name: match.getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()))
                            }
                        }
                    }
                }
            }

        }
        else {
            let matches = tournament.getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
            
            if matches[0].blueTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: matches[0].getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()) == 0 {
                    (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! IndividualMatchTableViewCell).playerScore.text = ""
            }
            else {
                (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! IndividualMatchTableViewCell).playerScore.text =
                    String(matches[0].blueTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: matches[0].getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()))
            }
            
            if matches[0].redTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: matches[0].getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()) == 0 {
                (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! IndividualMatchTableViewCell).playerScore.text = ""
            }
            else {
                (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! IndividualMatchTableViewCell).playerScore.text =
                    String(matches[0].redTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: matches[0].getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()))
            }
            
            if matches[1].blueTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: matches[0].getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()) == 0 {
                (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! IndividualMatchTableViewCell).playerScore.text = ""
            }
            else {
                (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! IndividualMatchTableViewCell).playerScore.text =
                    String(matches[1].blueTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: matches[0].getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()))
            }
            
            if matches[1].redTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: matches[0].getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()) == 0 {
                (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! IndividualMatchTableViewCell).playerScore.text = ""
            }
            else {
                (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! IndividualMatchTableViewCell).playerScore.text =
                    String(matches[1].redTeamPlayerOne().getHoleScore(tournament.getCourseWithName(name: matches[0].getCourseName()).getHole(viewingHoleNumber).getNumber(), round: match.getRound()))
            }
            
        }
        
    }
    
    func allMatchScoresEntered() -> Bool {
        var allEntered = true
        
        for i in 0...(individualMatchTableView.numberOfSections-1) {
            if (individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: i)) as! IndividualMatchTableViewCell).playerScore.text == "" {
                allEntered = false
            }
        }
        
        return allEntered
    }
    
    func getSinglesMatchScores() -> (Int,Int,Int,Int){
        var match1BluePlayer = Int()
        var match1RedPlayer = Int()
        var match2BluePlayer = Int()
        var match2RedPlayer = Int()
        
        match1BluePlayer = Int((individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! IndividualMatchTableViewCell).playerScore.text!)!
        match1RedPlayer = Int((individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! IndividualMatchTableViewCell).playerScore.text!)!
        match2BluePlayer = Int((individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! IndividualMatchTableViewCell).playerScore.text!)!
        match2RedPlayer = Int((individualMatchTableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! IndividualMatchTableViewCell).playerScore.text!)!
        
        return (match1BluePlayer,match1RedPlayer,match2BluePlayer,match2RedPlayer)
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
