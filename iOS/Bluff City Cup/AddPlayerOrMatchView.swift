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

extension String {
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        // Use NumberFormatter to check if we can turn the string into a number
        // and to get the locale specific decimal separator.
        let formatter = NumberFormatter()
        formatter.allowsFloats = true // Default is true, be explicit anyways
        let decimalSeparator = formatter.decimalSeparator ?? "."  // Gets the locale specific decimal separator. If for some reason there is none we assume "." is used as separator.

        // Check if we can create a valid number. (The formatter creates a NSNumber, but
        // every NSNumber is a valid double, so we're good!)
        if formatter.number(from: self) != nil {
          // Split our string at the decimal separator
          let split = self.components(separatedBy: decimalSeparator)

          // Depending on whether there was a decimalSeparator we may have one
          // or two parts now. If it is two then the second part is the one after
          // the separator, aka the digits we care about.
          // If there was no separator then the user hasn't entered a decimal
          // number yet and we treat the string as empty, succeeding the check
          let digits = split.count == 2 ? split.last ?? "" : ""

          // Finally check if we're <= the allowed digits
          return digits.count <= maxDecimalPlaces    // TODO: Swift 4.0 replace with digits.count, YAY!
        }

        return false // couldn't turn string into a valid number
      }
}


class AddPlayerOrMatchView: UIViewController, UIPickerViewDelegate, UITextFieldDelegate,UIPickerViewDataSource {
    
    private static let bccBlue = UIColor(red: 0.071, green: 0.176, blue: 0.451, alpha: 1.0)
    private static let bccRed = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1.0)
    private static let surfaceColor = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1.0)
    private static let secondarySurfaceColor = UIColor(red: 0.957, green: 0.965, blue: 0.976, alpha: 1.0)
    private static let textColor = UIColor(red: 0.071, green: 0.082, blue: 0.102, alpha: 1.0)
    private static let secondaryTextColor = UIColor(red: 0.365, green: 0.392, blue: 0.439, alpha: 1.0)
    
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
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var matchLengthLabel: UILabel!
    @IBOutlet weak var pointsField: UITextField!
    @IBOutlet weak var matchLengthField: UISegmentedControl!

    
    @IBOutlet weak var navBar: UINavigationItem!
    var player: Player!
    var match: Match!
    var editType: String!
    var tournament: Tournament!
    
    var pickerElements: [String]!
    var fieldSelected: String!
    
    var model = Model.sharedInstance
    private let formCardView = UIView()
    private let headerCardView = UIView()
    private var didInstallCards = false
    
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
        
        self.pointsField.delegate = self
        
        self.pickerView.delegate = self
        self.pickerView.isHidden = true
        self.pickerElements = [""]
        installDesignCardsIfNeeded()
        configureNavigationAppearance()
        
        
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
            self.matchLengthLabel.isHidden = true
            self.pointsLabel.isHidden = true
            self.roundField.isHidden = true
            self.matchField.isHidden = true
            self.groupField.isHidden = true
            self.startingHoleSegment.isHidden = true
            self.formatSelector.isHidden = true
            self.courseField.isHidden = true
            self.teesField.isHidden = true
            self.scorekeeperField.isHidden = true
            
            self.pointsField.isHidden = true
            self.matchLengthField.isHidden = true
            
            
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
            
            if match.getMatchLength() == 18 {
                self.matchLengthField.selectedSegmentIndex = 1
            }
            else {
                self.matchLengthField.selectedSegmentIndex = 0
            }
            
            self.pointsField.text = String(match.getPoints())

        }
        
        
        
        
        // Do any additional setup after loading the view.
        layoutForm()
        layoutDesignCards()
        applyDesignPass()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutForm()
        layoutDesignCards()
        applyDesignPass()
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
                        let addedPlayer = Player(name: playerNameField.text!, handicap: Double(playerHandicap.text!)!, team: team)
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
                        let addedPlayer = Player(name: playerNameField.text!, handicap: Double(playerHandicap.text!)!, team: team)
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
            if self.roundField.text != "" && self.matchField.text != "" && self.groupField.text != "" && self.formatSelector.text != "" && self.courseField.text != "" && self.teesField.text != "" && self.scorekeeperField.text != "" && self.pointsField.text != "" && self.pointsField.text!.isValidDouble(maxDecimalPlaces: 1) &&
                !(self.matchLengthField.selectedSegmentIndex == 1 && self.startingHoleSegment.selectedSegmentIndex == 1)
            {
                
                
                if self.formatSelector.text == "Singles" {
                    if self.bluePlayer1Field.text != "" && self.redPlayer1Field.text != "" {
                        if tournament.playerAlreadyInMatchInRound(playerName: self.bluePlayer1Field.text!, round: Int(self.roundField.text!)!) || tournament.playerAlreadyInMatchInRound(playerName: self.redPlayer1Field.text!, round: Int(self.roundField.text!)!) {
                            playerAlreadyHasMatchInRound()
                        }
                        else {
                            matchPlayers.append(tournament.getPlayerWithName(self.bluePlayer1Field.text!)!)
                            matchPlayers.append(tournament.getPlayerWithName(self.redPlayer1Field.text!)!)
                            
                            let startingHole = Int(self.startingHoleSegment.titleForSegment(at: self.startingHoleSegment.selectedSegmentIndex)!)!
                            
                            let addedMatch = Match(format: self.formatSelector.text!, players: matchPlayers, scorekeeper: self.scorekeeperField.text!, score: 0,teamWinning: "AS", hole: startingHole, course: self.courseField.text!, tees: self.teesField.text!,round: Int(self.roundField.text!)!, group: Int(self.groupField.text!)!, startingHole: startingHole, matchNumber: Int(self.matchField.text!)!,matchLength: self.matchLengthField.selectedSegmentIndex == 0 ? 9 : 18, points: Double(self.pointsField.text!) ?? 0.0)
                            
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
                            
                            let addedMatch = Match(format: self.formatSelector.text!, players: matchPlayers, score: 0, teamWinning: "AS", hole: startingHole, course: self.courseField.text!, tees: self.teesField.text!, round: Int(self.roundField.text!)!, group: Int(self.groupField.text!)!, startingHole: startingHole, matchNumber: Int(self.matchField.text!)!,matchLength: self.matchLengthField.selectedSegmentIndex == 0 ? 9 : 18, points: Double(self.pointsField.text!) ?? 0.0)
                                
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
                    editPlayer.setHandicap(Double(self.playerHandicap.text!)!)
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
            
            if (self.match.getMatchLength() == 9 && (self.match.getCurrentHole() > 1 && self.match.getStartingHole() == 1)) || (self.match.getMatchLength() == 9 && (self.match.getCurrentHole() > 10 && self.match.getStartingHole() > 10)) || (self.match.getMatchLength() == 18 && self.match.getCurrentHole() > 1) {

                matchInProgressError()
            }
            else {
              
                if (self.roundField.text == "" || self.matchField.text == "" || self.groupField.text == "" || self.formatSelector.text == "" || self.courseField.text == "" || self.teesField.text == "" || self.scorekeeperField.text == "" || self.bluePlayer1Field.text == "" || self.redPlayer1Field.text == "" || self.pointsField.text == "" || !self.pointsField.text!.isValidDouble(maxDecimalPlaces: 1)) ||
                    (self.matchLengthField.selectedSegmentIndex == 1 && self.startingHoleSegment.selectedSegmentIndex == 1)
                {
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
                        
                        editMatch.setPoints(Double(self.pointsField.text!)!)
                        editMatch.setMatchLength(self.matchLengthField.selectedSegmentIndex == 0 ? 9 : 18)
                        
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
        self.pickerElements = ["Alternate Shot", "Best Ball", "Shamble","Singles", "Two Man Scramble"]
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
        }        else {
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
        let playerErrorAlert = UIAlertController(title: "Oops!", message: "There was an error in the player record.", preferredStyle: UIAlertController.Style.alert)
        
        playerErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))

        present(playerErrorAlert, animated: true, completion: nil)
    }
    
    func playerAlreadyExists() {
        let playerErrorAlert = UIAlertController(title: "Oops!", message: "That player already exists.", preferredStyle: UIAlertController.Style.alert)
        
        playerErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(playerErrorAlert, animated: true, completion: nil)
    }
    
    func matchAddError() {
        let matchErrorAlert = UIAlertController(title: "Oops!", message: "There was an error in the match record.", preferredStyle: UIAlertController.Style.alert)
        
        matchErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(matchErrorAlert, animated: true, completion: nil)
    }
    
    func playerAlreadyHasMatchInRound() {
        let playerErrorAlert = UIAlertController(title: "Oops!", message: "One or more players already have a match in this round.", preferredStyle: UIAlertController.Style.alert)
        
        playerErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(playerErrorAlert, animated: true, completion: nil)
    }
    
    func noRoundCourseError() {
        let noRoundAlert = UIAlertController(title: "Oops!", message: "There hasn't been a course entered for this round.", preferredStyle: UIAlertController.Style.alert)
        
        noRoundAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(noRoundAlert, animated: true, completion: nil)
    }
    
    func noPlayerNameOrHandicap() {
        let alert = UIAlertController(title: "Oops!", message: "There is not a valid player name and handicap.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }

    func matchInProgressError() {
        let alert = UIAlertController(title: "Oops!", message: "The match is already in progress. It cannot be deleted.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    

    
}

private extension AddPlayerOrMatchView {
    
    func configureNavigationAppearance() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AddPlayerOrMatchView.bccBlue
        appearance.titleTextAttributes = titleAttributes
        appearance.shadowColor = UIColor.clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    func installDesignCardsIfNeeded() {
        guard !didInstallCards else { return }
        didInstallCards = true
        
        view.backgroundColor = AddPlayerOrMatchView.surfaceColor
        
        headerCardView.backgroundColor = UIColor.white
        headerCardView.layer.cornerRadius = 10
        headerCardView.layer.shadowColor = UIColor.black.cgColor
        headerCardView.layer.shadowOpacity = 0.06
        headerCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerCardView.layer.shadowRadius = 8
        view.insertSubview(headerCardView, at: 0)
        
        formCardView.backgroundColor = UIColor.white
        formCardView.layer.cornerRadius = 10
        formCardView.layer.shadowColor = UIColor.black.cgColor
        formCardView.layer.shadowOpacity = 0.04
        formCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        formCardView.layer.shadowRadius = 6
        view.insertSubview(formCardView, aboveSubview: headerCardView)
    }
    
    func layoutDesignCards() {
        let width = view.bounds.width
        guard width > 0 else { return }
        
        headerCardView.frame = CGRect(x: 16, y: 122, width: width - 32, height: 66)
        
        let visibleControls = allFormControls().filter { !$0.isHidden && $0 !== pickerView }
        if let firstY = visibleControls.map({ $0.frame.minY }).min(),
           let lastY = visibleControls.map({ $0.frame.maxY }).max() {
            formCardView.frame = CGRect(x: 16, y: firstY - 16, width: width - 32, height: lastY - firstY + 32)
        }
    }
    
    func layoutForm() {
        if editType == "Player" || editType == "EditPlayer" {
            layoutPlayerForm()
        } else {
            layoutMatchForm()
        }
        
        pickerView.frame = CGRect(x: 0, y: view.bounds.height - 150, width: view.bounds.width, height: 150)
        pickerView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    }
    
    func layoutPlayerForm() {
        let labelX: CGFloat = 34
        let fieldX: CGFloat = view.bounds.width - 176
        let fieldW: CGFloat = 142
        let rowH: CGFloat = 46
        let startY: CGFloat = 224
        
        setRow(label: playerNameLabel, control: playerNameField, y: startY, labelX: labelX, fieldX: fieldX, fieldW: fieldW)
        setRow(label: playerHandicapLabel, control: playerHandicap, y: startY + rowH, labelX: labelX, fieldX: view.bounds.width - 94, fieldW: 60)
        setRow(label: playerTeamLabel, control: teamSelector, y: startY + rowH * 2, labelX: labelX, fieldX: view.bounds.width - 174, fieldW: 140)
    }
    
    func layoutMatchForm() {
        let labelX: CGFloat = 34
        let rowH: CGFloat = 39
        let startY: CGFloat = 214
        let fullFieldX: CGFloat = 202
        let fullFieldW: CGFloat = view.bounds.width - fullFieldX - 34
        let smallFieldX: CGFloat = view.bounds.width - 84
        let segmentX: CGFloat = view.bounds.width - 166
        let segmentW: CGFloat = 132
        
        setRow(label: matchLengthLabel, control: matchLengthField, y: startY, labelX: labelX, fieldX: segmentX, fieldW: segmentW)
        setRow(label: pointsLabel, control: pointsField, y: startY + rowH, labelX: labelX, fieldX: view.bounds.width - 104, fieldW: 70)
        setRow(label: roundNumberLabel, control: roundField, y: startY + rowH * 2, labelX: labelX, fieldX: smallFieldX, fieldW: 50)
        setRow(label: matchNumberLabel, control: matchField, y: startY + rowH * 3, labelX: labelX, fieldX: smallFieldX, fieldW: 50)
        setRow(label: groupNumberLabel, control: groupField, y: startY + rowH * 4, labelX: labelX, fieldX: smallFieldX, fieldW: 50)
        setRow(label: startingHoleLabel, control: startingHoleSegment, y: startY + rowH * 5, labelX: labelX, fieldX: segmentX, fieldW: segmentW)
        setRow(label: matchFormatLabel, control: formatSelector, y: startY + rowH * 6, labelX: labelX, fieldX: fullFieldX, fieldW: fullFieldW)
        setRow(label: matchCourseLabel, control: courseField, y: startY + rowH * 7, labelX: labelX, fieldX: fullFieldX, fieldW: fullFieldW)
        setRow(label: courseTeesLabel, control: teesField, y: startY + rowH * 8, labelX: labelX, fieldX: fullFieldX, fieldW: fullFieldW)
        setRow(label: bluePlayer1Label, control: bluePlayer1Field, y: startY + rowH * 9, labelX: labelX, fieldX: fullFieldX, fieldW: fullFieldW)
        setRow(label: redPlayer1Label, control: redPlayer1Field, y: startY + rowH * 10, labelX: labelX, fieldX: fullFieldX, fieldW: fullFieldW)
        setRow(label: bluePlayer2Label, control: bluePlayer2Field, y: startY + rowH * 11, labelX: labelX, fieldX: fullFieldX, fieldW: fullFieldW)
        setRow(label: redPlayer2Label, control: redPlayer2Field, y: startY + rowH * 12, labelX: labelX, fieldX: fullFieldX, fieldW: fullFieldW)
        setRow(label: scorekeeperLabel, control: scorekeeperField, y: startY + rowH * 13, labelX: labelX, fieldX: fullFieldX, fieldW: fullFieldW)
    }
    
    func setRow(label: UILabel, control: UIView, y: CGFloat, labelX: CGFloat, fieldX: CGFloat, fieldW: CGFloat) {
        label.frame = CGRect(x: labelX, y: y + 6, width: max(120, fieldX - labelX - 16), height: 28)
        label.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        
        let controlHeight: CGFloat = control is UISegmentedControl ? 32 : 34
        control.frame = CGRect(x: fieldX, y: y + 3, width: fieldW, height: controlHeight)
        control.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
    }
    
    func applyDesignPass() {
        installDesignCardsIfNeeded()
        styleHeader()
        
        formLabels().forEach { styleLabel($0) }
        formTextFields().forEach { styleTextField($0) }
        styleSegmentedControl(teamSelector, tint: AddPlayerOrMatchView.bccBlue)
        styleSegmentedControl(startingHoleSegment, tint: AddPlayerOrMatchView.bccBlue)
        styleSegmentedControl(matchLengthField, tint: AddPlayerOrMatchView.bccBlue)
        stylePicker()
        
        playerNameField.textAlignment = .right
        playerHandicap.keyboardType = .decimalPad
        roundField.keyboardType = .numberPad
        matchField.keyboardType = .numberPad
        groupField.keyboardType = .numberPad
        pointsField.keyboardType = .decimalPad
    }
    
    func styleHeader() {
        headerCardView.subviews.forEach { $0.removeFromSuperview() }
        
        let iconView = UIImageView(frame: CGRect(x: 16, y: 11, width: 40, height: 40))
        iconView.backgroundColor = editType == "Match" || editType == "EditMatch" ? AddPlayerOrMatchView.bccRed : AddPlayerOrMatchView.bccBlue
        iconView.tintColor = UIColor.white
        iconView.layer.cornerRadius = 20
        iconView.contentMode = .center
        iconView.image = UIImage(systemName: editType == "Match" || editType == "EditMatch" ? "flag.2.crossed.fill" : "person.fill")
        headerCardView.addSubview(iconView)
        
        let titleLabel = UILabel(frame: CGRect(x: 72, y: 11, width: headerCardView.bounds.width - 92, height: 24))
        titleLabel.autoresizingMask = [.flexibleWidth]
        titleLabel.text = navBar.title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = AddPlayerOrMatchView.textColor
        headerCardView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel(frame: CGRect(x: 72, y: 38, width: headerCardView.bounds.width - 92, height: 18))
        subtitleLabel.autoresizingMask = [.flexibleWidth]
        subtitleLabel.text = editType == "Match" || editType == "EditMatch" ? "Match setup" : "Player profile"
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = AddPlayerOrMatchView.secondaryTextColor
        headerCardView.addSubview(subtitleLabel)
    }
    
    func styleLabel(_ label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = AddPlayerOrMatchView.textColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
    }
    
    func styleTextField(_ textField: UITextField) {
        textField.borderStyle = .none
        textField.backgroundColor = AddPlayerOrMatchView.secondarySurfaceColor
        textField.textColor = AddPlayerOrMatchView.textColor
        textField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0.871, green: 0.890, blue: 0.922, alpha: 1.0).cgColor
        textField.clearButtonMode = .whileEditing
    }
    
    func styleSegmentedControl(_ segmentedControl: UISegmentedControl, tint: UIColor) {
        segmentedControl.tintColor = tint
        segmentedControl.layer.cornerRadius = 8
        
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = tint
        }
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            NSAttributedString.Key.foregroundColor: AddPlayerOrMatchView.secondaryTextColor
        ], for: .normal)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .selected)
    }
    
    func stylePicker() {
        pickerView.backgroundColor = UIColor.white
        pickerView.layer.borderWidth = 1
        pickerView.layer.borderColor = UIColor(red: 0.871, green: 0.890, blue: 0.922, alpha: 1.0).cgColor
    }
    
    func formLabels() -> [UILabel] {
        return [
            playerTeamLabel, playerHandicapLabel, playerNameLabel,
            roundNumberLabel, matchNumberLabel, groupNumberLabel,
            matchFormatLabel, matchCourseLabel, scorekeeperLabel,
            startingHoleLabel, courseTeesLabel, bluePlayer1Label,
            redPlayer1Label, bluePlayer2Label, redPlayer2Label,
            pointsLabel, matchLengthLabel
        ]
    }
    
    func formTextFields() -> [UITextField] {
        return [
            playerNameField, playerHandicap, courseField, teesField,
            roundField, matchField, groupField, formatSelector,
            scorekeeperField, bluePlayer1Field, redPlayer1Field,
            bluePlayer2Field, redPlayer2Field, pointsField
        ]
    }
    
    func allFormControls() -> [UIView] {
        return formLabels() + formTextFields() + [teamSelector, startingHoleSegment, matchLengthField]
    }
}
