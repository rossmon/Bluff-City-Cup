
//  CommishDetailViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 4/25/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class CommishDetailViewController: UITableViewController {

    var tournament: Tournament!
    fileprivate var tournamentUpdated: Tournament!
    var settingSelected: String!
    var path: IndexPath?
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.title = settingSelected
        self.navBar.backBarButtonItem?.title = "Back"
        self.tableView.delegate = self

        tournamentUpdated = tournament
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBOutlet weak var navBar: UINavigationItem!
 
    @IBAction func addButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "addElement", sender: self)
        
    }
    
    // MARK: - Navigation
  
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addElement" {
            if self.settingSelected == "Edit Players" {
                if let destViewController = segue.destination as? AddPlayerOrMatchView {
                    destViewController.editType = "Player"
                    destViewController.tournament = tournament
                    destViewController.delegate = self
                }
            }
            else if self.settingSelected == "Edit Matches" {
                if let destViewController = segue.destination as? AddPlayerOrMatchView {
                    destViewController.editType = "Match"
                    destViewController.tournament = tournament
                    destViewController.delegate = self
                }
            }
        }
        else {
            let indexPath = self.tableView.indexPathForSelectedRow
            //tableView.deselectRow(at: indexPath!, animated: true)
            //self.tableView.reloadData()
            
                if self.settingSelected == "Edit Players" {
                    if let destViewController = segue.destination as? AddPlayerOrMatchView {
                        destViewController.editType = "EditPlayer"
                        let player = self.tournament.sortPlayersByTeamAndHandicap()[(indexPath! as NSIndexPath).row]
                        destViewController.player = player
                        destViewController.tournament = tournament
                        destViewController.delegate = self
                    }
                }
                else if self.settingSelected == "Edit Matches" {
                    if let destViewController = segue.destination as? AddPlayerOrMatchView {
                        destViewController.editType = "EditMatch"
                        let match = self.tournament.getMatchesSorted()[(indexPath! as NSIndexPath).row]
                        destViewController.match = match
                        destViewController.tournament = tournament
                        destViewController.delegate = self
                    }
                }
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if settingSelected == "Edit Players" {
            return tournament.getPlayers().count
        }
        else if settingSelected == "Edit Matches" {
            return tournament.getMatches().count
        }
        else if settingSelected == "Edit Rounds" {
            return tournament.getCourseRounds().count
        }
        else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell()
        
        if settingSelected == "Edit Players" {
            let cellIdentifier = "PlayerCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlayerViewCell
            let player = self.tournament.sortPlayersByTeamAndHandicap()[(indexPath as NSIndexPath).row]
            
            cell.playerName.text = player.getName()
            cell.playerHandicap.text = String(player.getHandicap())
            
            if player.getTeam() == "Blue" {
                cell.backgroundColor = UIColorFromRGB(0x0F296B)
            }
            else if player.getTeam() == "Red" {
                cell.backgroundColor = UIColorFromRGB(0xB70A1C)
            }
            return cell
        }
        else if settingSelected == "Edit Matches" {
            let cellIdentifier = "MatchCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchViewCell
            
            let match = self.tournament.getMatchesSorted()[(indexPath as NSIndexPath).row]
            
            if match.getFormat() == "Singles" {
                cell.playersName.text = "\(match.blueTeamPlayerOne().getLastName()) vs. \(match.redTeamPlayerOne().getLastName())"
            }
            else if (match.getFormat() == "Best Ball" || match.getFormat() == "Alternate Shot" || match.getFormat() == "Two Man Scramble" || match.getFormat() == "Shamble") {
                cell.playersName.text = "\(match.blueTeamPlayerOne().getLastName())/\(match.blueTeamPlayerTwo()!.getLastName()) vs. \(match.redTeamPlayerOne().getLastName())/\(match.redTeamPlayerTwo()!.getLastName())"
            }
            
            cell.roundMatchGroup.text = "R\(match.getRound())M\(match.getMatchNumber())G\(match.getGroup())"
            
            return cell
        }
        let cell = UITableViewCell()
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            if settingSelected == "Edit Players" {
                let player = self.tournament.sortPlayersByTeamAndHandicap()[(indexPath as NSIndexPath).row]
                
                if !tournament.deletePlayer(player) {
                    playerRemovalAlert()
                }
                else {
                    Model.sharedInstance.deletePlayer(player)
                }

                self.tableView.reloadData()
            }
            else if settingSelected == "Edit Matches" {
                let match = self.tournament.getMatchesSorted()[(indexPath as NSIndexPath).row]
                
                if !tournament.deleteMatch(match) {
                    matchRemovalAlert()
                }
                else {
                    Model.sharedInstance.deleteMatch(match)
                }
                
                self.tableView.reloadData()
            }

            
        }
    }
    
    func playerRemovalAlert() {
        let alert = UIAlertController(title: "Oops!", message: "This player is already in a match. Please delete the match first.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func matchRemovalAlert() {
        let alert = UIAlertController(title: "Oops!", message: "This match has already started. It cannot be deleted.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
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

extension CommishDetailViewController: AddPlayerOrMatchViewDelegate {
    func updateTournament(_ tournament: Tournament) {
        self.tournament = tournament
    }
    
    func reload() {
        self.tableView.reloadData()
    }
}



