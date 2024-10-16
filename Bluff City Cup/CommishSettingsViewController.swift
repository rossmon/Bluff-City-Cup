//
//  TestTableViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 3/11/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

protocol CommishSettingsViewControllerDelegate {
    
    func toggleTopPanelCommishSettings()
    func collapseTopPanelCommishSettings()
    func changeViewCommishSettings(_ menu: String)
    
}

class CommishSettingsViewController: UITableViewController {
    
    
    var delegate: CommishSettingsViewControllerDelegate?
    var user = User.sharedInstance
    var tournament: Tournament!
    var model = Model.sharedInstance
    @IBOutlet weak var navBar: UINavigationItem!
    var selectedCell: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        selectedCell = ""
        self.navBar.backBarButtonItem?.title = "Back"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        }
        else if section == 1 {
            return 2
        }
        else if section == 2 {
            return 2
        }
        else if section == 3 {
            return 1
        }
        else if section == 4 {
            return 1
        }
        else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if (indexPath as NSIndexPath).section == 0 {
            /*if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "matchLengthCell", for: indexPath) as! MatchLengthCell
                cell.settingLabel.text = "Match Length"
                //tournament.getMatchLength()
                /*if .getMatchLength() == 9 {
                    cell.matchLengthSelector.selectedSegmentIndex = 0
                }
                else {
                    cell.matchLengthSelector.selectedSegmentIndex = 1
                }*/
                
                cell.tournament = self.tournament
            }
            else*/ if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "numberOfRoundsCell", for: indexPath) as! NumberOfRoundsCell
                cell.settingLabel.text = "Number of Rounds"
                cell.numberOfRoundsSelector.selectedSegmentIndex = tournament.getNumberOfRounds() - 1
                cell.tournament = self.tournament
            }
            else if (indexPath as NSIndexPath).row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "maxHandicapCell", for: indexPath) as! MaxHandicapCell
                cell.settingLabel.text = "Max Handicap"
                cell.tournament = self.tournament
                cell.maxHandicapField.text = String(self.tournament.getMaxHandicap())
            }
            else if (indexPath as NSIndexPath).row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commishPasswordCell", for: indexPath) as! CommishPasswordCell
                cell.settingLabel.text = "Commissioner Password"
                cell.tournament = self.tournament
                cell.commishPasswordField.text = String(self.tournament.getCommissionerPassword())
            }
        }
        else if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCartOnCell", for: indexPath) as! DrinkCartOnCell
                cell.settingLabel.text = "Drink Cart"
                cell.drinkCartSwitch.isOn = tournament.isDrinkCartAvailable()
                cell.tournament = self.tournament
            }
            else if (indexPath as NSIndexPath).row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCartNumberCell", for: indexPath) as! DrinkCartNumberCell
                cell.settingLabel.text = "Drink Cart Number"
                cell.tournament = self.tournament
                cell.drinkCartNumber.text = self.tournament.getDrinkCartNumber()
            }
        }
        else if (indexPath as NSIndexPath).section == 2 {
            if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commishSettingsCell", for: indexPath) as! CommishSettingsCell
                cell.settingLabel.text = "Players"
                cell.settingStatus.text = ""
                
            }
            else if (indexPath as NSIndexPath).row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commishSettingsCell", for: indexPath) as! CommishSettingsCell
                cell.settingLabel.text = "Matches"
                cell.settingStatus.text = ""
            }
            else if (indexPath as NSIndexPath).row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commishSettingsCell", for: indexPath) as! CommishSettingsCell
                cell.settingLabel.text = "Courses for Rounds"
                cell.settingStatus.text = ""
            }
        }
        else if (indexPath as NSIndexPath).section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCourseCell", for: indexPath) as! AddCourseCell
            cell.settingLabel.text = "Add Course"
        }
        else if (indexPath as NSIndexPath).section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteMatchesCell", for: indexPath) as! DeleteMatchesCell
            cell.settingLabel.text = "Delete All Matches"
        }
        
        return cell
        
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let path = self.tableView.indexPathForSelectedRow
        tableView.deselectRow(at: path!, animated: true)
        self.tableView.reloadData()
        
        if (path! as NSIndexPath).section == 0 {
            /*
             if (path! as NSIndexPath).row == 0 {
             self.selectedCell = "Match Length"
             }
             else if (path! as NSIndexPath).row == 1 {
             self.selectedCell = "Number of Matches"
             }
             else if (path! as NSIndexPath).row == 2 {
             self.selectedCell = "Drink Cart"
             }
             */
        }
        else if (path! as NSIndexPath).section == 1 {
            
        }
        else if (path! as NSIndexPath).section == 2 {
            if (path! as NSIndexPath).row == 0 {
                self.selectedCell = "Edit Players"
            }
            else if (path! as NSIndexPath).row == 1 {
                self.selectedCell = "Edit Matches"
            }
            else if (path! as NSIndexPath).row == 2 {
                self.selectedCell = "Edit Rounds"
            }
        }
        
        if let destViewController = segue.destination as? CommishDetailViewController {
            
            destViewController.tournament = self.tournament
            destViewController.settingSelected = selectedCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("Selected section: \(indexPath.section)")
        if indexPath.section == 3 {
            print("Selected Add Course")
            self.performSegue(withIdentifier: "addCourseSegue", sender: self)
        }
        else if indexPath.section == 4 {
            print("Selected Delete All Matches")
            verifyMatchDeletion()
            tableView.reloadData()
        }
        else {
            self.performSegue(withIdentifier: "listSegue", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath
    {
        if (indexPath.section == 2) || (indexPath.section == 3) || (indexPath.section == 4){
            return indexPath
        }
        return IndexPath()
    }
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if (indexPath.section == 2) || (indexPath.section == 3) {
            return true
        }
        else if indexPath.section == 4 {
            self.tableView(self.tableView, didSelectRowAt: indexPath)
        }
        return false
    }
    
    
    @IBAction func saveToCommishSettings(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CommishDetailViewController, let tournamentNew = sourceViewController.tournament {
            self.tournament = tournamentNew
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        User.sharedInstance.updateScorekeeperFromTournament(tournament)
        self.delegate?.changeViewCommishSettings("Scoreboard")
    }
    
    func verifyMatchDeletion() {
        let deleteMatchAlert = UIAlertController(title: "Verify", message: "Are you sure you want to delete all matches and round scores for this tournament?", preferredStyle: UIAlertController.Style.alert)
        
        deleteMatchAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Wants to delete all matches")
            
            self.model.deleteAllMatches(tournamentName: self.tournament.getName())
            self.tournament.deleteMatches()
            self.user.updateRole(tournamentName: self.tournament.getName()) { }
        }))
        deleteMatchAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Doesn't want to delete matches.")
        }))
        
        present(deleteMatchAlert, animated: true, completion: nil)
    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData() // to reload selected cell
    }
    
}

extension CommishSettingsViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        //Logic to change views?
        
        delegate?.collapseTopPanelCommishSettings()
        delegate?.changeViewCommishSettings(menu)
        
    }
}
