//
//  MatchTableViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/16/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

protocol MatchTableViewControllerDelegate {
    func updateScoreboard(_ newTournament: Tournament)
    func showScorecard(_ match: Match)
}

class MatchTableViewController: UITableViewController {
    
    var tournament: Tournament! = Tournament()
    var delegate: MatchTableViewControllerDelegate?
    var matchScorecardViewController: MatchScorecardViewController!
    
    @objc func refreshData()
    {
        // Updating your data here...
        print("Refreshing")
        
        Model.sharedInstance.refresh { errorString in
            self.tournament = Model.sharedInstance.getTournament()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            print("Done Refreshing")
            
            self.delegate?.updateScoreboard(self.tournament)
            self.tableView.reloadData()
        }
        
        User.sharedInstance.updateRole(tournamentName: tournament.getName()) {}
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tournament = Model.sharedInstance.getTournament()
        
        refreshControl = UIRefreshControl()
        
        self.matchTableView.backgroundColor = UIColorFromRGB(0xAAAAAA)
        self.refreshControl?.addTarget(self, action: #selector(MatchTableViewController.refreshData), for: UIControl.Event.valueChanged)
        self.tableView?.addSubview(refreshControl!)
        
        self.matchTableView.delegate = self
        self.matchTableView.dataSource = self
        self.matchTableView.isEditing = false
        self.matchTableView.allowsSelection = true
        self.view = matchTableView

        
        print("Done Match Table View Load")
        
        Model.sharedInstance.refresh() { errorDesc in
            DispatchQueue.main.async {
                self.tournament = Model.sharedInstance.getTournament()
                self.tableView.reloadData()
                self.delegate?.updateScoreboard(self.tournament)
                self.tableView.reloadData()
            }
        }

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
    
    @IBOutlet var matchTableView: UITableView!
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournament.getMatches().count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let matchObject = self.tournament.getMatchesSortedForTable()[(indexPath).row]
        print(matchObject.blueTeamPlayerOne().getName())
        

        delegate?.showScorecard(matchObject)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MatchTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchTableViewCell
        
        //let matchObject = self.tournament.getRoundMatches(tournament.getCurrentRound())[(indexPath as NSIndexPath).row]
        let matchObject = self.tournament.getMatchesSortedForTable()[(indexPath as NSIndexPath).row]
        //if let matchObject = self.matches?[indexPath.row] {
            if matchObject.doubles() {
                cell.blueTeamPlayerOneLabel.text = matchObject.blueTeamPlayerOne().name
                cell.blueTeamPlayerTwoLabel.text = matchObject.blueTeamPlayerTwo()!.name
                
                cell.redTeamPlayerOneLabel.text = matchObject.redTeamPlayerOne().name
                cell.redTeamPlayerTwoLabel.text = matchObject.redTeamPlayerTwo()!.name
                
                cell.blueTeamSinglesLabel.text = ""
                cell.redTeamSinglesLabel.text = ""
                cell.blueTeamSinglesLabel.isHidden = true
                cell.redTeamSinglesLabel.isHidden = true
                
                cell.blueTeamPlayerOneLabel.isHidden = false
                cell.redTeamPlayerOneLabel.isHidden = false
                cell.blueTeamPlayerTwoLabel.isHidden = false
                cell.redTeamPlayerTwoLabel.isHidden = false
            }
            else {
                cell.blueTeamSinglesLabel.isHidden = false
                cell.redTeamSinglesLabel.isHidden = false
                cell.blueTeamSinglesLabel.text = matchObject.blueTeamPlayerOne().name
                cell.redTeamSinglesLabel.text = matchObject.redTeamPlayerOne().name

                cell.blueTeamPlayerOneLabel.text = ""
                cell.redTeamPlayerOneLabel.text = ""
                cell.blueTeamPlayerOneLabel.isHidden = true
                cell.redTeamPlayerOneLabel.isHidden = true
                
                cell.blueTeamPlayerTwoLabel.text = ""
                cell.redTeamPlayerTwoLabel.text = ""
                cell.blueTeamPlayerTwoLabel.isHidden = true
                cell.redTeamPlayerTwoLabel.isHidden = true
            }
        
        if matchObject.winningTeam() == "Blue" {
            //cell.blueTeamMatchScore.text = tournament.getMatchScore(matchObject)
           cell.blueTeamMatchScore.text = matchObject.currentScoreString()
            cell.redTeamMatchScore.text = nil
            matchCellBlueUp(cell)
        }
        else if matchObject.winningTeam() == "Red" {
            //cell.redTeamMatchScore.text = tournament.getMatchScore(matchObject)
            cell.redTeamMatchScore.text = matchObject.currentScoreString()
            cell.blueTeamMatchScore.text = nil
            matchCellRedUp(cell)
        }
        else {
            //cell.blueTeamMatchScore.text = tournament.getMatchScore(matchObject)
            //cell.redTeamMatchScore.text = tournament.getMatchScore(matchObject)
            
            cell.blueTeamMatchScore.text = matchObject.currentScoreString()
            cell.redTeamMatchScore.text = matchObject.currentScoreString()
            matchCellAllSquared(cell)
        }
        
        //Set hole number
        if matchObject.isCompleted() {
        
                /*(matchObject.getStartingHole() == 10 && matchObject.getCurrentHole() > 18) || (matchObject.getCurrentHole() > tournament.getMatchLength() && matchObject.getStartingHole() == 1) {*/
            cell.holeNumber.text = "Ended"
            cell.holeTitle.text = "Match"
        }
        else if matchObject.getCurrentHole() == matchObject.getStartingHole() {
            cell.holeNumber.text = "Started"
            cell.holeTitle.text = "Not"
        }
        else {
            cell.holeNumber.text = String(matchObject.getCurrentHole())
            cell.holeTitle.text = "Hole"
        }
        
        print("Done Cell \((indexPath as NSIndexPath).row)")
        
        
        return cell
    }
    
    

    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func matchCellAllSquared(_ cell: MatchTableViewCell) {
        cell.blueTeamView.layer.backgroundColor = UIColor.white.cgColor
        cell.redTeamView.layer.backgroundColor = UIColor.white.cgColor
        
        cell.blueTeamPlayerOneLabel.textColor = UIColor.black
        cell.redTeamPlayerOneLabel.textColor = UIColor.black
        
        cell.blueTeamPlayerTwoLabel.textColor = UIColor.black
        cell.redTeamPlayerTwoLabel.textColor = UIColor.black
        
        cell.blueTeamSinglesLabel.textColor = UIColor.black
        cell.redTeamSinglesLabel.textColor = UIColor.black
        
        cell.redTeamMatchScore.textColor = UIColor.black
        cell.blueTeamMatchScore.textColor = UIColor.black
    }
    func matchCellBlueUp(_ cell: MatchTableViewCell) {
        cell.blueTeamView.layer.backgroundColor = UIColorFromRGB(0x0F296B).cgColor
        cell.redTeamView.layer.backgroundColor = UIColor.white.cgColor
        
        cell.blueTeamPlayerOneLabel.textColor = UIColor.white
        cell.redTeamPlayerOneLabel.textColor = UIColor.black
        
        cell.blueTeamPlayerTwoLabel.textColor = UIColor.white
        cell.redTeamPlayerTwoLabel.textColor = UIColor.black
        
        cell.blueTeamSinglesLabel.textColor = UIColor.white
        cell.redTeamSinglesLabel.textColor = UIColor.black
        
        cell.blueTeamMatchScore.textColor = UIColor.white
        cell.redTeamMatchScore.textColor = UIColor.black
    }
    func matchCellRedUp(_ cell: MatchTableViewCell) {
        cell.blueTeamView.layer.backgroundColor = UIColor.white.cgColor
        cell.redTeamView.layer.backgroundColor = UIColorFromRGB(0xB70A1C).cgColor
        
        cell.blueTeamPlayerOneLabel.textColor = UIColor.black
        cell.redTeamPlayerOneLabel.textColor = UIColor.white
        
        cell.blueTeamPlayerTwoLabel.textColor = UIColor.black
        cell.redTeamPlayerTwoLabel.textColor = UIColor.white
        
        cell.blueTeamSinglesLabel.textColor = UIColor.black
        cell.redTeamSinglesLabel.textColor = UIColor.white
        
        cell.blueTeamMatchScore.textColor = UIColor.black
        cell.redTeamMatchScore.textColor = UIColor.white
    }


}


