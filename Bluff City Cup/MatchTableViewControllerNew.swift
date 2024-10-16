//
//  MatchTableViewControllerNew.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 7/4/22.
//  Copyright © 2022 Jumpstop Creations. All rights reserved.
//


import UIKit

protocol MatchTableViewNewControllerDelegate {
    func updateScoreboard(_ newTournament: Tournament)
    func showScorecard(_ match: Match)
}

class MatchTableViewControllerNew: UITableViewController {
    
    var tournament: Tournament! = Tournament()
    var delegate: MatchTableViewNewControllerDelegate?
    var matchScorecardViewController: MatchScorecardViewController!
    
    @IBOutlet var matchTableView: UITableView!
    
    @objc func refreshData()
    {
        // Updating your data here...
        print("Refreshing")
        
        Model.sharedInstance.refresh { errorString in
            self.tournament = Model.sharedInstance.getTournament()
            
            DispatchQueue.main.async {
                //self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                print("Done Refreshing")
            
                self.delegate?.updateScoreboard(self.tournament)
                self.tableView.reloadData()
            }
        }
        
        User.sharedInstance.updateRole(tournamentName: tournament.getName()) {}
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tournament = Model.sharedInstance.getTournament()
        
        refreshControl = UIRefreshControl()
        
        self.matchTableView.backgroundColor = UIColorFromRGB(0xAAAAAA)
        self.refreshControl?.addTarget(self, action: #selector(MatchTableViewControllerNew.refreshData), for: UIControl.Event.valueChanged)
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
                //self.tableView.reloadData()
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
        
        let matchObject = Model.sharedInstance.getTournament().getMatchesSortedForTable()[(indexPath as NSIndexPath).row]
        

        if matchObject.getMatchLength() == 18 {
            
            let cellIdentifier = "MatchTableViewCell18"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchTableViewCell18
            
            cell.cleanupForReuse()
            
            
            
            cell.roundMatchLabel.text = "Round " + String(matchObject.getRound()) + ", Match " + String(matchObject.getMatchNumber())
            
                if matchObject.doubles() {
                    //Blue Player 1
                    cell.blueDoubleFirstName1.text = matchObject.blueTeamPlayerOne().name.components(separatedBy: " ")[0]
                    cell.blueDoubleLastName1.text = matchObject.blueTeamPlayerOne().name.components(separatedBy: " ")[1]
                    
                    //Blue Player 2
                    cell.blueDoubleFirstName2.text = matchObject.blueTeamPlayerTwo()!.name.components(separatedBy: " ")[0]
                    cell.blueDoubleLastName2.text = matchObject.blueTeamPlayerTwo()!.name.components(separatedBy: " ")[1]
                    
                    //Red Player 1
                    cell.redDoubleFirstName1.text = matchObject.redTeamPlayerOne().name.components(separatedBy: " ")[0]
                    cell.redDoubleLastName1.text = matchObject.redTeamPlayerOne().name.components(separatedBy: " ")[1]
                    
                    //Red Player 2
                    cell.redDoubleFirstName2.text = matchObject.redTeamPlayerTwo()!.name.components(separatedBy: " ")[0]
                    cell.redDoubleLastName2.text = matchObject.redTeamPlayerTwo()!.name.components(separatedBy: " ")[1]

                    
                    //Blue Singles
                    cell.blueSingleFirstName.text = ""
                    cell.blueSingleLastName.text = ""
                    cell.blueSingleFirstName.isHidden = true
                    cell.blueSingleLastName.isHidden = true
                    
                    //Red Singles
                    cell.redSingleFirstName.text = ""
                    cell.redSingleLastName.text = ""
                    cell.redSingleFirstName.isHidden = true
                    cell.redSingleLastName.isHidden = true
                    
                }
                else {
                    //SINGLES
                    
                    cell.redSingleFirstName.isHidden = false
                    cell.redSingleLastName.isHidden = false
                    cell.blueSingleFirstName.isHidden = false
                    cell.blueSingleLastName.isHidden = false
                                    
                    //Blue Player 1
                    cell.blueSingleFirstName.text = matchObject.blueTeamPlayerOne().name.components(separatedBy: " ")[0]
                    cell.blueSingleLastName.text = matchObject.blueTeamPlayerOne().name.components(separatedBy: " ")[1]
                    
                    //Red Player 1
                    cell.redSingleFirstName.text = matchObject.redTeamPlayerOne().name.components(separatedBy: " ")[0]
                    cell.redSingleLastName.text = matchObject.redTeamPlayerOne().name.components(separatedBy: " ")[1]
            
                    //Blue Doubles
                    cell.blueDoubleLastName1.text = ""
                    cell.blueDoubleLastName1.isHidden = false
                    cell.blueDoubleFirstName1.text = ""
                    cell.blueDoubleFirstName1.isHidden = false
                    cell.blueDoubleLastName2.text = ""
                    cell.blueDoubleLastName2.isHidden = false
                    cell.blueDoubleFirstName2.text = ""
                    cell.blueDoubleFirstName2.isHidden = false
                    
                    //Red Doubles
                    cell.redDoubleLastName1.text = ""
                    cell.redDoubleLastName1.isHidden = false
                    cell.redDoubleFirstName1.text = ""
                    cell.redDoubleFirstName1.isHidden = false
                    cell.redDoubleLastName2.text = ""
                    cell.redDoubleLastName2.isHidden = false
                    cell.redDoubleFirstName2.text = ""
                    cell.redDoubleFirstName2.isHidden = false

                }
            
            let matchStatus = matchObject.getMatchScoreSeparated(matchLength: matchObject.getMatchLength())
            
            if matchStatus.scoreString != "AS" && matchStatus.scoreString != "Halved" {
                cell.tiedLabel.isHidden = true
                cell.numLabel.text = matchStatus.scoreString
                cell.scoreLabel.text = String(matchStatus.secondaryString.filter {!" ".contains($0)})
                cell.scoreLabel.isHidden = false
                cell.numLabel.isHidden = false
            }
            else {
                cell.tiedLabel.isHidden = false
                cell.tiedLabel.text = matchStatus.scoreString
                cell.scoreLabel.isHidden = true
                cell.numLabel.isHidden = true
            }
            
            if matchObject.winningTeam() == "Blue" {
                matchCellBlueUp(cell)
            }
            else if matchObject.winningTeam() == "Red" {
                matchCellRedUp(cell)
            }
            else {
                matchCellAllSquared(cell)
            }
            
            
            
            
            let endingHole = matchObject.getEndingHole()
            
            
            //Set hole number
            if matchObject.getCurrentHole() >= endingHole && endingHole != 0 {
                cell.finalLabel.text = "Final"
                cell.finalLabel.isHidden = false
            }
            else if matchObject.getCurrentHole() == matchObject.getStartingHole() {
                cell.finalLabel.text = "Not Started"
                cell.finalLabel.isHidden = false
            }
            else {
                cell.finalLabel.text = ""
                cell.finalLabel.isHidden = true
            }
     
            var maxHole = 30
            if endingHole == 0 { maxHole = 30 }
            else { maxHole = endingHole }
            
            if matchObject.getMatchLength() == 18 {
                for hole in 1...min(max(matchObject.getCurrentHole()-1,1),maxHole) {
                    if matchObject.holeWinner(hole) == "Blue" {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0x0F296B))
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                    else if matchObject.holeWinner(hole) == "Red" {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xB70A1C))
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                    else {
                        cell.setHoleBackgroundColor(hole, color: UIColor.darkGray)
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                }
                if endingHole != 18 && matchObject.getCurrentHole() != 19 {
                    for hole in min(matchObject.getCurrentHole(),maxHole+1,18)...18 {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xDCDCDC))
                        cell.setHoleTextColor(hole, color: UIColor.black)
                    }
                }
                
            }
            /*else {
            //9 HOLE MATCHES

                for hole in 1...min((matchObject.getCurrentHole()-1),maxHole) {
                    if matchObject.holeWinner(hole) == "Blue" {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0x0F296B))
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                    else if matchObject.holeWinner(hole) == "Red" {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xB70A1C))
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                    else {
                        cell.setHoleBackgroundColor(hole, color: UIColor.darkGray)
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                }
                
                if matchObject.getCurrentHole() < 19 {
                    for hole in min(matchObject.getCurrentHole(),maxHole+1)...18 {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xDCDCDC))
                        cell.setHoleTextColor(hole, color: UIColor.black)
                    }
                }
            }*/
            
            if endingHole > 0 && endingHole < 18 {
                for hole in endingHole+1...18 {
                    cell.holeNotNeeded(hole)
                }
            }
            
            print("Done Cell \((indexPath as NSIndexPath).row)")
            cell.setNeedsDisplay()
            
            return cell
        }
        else {
            let cellIdentifier = "MatchTableViewCell9"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchTableViewCell9
            
            cell.cleanupForReuse()
            
            
            let matchObject = Model.sharedInstance.getTournament().getMatchesSortedForTable()[(indexPath as NSIndexPath).row]
            cell.roundMatchLabel.text = "Round " + String(matchObject.getRound()) + ", Match " + String(matchObject.getMatchNumber())
            
                if matchObject.doubles() {
                    //Blue Player 1
                    cell.blueDoubleFirstName1.text = matchObject.blueTeamPlayerOne().name.components(separatedBy: " ")[0]
                    cell.blueDoubleLastName1.text = matchObject.blueTeamPlayerOne().name.components(separatedBy: " ")[1]
                    
                    //Blue Player 2
                    cell.blueDoubleFirstName2.text = matchObject.blueTeamPlayerTwo()!.name.components(separatedBy: " ")[0]
                    cell.blueDoubleLastName2.text = matchObject.blueTeamPlayerTwo()!.name.components(separatedBy: " ")[1]
                    
                    //Red Player 1
                    cell.redDoubleFirstName1.text = matchObject.redTeamPlayerOne().name.components(separatedBy: " ")[0]
                    cell.redDoubleLastName1.text = matchObject.redTeamPlayerOne().name.components(separatedBy: " ")[1]
                    
                    //Red Player 2
                    cell.redDoubleFirstName2.text = matchObject.redTeamPlayerTwo()!.name.components(separatedBy: " ")[0]
                    cell.redDoubleLastName2.text = matchObject.redTeamPlayerTwo()!.name.components(separatedBy: " ")[1]

                    
                    //Blue Singles
                    cell.blueSingleFirstName.text = ""
                    cell.blueSingleLastName.text = ""
                    cell.blueSingleFirstName.isHidden = true
                    cell.blueSingleLastName.isHidden = true
                    
                    //Red Singles
                    cell.redSingleFirstName.text = ""
                    cell.redSingleLastName.text = ""
                    cell.redSingleFirstName.isHidden = true
                    cell.redSingleLastName.isHidden = true
                    
                }
                else {
                    //SINGLES
                    
                    cell.redSingleFirstName.isHidden = false
                    cell.redSingleLastName.isHidden = false
                    cell.blueSingleFirstName.isHidden = false
                    cell.blueSingleLastName.isHidden = false
                                    
                    //Blue Player 1
                    cell.blueSingleFirstName.text = matchObject.blueTeamPlayerOne().name.components(separatedBy: " ")[0]
                    cell.blueSingleLastName.text = matchObject.blueTeamPlayerOne().name.components(separatedBy: " ")[1]
                    
                    //Red Player 1
                    cell.redSingleFirstName.text = matchObject.redTeamPlayerOne().name.components(separatedBy: " ")[0]
                    cell.redSingleLastName.text = matchObject.redTeamPlayerOne().name.components(separatedBy: " ")[1]
            
                    //Blue Doubles
                    cell.blueDoubleLastName1.text = ""
                    cell.blueDoubleLastName1.isHidden = false
                    cell.blueDoubleFirstName1.text = ""
                    cell.blueDoubleFirstName1.isHidden = false
                    cell.blueDoubleLastName2.text = ""
                    cell.blueDoubleLastName2.isHidden = false
                    cell.blueDoubleFirstName2.text = ""
                    cell.blueDoubleFirstName2.isHidden = false
                    
                    //Red Doubles
                    cell.redDoubleLastName1.text = ""
                    cell.redDoubleLastName1.isHidden = false
                    cell.redDoubleFirstName1.text = ""
                    cell.redDoubleFirstName1.isHidden = false
                    cell.redDoubleLastName2.text = ""
                    cell.redDoubleLastName2.isHidden = false
                    cell.redDoubleFirstName2.text = ""
                    cell.redDoubleFirstName2.isHidden = false

                }
            
            let matchStatus = matchObject.getMatchScoreSeparated(matchLength: matchObject.getMatchLength())
            
            if matchStatus.scoreString != "AS" && matchStatus.scoreString != "Halved" {
                cell.tiedLabel.isHidden = true
                cell.numLabel.text = matchStatus.scoreString
                cell.scoreLabel.text = String(matchStatus.secondaryString.filter {!" ".contains($0)})
                cell.scoreLabel.isHidden = false
                cell.numLabel.isHidden = false
            }
            else {
                cell.tiedLabel.isHidden = false
                cell.tiedLabel.text = matchStatus.scoreString
                cell.scoreLabel.isHidden = true
                cell.numLabel.isHidden = true
            }
            
            if matchObject.winningTeam() == "Blue" {
                matchCellBlueUp(cell)
            }
            else if matchObject.winningTeam() == "Red" {
                matchCellRedUp(cell)
            }
            else {
                matchCellAllSquared(cell)
            }
            
            let endingHole = matchObject.getEndingHole()
            
            
            //Set hole number
            if matchObject.getCurrentHole() >= endingHole {
                cell.finalLabel.text = "Final"
                cell.finalLabel.isHidden = false
            }
            else if matchObject.getCurrentHole() == matchObject.getStartingHole() {
                cell.finalLabel.text = "Not Started"
                cell.finalLabel.isHidden = false
            }
            else {
                cell.finalLabel.text = ""
                cell.finalLabel.isHidden = true
            }
     
            var maxHole = 30
            if endingHole == 0 { maxHole = 30 }
            else { maxHole = endingHole }
            
            //9 HOLE MATCHES
                /*
                for hole in 1...min((matchObject.getCurrentHole()-1),maxHole) {
                    if matchObject.holeWinner(hole) == "Blue" {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0x0F296B))
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                    else if matchObject.holeWinner(hole) == "Red" {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xB70A1C))
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                    else {
                        cell.setHoleBackgroundColor(hole, color: UIColor.darkGray)
                        cell.setHoleTextColor(hole, color: UIColor.white)
                    }
                }
                
                if matchObject.getCurrentHole() < 10 {
                    for hole in min(matchObject.getCurrentHole(),maxHole+1)...9 {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xDCDCDC))
                        cell.setHoleTextColor(hole, color: UIColor.black)
                    }
                }
            
            if endingHole > 0 && endingHole < 9 {
                for hole in endingHole+1...9 {
                    cell.holeNotNeeded(hole)
                }
            }*/
            
            
            for hole in matchObject.getStartingHole()...min(max(matchObject.getCurrentHole()-1,1),maxHole) {
                if matchObject.holeWinner(hole) == "Blue" {
                    cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0x0F296B))
                    cell.setHoleTextColor(hole, color: UIColor.white)
                }
                else if matchObject.holeWinner(hole) == "Red" {
                    cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xB70A1C))
                    cell.setHoleTextColor(hole, color: UIColor.white)
                }
                else {
                    cell.setHoleBackgroundColor(hole, color: UIColor.darkGray)
                    cell.setHoleTextColor(hole, color: UIColor.white)
                }
            }
            
            if matchObject.getStartingHole() == 1 {
                if matchObject.getCurrentHole() < 10 {
                    for hole in min(matchObject.getCurrentHole(),maxHole+1)...9 {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xDCDCDC))
                        cell.setHoleTextColor(hole, color: UIColor.black)
                    }
                }
                
                if endingHole > 0 && endingHole < 9 {
                    for hole in endingHole+1...9 {
                        cell.holeNotNeeded(hole)
                    }
                }
                
                cell.hole1.text = "1"
                cell.hole2.text = "2"
                cell.hole3.text = "3"
                cell.hole4.text = "4"
                cell.hole5.text = "5"
                cell.hole6.text = "6"
                cell.hole7.text = "7"
                cell.hole8.text = "8"
                cell.hole9.text = "9"
            }
            else {
                if matchObject.getCurrentHole() < 19 {
                    for hole in min(matchObject.getCurrentHole(),maxHole+1)...18 {
                        cell.setHoleBackgroundColor(hole, color: UIColorFromRGB(0xDCDCDC))
                        cell.setHoleTextColor(hole, color: UIColor.black)
                    }
                }
                
                if endingHole > 0 && endingHole < 18 {
                    for hole in endingHole+1...18 {
                        cell.holeNotNeeded(hole)
                    }
                }
                
                cell.hole1.text = "10"
                cell.hole2.text = "11"
                cell.hole3.text = "12"
                cell.hole4.text = "13"
                cell.hole5.text = "14"
                cell.hole6.text = "15"
                cell.hole7.text = "16"
                cell.hole8.text = "17"
                cell.hole9.text = "18"
            }
            
        
        
            
            print("Done Cell \((indexPath as NSIndexPath).row)")
            cell.setNeedsDisplay()
            
            return cell
        }
        
        
    }
    
    


    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func matchCellAllSquared(_ cell: MatchTableViewCell18) {
        cell.blueTeamNames.layer.backgroundColor = UIColor.white.cgColor
        cell.redTeamNames.layer.backgroundColor = UIColor.white.cgColor
        
        cell.setBlueTriangle(color: UIColor.white)
        cell.setRedTriangle(color: UIColor.white)
        
        //Color blue names white
        cell.blueSingleFirstName.textColor = UIColor.black
        cell.blueSingleLastName.textColor = UIColor.black
        cell.blueDoubleFirstName1.textColor = UIColor.black
        cell.blueDoubleLastName1.textColor = UIColor.black
        cell.blueDoubleFirstName2.textColor = UIColor.black
        cell.blueDoubleLastName2.textColor = UIColor.black
        
        //Color red team names blue
        cell.redSingleFirstName.textColor = UIColor.black
        cell.redSingleLastName.textColor = UIColor.black
        cell.redDoubleFirstName1.textColor = UIColor.black
        cell.redDoubleLastName1.textColor = UIColor.black
        cell.redDoubleFirstName2.textColor = UIColor.black
        cell.redDoubleLastName2.textColor = UIColor.black
        
        //Score color
        cell.numLabel.textColor = UIColor.black
        cell.scoreLabel.textColor = UIColor.black
        cell.tiedLabel.textColor = UIColor.black
    }
    func matchCellBlueUp(_ cell: MatchTableViewCell18) {
        cell.blueTeamNames.layer.backgroundColor = UIColorFromRGB(0x0F296B).cgColor
        cell.redTeamNames.layer.backgroundColor = UIColor.white.cgColor
        
        cell.setBlueTriangle(color: UIColorFromRGB(0x0F296B))
        cell.setRedTriangle(color: UIColor.white)
        
        //Color blue names white
        cell.blueSingleFirstName.textColor = UIColor.white
        cell.blueSingleLastName.textColor = UIColor.white
        cell.blueDoubleFirstName1.textColor = UIColor.white
        cell.blueDoubleLastName1.textColor = UIColor.white
        cell.blueDoubleFirstName2.textColor = UIColor.white
        cell.blueDoubleLastName2.textColor = UIColor.white
        
        //Color red team names blue
        cell.redSingleFirstName.textColor = UIColor.black
        cell.redSingleLastName.textColor = UIColor.black
        cell.redDoubleFirstName1.textColor = UIColor.black
        cell.redDoubleLastName1.textColor = UIColor.black
        cell.redDoubleFirstName2.textColor = UIColor.black
        cell.redDoubleLastName2.textColor = UIColor.black
        
        //Score color
        cell.numLabel.textColor = UIColorFromRGB(0x0F296B)
        cell.scoreLabel.textColor = UIColorFromRGB(0x0F296B)
        cell.tiedLabel.textColor = UIColorFromRGB(0x0F296B)
    }
    func matchCellRedUp(_ cell: MatchTableViewCell18) {
        cell.blueTeamNames.layer.backgroundColor = UIColor.white.cgColor
        cell.redTeamNames.layer.backgroundColor = UIColorFromRGB(0xB70A1C).cgColor
        
        cell.setBlueTriangle(color: UIColor.white)
        cell.setRedTriangle(color: UIColorFromRGB(0xB70A1C))
        
        //Color blue names white
        cell.blueSingleFirstName.textColor = UIColor.black
        cell.blueSingleLastName.textColor = UIColor.black
        cell.blueDoubleFirstName1.textColor = UIColor.black
        cell.blueDoubleLastName1.textColor = UIColor.black
        cell.blueDoubleFirstName2.textColor = UIColor.black
        cell.blueDoubleLastName2.textColor = UIColor.black
        
        //Color red team names blue
        cell.redSingleFirstName.textColor = UIColor.white
        cell.redSingleLastName.textColor = UIColor.white
        cell.redDoubleFirstName1.textColor = UIColor.white
        cell.redDoubleLastName1.textColor = UIColor.white
        cell.redDoubleFirstName2.textColor = UIColor.white
        cell.redDoubleLastName2.textColor = UIColor.white
        
        //Score color
        cell.numLabel.textColor = UIColorFromRGB(0xB70A1C)
        cell.scoreLabel.textColor = UIColorFromRGB(0xB70A1C)
        cell.tiedLabel.textColor = UIColorFromRGB(0xB70A1C)
    }

    
    func matchCellAllSquared(_ cell: MatchTableViewCell9) {
        cell.blueTeamNames.layer.backgroundColor = UIColor.white.cgColor
        cell.redTeamNames.layer.backgroundColor = UIColor.white.cgColor
        
        cell.setBlueTriangle(color: UIColor.white)
        cell.setRedTriangle(color: UIColor.white)
        
        //Color blue names white
        cell.blueSingleFirstName.textColor = UIColor.black
        cell.blueSingleLastName.textColor = UIColor.black
        cell.blueDoubleFirstName1.textColor = UIColor.black
        cell.blueDoubleLastName1.textColor = UIColor.black
        cell.blueDoubleFirstName2.textColor = UIColor.black
        cell.blueDoubleLastName2.textColor = UIColor.black
        
        //Color red team names blue
        cell.redSingleFirstName.textColor = UIColor.black
        cell.redSingleLastName.textColor = UIColor.black
        cell.redDoubleFirstName1.textColor = UIColor.black
        cell.redDoubleLastName1.textColor = UIColor.black
        cell.redDoubleFirstName2.textColor = UIColor.black
        cell.redDoubleLastName2.textColor = UIColor.black
        
        //Score color
        cell.numLabel.textColor = UIColor.black
        cell.scoreLabel.textColor = UIColor.black
        cell.tiedLabel.textColor = UIColor.black
    }
    func matchCellBlueUp(_ cell: MatchTableViewCell9) {
        cell.blueTeamNames.layer.backgroundColor = UIColorFromRGB(0x0F296B).cgColor
        cell.redTeamNames.layer.backgroundColor = UIColor.white.cgColor
        
        cell.setBlueTriangle(color: UIColorFromRGB(0x0F296B))
        cell.setRedTriangle(color: UIColor.white)
        
        //Color blue names white
        cell.blueSingleFirstName.textColor = UIColor.white
        cell.blueSingleLastName.textColor = UIColor.white
        cell.blueDoubleFirstName1.textColor = UIColor.white
        cell.blueDoubleLastName1.textColor = UIColor.white
        cell.blueDoubleFirstName2.textColor = UIColor.white
        cell.blueDoubleLastName2.textColor = UIColor.white
        
        //Color red team names blue
        cell.redSingleFirstName.textColor = UIColor.black
        cell.redSingleLastName.textColor = UIColor.black
        cell.redDoubleFirstName1.textColor = UIColor.black
        cell.redDoubleLastName1.textColor = UIColor.black
        cell.redDoubleFirstName2.textColor = UIColor.black
        cell.redDoubleLastName2.textColor = UIColor.black
        
        //Score color
        cell.numLabel.textColor = UIColorFromRGB(0x0F296B)
        cell.scoreLabel.textColor = UIColorFromRGB(0x0F296B)
        cell.tiedLabel.textColor = UIColorFromRGB(0x0F296B)
    }
    func matchCellRedUp(_ cell: MatchTableViewCell9) {
        cell.blueTeamNames.layer.backgroundColor = UIColor.white.cgColor
        cell.redTeamNames.layer.backgroundColor = UIColorFromRGB(0xB70A1C).cgColor
        
        cell.setBlueTriangle(color: UIColor.white)
        cell.setRedTriangle(color: UIColorFromRGB(0xB70A1C))
        
        //Color blue names white
        cell.blueSingleFirstName.textColor = UIColor.black
        cell.blueSingleLastName.textColor = UIColor.black
        cell.blueDoubleFirstName1.textColor = UIColor.black
        cell.blueDoubleLastName1.textColor = UIColor.black
        cell.blueDoubleFirstName2.textColor = UIColor.black
        cell.blueDoubleLastName2.textColor = UIColor.black
        
        //Color red team names blue
        cell.redSingleFirstName.textColor = UIColor.white
        cell.redSingleLastName.textColor = UIColor.white
        cell.redDoubleFirstName1.textColor = UIColor.white
        cell.redDoubleLastName1.textColor = UIColor.white
        cell.redDoubleFirstName2.textColor = UIColor.white
        cell.redDoubleLastName2.textColor = UIColor.white
        
        //Score color
        cell.numLabel.textColor = UIColorFromRGB(0xB70A1C)
        cell.scoreLabel.textColor = UIColorFromRGB(0xB70A1C)
        cell.tiedLabel.textColor = UIColorFromRGB(0xB70A1C)
    }

}


