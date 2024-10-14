//
//  AddPlayerOrMatchView.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/6/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
//
//  AddPlayerView.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 12/5/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

protocol AddPlayerOrMatchViewDelegate {
    func updateTournament(_ tournament: Tournament)
    func reload()
}


class AddPlayerOrMatchView: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    var delegate: AddPlayerOrMatchViewDelegate?
    
    @IBOutlet weak var playerTeamLabel: UILabel!
    @IBOutlet weak var playerHandicapLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerNameField: UITextField!
    @IBOutlet weak var playerHandicap: UITextField!
    @IBOutlet weak var teamSelector: UISegmentedControl!
    @IBOutlet weak var courseField: UITextField!
    @IBOutlet weak var teesField: UITextField!
    
    
    @IBOutlet weak var roundNumberLabel: UILabel!
    @IBOutlet weak var matchNumberLabel: UILabel!
    @IBOutlet weak var groupNumberLabel: UILabel!
    @IBOutlet weak var matchFormatLabel: UILabel!
    @IBOutlet weak var matchCourseLabel: UILabel!
    @IBOutlet weak var scorekeeperLabel: UILabel!
    @IBOutlet weak var startingHoleLabel: UILabel!
    @IBOutlet weak var courseTeesLabel: UILabel!
    
    @IBOutlet weak var roundField: UITextField!
    @IBOutlet weak var matchField: UITextField!
    @IBOutlet weak var groupField: UITextField!
    @IBOutlet weak var formatSelector: UITextField!
    @IBOutlet weak var startingHoleSegment: UISegmentedControl!
    @IBOutlet weak var scorekeeperField: UITextField!
    
    @IBOutlet weak var bluePlayer1Label: UILabel!
    
    @IBOutlet weak var redPlayer1Label: UILabel!
    @IBOutlet weak var bluePlayer2Label: UILabel!
    @IBOutlet weak var redPlayer2Label: UILabel!
    
    @IBOutlet weak var bluePlayer1Field: UITextField!
    @IBOutlet weak var redPlayer1Field: UITextField!
    @IBOutlet weak var bluePlayer2Field: UITextField!
    @IBOutlet weak var redPlayer2Field: UITextField!
    
    
    @IBOutlet weak var navBar: UINavigationItem!
    var player: Player!
    var match: Match!
    var editType: String!
    var tournament: Tournament!
    
    var pickerElements: [String]!
    var fieldSelected: String!
    
    var model = Model.sharedInstance
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.roundField.delegate = self
        self.matchField.delegate = self
        self.groupField.delegate = self
        
        self.bluePlayer1Field.delegate = self
        self.bluePlayer2Field.delegate = self
        self.redPlayer1Field.delegate = self
        self.redPlayer2Field.delegate = self
        self.formatSelector.delegate = self
        self.scorekeeperField.delegate = self
        self.courseField.delegate = self
        self.teesField.delegate = self
        
        self.pickerView.delegate = self
        self.pickerView.isHidden = true
        self.pickerElements = [""]
        
        
        if editType == "Player" || editType == "EditPlayer" {
            self.navBar.title = "Add Player"
            self.roundNumberLabel.isHidden = true
            self.matchNumberLabel.isHidden = true
            self.groupNumberLabel.isHidden = true
            self.matchFormatLabel.isHidden = true
            self.matchCourseLabel.isHidden = true
            self.courseTeesLabel.isHidden = true
            self.scorekeeperLabel.isHidden = true
            self.startingHoleLabel.isHidden = true
            self.roundField.isHidden = true
            self.matchField.isHidden = true
            self.groupField.isHidden = true
            self.startingHoleSegment.isHidden = true
            self.formatSelector.isHidden = true
            self.courseField.isHidden = true
            self.teesField.isHidden = true
            self.scorekeeperField.isHidden = true
            
            
            self.bluePlayer1Label.isHidden = true
            self.bluePlayer1Field.isHidden = true
            self.bluePlayer2Label.isHidden = true
            self.bluePlayer2Field.isHidden = true
            self.redPlayer1Label.isHidden = true
            self.redPlayer1Field.isHidden = true
            self.redPlayer2Label.isHidden = true
            self.redPlayer2Field.isHidden = true
            
        }
        else if editType == "Match" || editType == "EditMatch"{
            self.navBar.title = "Add Match"
            self.playerTeamLabel.isHidden = true
            self.playerHandicapLabel.isHidden = true
            self.playerNameLabel.isHidden = true
            self.playerNameField.isHidden = true
            self.playerHandicap.isHidden = true
            self.teamSelector.isHidden = true
        }
        
        if editType == "EditPlayer" {
            self.playerNameField.isUserInteractionEnabled = false
            self.playerNameField.text = player.getName()
            self.playerHandicap.text = String(player.getHandicap())
            if player.getTeam() == "Blue" {
                self.teamSelector.selectedSegmentIndex = 0
            }
            else {
                self.teamSelector.selectedSegmentIndex = 1
            }
            
        }
        else if editType == "EditMatch" {
            self.formatSelector.text = self.match.getFormat()
            self.bluePlayer1Field.text = self.match.blueTeamPlayerOne().getName()
            self.redPlayer1Field.text = self.match.redTeamPlayerOne().getName()
            if self.formatSelector.text != "Singles" {
                self.bluePlayer2Field.text = self.match.blueTeamPlayerTwo()?.getName()
                self.redPlayer2Field.text = self.match.redTeamPlayerTwo()?.getName()
            }
            else {
                self.bluePlayer2Field.isHidden = true
                self.redPlayer2Field.isHidden = true
                self.bluePlayer2Label.isHidden = true
                self.redPlayer2Label.isHidden = true
            }
            self.roundField.text = String(match.getRound())
            self.matchField.text = String(match.getMatchNumber())
            self.groupField.text = String(match.getGroup())
            if match.getStartingHole() == 1 {
                self.startingHoleSegment.selectedSegmentIndex = 0
            }
            else {
                self.startingHoleSegment.selectedSegmentIndex = 1
            }
            self.courseField.text = String(match.getCourseName())
            self.teesField.text = String(match.getTees())
            self.scorekeeperField.text = match.getScorekeeperName()

        }
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if editType == "Player" {
            if self.playerNameField.text != "" && self.playerHandicap.text != "" {
                var playerNames = [String]()
                if self.teamSelector.selectedSegmentIndex == 0 {
                    let team = "Blue"
                    playerNames = tournament.getBluePlayerNames()
                    if playerNames.contains(playerNameField.text!) {
                        playerAlreadyExists()
                    }
                    else {
                        let addedPlayer = Player(name: playerNameField.text!, handicap: Int(playerHandicap.text!)!, team: team)
                        model.addPlayerRecord(player: addedPlayer, tournamentName: tournament.getName()) { () in
                            DispatchQueue.main.async {
                                //addedPlayer.setRecord(record: record)
                                self.tournament.appendPlayer(player: addedPlayer)
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
                else {
                    let team = "Red"
                    playerNames = tournament.getRedPlayerNames()
                    if playerNames.contains(playerNameField.text!) {
                        playerAlreadyExists()
                    }
                    else {
                        let addedPlayer = Player(name: playerNameField.text!, handicap: Int(playerHandicap.text!)!, team: team)
                        model.addPlayerRecord(player: addedPlayer, tournamentName: tournament.getName()) { () in
                            DispatchQueue.main.async {
                                //addedPlayer.setRecord(record: record)
                                self.tournament.appendPlayer(player: addedPlayer)
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
            else {
                playerNameError()
            }
        }
        else if editType == "Match" {
            var matchPlayers = [Player]()
            if self.roundField.text != "" && self.matchField.text != "" && self.groupField.text != "" && self.formatSelector.text != "" && self.courseField.text != "" && self.teesField.text != "" && self.scorekeeperField.text != "" {
                if self.formatSelector.text == "Singles" {
                    if self.bluePlayer1Field.text != "" && self.redPlayer1Field.text != "" {
                        if tournament.playerAlreadyInMatchInRound(playerName: self.bluePlayer1Field.text!, round: Int(self.roundField.text!)!) || tournament.playerAlreadyInMatchInRound(playerName: self.redPlayer1Field.text!, round: Int(self.roundField.text!)!) {
                            playerAlreadyHasMatchInRound()
                        }
                        else {
                            matchPlayers.append(tournament.getPlayerWithName(self.bluePlayer1Field.text!)!)
                            matchPlayers.append(tournament.getPlayerWithName(self.redPlayer1Field.text!)!)
                            
                            let startingHole = Int(self.startingHoleSegment.titleForSegment(at: self.startingHoleSegment.selectedSegmentIndex)!)!
                            
                            let addedMatch = Match(format: self.formatSelector.text!, players: matchPlayers, scorekeeper: self.scorekeeperField.text!, score: 0,teamWinning: "AS", hole: startingHole, course: self.courseField.text!, tees: self.teesField.text!,round: Int(self.roundField.text!)!, group: Int(self.groupField.text!)!, startingHole: startingHole, matchNumber: Int(self.matchField.text!)!)
                            
                            addedMatch.setScorekeeperName(self.scorekeeperField.text!)
                            
                            model.addMatchRecord(match: addedMatch, tournamentName: tournament.getName()) { () in
                                DispatchQueue.main.async {
                                    //addedMatch.setRecord(record: record)
                                    self.tournament.appendMatch(match: addedMatch)
                                    _ = self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                    else {
                        matchAddError()
                    }
                }
                else {
                    if self.bluePlayer1Field.text != "" && self.redPlayer1Field.text != "" && self.bluePlayer2Field.text != "" && self.redPlayer2Field.text != "" {
                        if tournament.playerAlreadyInMatchInRound(playerName: self.bluePlayer1Field.text!, round: Int(self.roundField.text!)!) || tournament.playerAlreadyInMatchInRound(playerName: self.redPlayer1Field.text!, round: Int(self.roundField.text!)!) || tournament.playerAlreadyInMatchInRound(playerName: self.bluePlayer2Field.text!, round: Int(self.roundField.text!)!) || tournament.playerAlreadyInMatchInRound(playerName: self.redPlayer2Field.text!, round: Int(self.roundField.text!)!){
                            
                            playerAlreadyHasMatchInRound()
                        }
                        else {
                            matchPlayers.append(tournament.getPlayerWithName(self.bluePlayer1Field.text!)!)
                            matchPlayers.append(tournament.getPlayerWithName(self.redPlayer1Field.text!)!)
                            matchPlayers.append(tournament.getPlayerWithName(self.bluePlayer2Field.text!)!)
                            matchPlayers.append(tournament.getPlayerWithName(self.redPlayer2Field.text!)!)
                            
                            let startingHole = Int(self.startingHoleSegment.titleForSegment(at: self.startingHoleSegment.selectedSegmentIndex)!)!
                            
                            let addedMatch = Match(format: self.formatSelector.text!, players: matchPlayers, score: 0, teamWinning: "AS", hole: startingHole, course: self.courseField.text!, tees: self.teesField.text!, round: Int(self.roundField.text!)!, group: Int(self.groupField.text!)!, startingHole: startingHole, matchNumber: Int(self.matchField.text!)!)
                                
                            addedMatch.setScorekeeperName(self.scorekeeperField.text!)
                                
                            model.addMatchRecord(match: addedMatch, tournamentName: tournament.getName()) { () in
                                DispatchQueue.main.async {
                                    //addedMatch.setRecord(record: record)
                                    self.tournament.appendMatch(match: addedMatch)
                                    _ = self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                    else {
                        matchAddError()
                    }
                }
            }
            else {
                matchAddError()
            }
        }
        else if editType == "EditPlayer" {
            if self.playerNameField.text == "" || self.playerHandicap.text == "" {
                noPlayerNameOrHandicap()
            }
            else {
                if let editPlayer = tournament.getPlayerWithName(self.playerNameField.text!) {
                    editPlayer.setHandicap(Int(self.playerHandicap.text!)!)
                    if self.teamSelector.selectedSegmentIndex == 0 {
                        editPlayer.setTeam("Blue")
                    }
                    else {
                        editPlayer.setTeam("Red")
                    }
                    Model.sharedInstance.updatePlayer(editPlayer) {() in
                        DispatchQueue.main.async {
                            self.delegate?.updateTournament(self.tournament)
                            self.delegate?.reload()
                            
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        else if editType == "EditMatch" {
            
            if (self.tournament.getMatchLength() == 9 && (self.match.getCurrentHole() != 1 && self.match.getCurrentHole() != 10)) || (self.tournament.getMatchLength() == 18 && self.match.getCurrentHole() > 1) {

                matchInProgressError()
            }
            else {
                if self.roundField.text == "" || self.matchField.text == "" || self.groupField.text == "" || self.formatSelector.text == "" || self.courseField.text == "" || self.teesField.text == "" || self.scorekeeperField.text == "" || self.bluePlayer1Field.text == "" || self.redPlayer1Field.text == "" {
                    matchAddError()
                }
                else {
                    if let editMatch = self.match {
                        
                        var matchPlayers = [Player]()
                        matchPlayers.append(tournament.getPlayerWithName(self.bluePlayer1Field.text!)!)
                        
                        if self.bluePlayer2Field.text != "" {
                            matchPlayers.append(tournament.getPlayerWithName(self.bluePlayer2Field.text!)!)
                        }
                        
                        matchPlayers.append(tournament.getPlayerWithName(self.redPlayer1Field.text!)!)
                        if self.redPlayer2Field.text != "" {
                            matchPlayers.append(tournament.getPlayerWithName(self.redPlayer2Field.text!)!)
                        }
                        
                        editMatch.setPlayers(matchPlayers)
                        
                        editMatch.setFormat(self.formatSelector.text!)
                        editMatch.setRound(Int(self.roundField.text!)!)
                        editMatch.setMatchNumber(Int(self.matchField.text!)!)
                        editMatch.setGroupNumber(Int(self.groupField.text!)!)
                        editMatch.setScorekeeperName(self.scorekeeperField.text!)
                        editMatch.setStartingHole(Int(self.startingHoleSegment.titleForSegment(at: self.startingHoleSegment.selectedSegmentIndex)!)!)
                        
                        
                        Model.sharedInstance.updateMatch(editMatch) {() in
                            DispatchQueue.main.async {
                                self.delegate?.updateTournament(self.tournament)
                                self.delegate?.reload()
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func formatTouched(_ sender: UITextField) {
        self.view.endEditing(true)
        self.fieldSelected = "Format"
        self.pickerView.isHidden = false
        self.pickerElements = ["Alternate Shot", "Best Ball", "Singles", "Two Man Scramble"]
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func courseTouched(_ sender: UITextField) {
        self.view.endEditing(true)
        self.fieldSelected = "Course"
        self.pickerView.isHidden = false
        self.pickerElements = tournament.getCourseNames()
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func courseTeesTouched(_ sender: UITextField) {
        
        if let course = self.courseField.text {
            self.view.endEditing(true)
            self.fieldSelected = "Tees"
            self.pickerView.isHidden = false
            self.pickerElements = tournament.getTeesForCourse(course)
            self.pickerView.reloadAllComponents()
        }
        else {
            noRoundCourseError()
        }
    }
    
    @IBAction func blueP1Touched(_ sender: UITextField) {
        self.view.endEditing(true)
        self.fieldSelected = "BP1"
        self.pickerView.isHidden = false
        self.pickerElements = tournament.getBluePlayerNames()
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func redP1Touched(_ sender: UITextField) {
        self.view.endEditing(true)
        self.fieldSelected = "RP1"
        self.pickerView.isHidden = false
        self.pickerElements = tournament.getRedPlayerNames()
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func blueP2Touched(_ sender: UITextField) {
        self.view.endEditing(true)
        self.fieldSelected = "BP2"
        self.pickerView.isHidden = false
        self.pickerElements = tournament.getBluePlayerNames()
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func redP2Touched(_ sender: UITextField) {
        self.view.endEditing(true)
        self.fieldSelected = "RP2"
        self.pickerView.isHidden = false
        self.pickerElements = tournament.getRedPlayerNames()
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func scorekeeperPressed(_ sender: UITextField) {
        self.view.endEditing(true)
        self.fieldSelected = "Scorekeeper"
        if self.bluePlayer1Field.text != "" || self.bluePlayer2Field.text != "" || self.redPlayer1Field.text != "" || self.redPlayer2Field.text != "" {
            self.pickerView.isHidden = false
            
            var playerNames = [String]()
            
            let players = tournament.getPlayers()
            for eachPlayer in players {
                playerNames.append(eachPlayer.getName())
            }
            /*
            
            if self.bluePlayer1Field.text != "" {
                playerNames.append(self.bluePlayer1Field.text!)
            }
            if self.bluePlayer2Field.text != "" {
                playerNames.append(self.bluePlayer2Field.text!)
            }
            if self.redPlayer1Field.text != "" {
                playerNames.append(self.redPlayer1Field.text!)
            }
            if self.redPlayer2Field.text != "" {
                playerNames.append(self.redPlayer2Field.text!)
            }
            */
            
            self.pickerElements = playerNames
            self.pickerView.reloadAllComponents()
        }
        else {
            self.pickerView.isHidden = true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()  //if desired
        
        self.view.endEditing(true)
        
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.bluePlayer1Field || textField == self.bluePlayer2Field || textField == self.redPlayer1Field || textField == self.redPlayer2Field || textField == self.courseField || textField == self.teesField || textField == self.formatSelector || textField == self.scorekeeperField {
            pickerView.isHidden = false
            return false
        }
        
        return true
        
    }
    
    private func textFieldDidBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.bluePlayer1Field || textField == self.bluePlayer2Field || textField == self.redPlayer1Field || textField == self.redPlayer2Field || textField == self.matchField {
            pickerView.isHidden = false
            return false
        }
        
        return true
    }
    
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerElements.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerElements[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if self.fieldSelected == "Format" {
            self.formatSelector.text = self.pickerElements[row]
            if self.formatSelector.text == "Singles" {
                self.bluePlayer2Field.isHidden = true
                self.redPlayer2Field.isHidden = true
                self.bluePlayer2Label.isHidden = true
                self.redPlayer2Label.isHidden = true
            }
            else {
                self.bluePlayer2Field.isHidden = false
                self.redPlayer2Field.isHidden = false
                self.bluePlayer2Label.isHidden = false
                self.redPlayer2Label.isHidden = false
            }
        }
        else if self.fieldSelected == "BP1" {
            self.bluePlayer1Field.text = self.pickerElements[row]
        }
        else if self.fieldSelected == "RP1" {
            self.redPlayer1Field.text = self.pickerElements[row]
        }
        else if self.fieldSelected == "BP2" {
            self.bluePlayer2Field.text = self.pickerElements[row]
        }
        else if self.fieldSelected == "RP2" {
            self.redPlayer2Field.text = self.pickerElements[row]
        }
        else if self.fieldSelected == "Course" {
            self.courseField.text = self.pickerElements[row]
        }
        else if self.fieldSelected == "Tees" {
            self.teesField.text = self.pickerElements[row]
        }
        else if self.fieldSelected == "Scorekeeper" {
            self.scorekeeperField.text = self.pickerElements[row]
        }
        pickerView.isHidden = true
    }

    func playerNameError() {
        let playerErrorAlert = UIAlertController(title: "Oops!", message: "There was an error in the player record.", preferredStyle: UIAlertControllerStyle.alert)
        
        playerErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))

        present(playerErrorAlert, animated: true, completion: nil)
    }
    
    func playerAlreadyExists() {
        let playerErrorAlert = UIAlertController(title: "Oops!", message: "That player already exists.", preferredStyle: UIAlertControllerStyle.alert)
        
        playerErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(playerErrorAlert, animated: true, completion: nil)
    }
    
    func matchAddError() {
        let matchErrorAlert = UIAlertController(title: "Oops!", message: "There was an error in the match record.", preferredStyle: UIAlertControllerStyle.alert)
        
        matchErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(matchErrorAlert, animated: true, completion: nil)
    }
    
    func playerAlreadyHasMatchInRound() {
        let playerErrorAlert = UIAlertController(title: "Oops!", message: "One or more players already have a match in this round.", preferredStyle: UIAlertControllerStyle.alert)
        
        playerErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(playerErrorAlert, animated: true, completion: nil)
    }
    
    func noRoundCourseError() {
        let noRoundAlert = UIAlertController(title: "Oops!", message: "There hasn't been a course entered for this round.", preferredStyle: UIAlertControllerStyle.alert)
        
        noRoundAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(noRoundAlert, animated: true, completion: nil)
    }
    
    func noPlayerNameOrHandicap() {
        let alert = UIAlertController(title: "Oops!", message: "There is not a valid player name and handicap.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }

    func matchInProgressError() {
        let alert = UIAlertController(title: "Oops!", message: "The match is already in progress. It cannot be deleted.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
}

