//
//  ScoreEntryViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/14/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol ScoreEntryViewControllerDelegate {
    
    func toggleTopPanelScoreEntry()
    func collapseTopPanelScoreEntry()
    func changeViewScoreEntry(_ menu: String)
    func updateTournament(_ tournament: Tournament)
    //func showScorecard()
}

class ScoreEntryViewController: UIViewController {

    var delegate: ScoreEntryViewControllerDelegate?
    var tournament: Tournament!
    var match: Match!
    var user: User!
    var matchTable: IndividualMatchTableViewController!
    var viewingHoleNumber: Int!
    
    var tempCell: IndividualMatchTableViewCell!
    var tempTableView: UITableView!
    var tempIndexPath: IndexPath!
    
    @IBOutlet weak var entryTitle: UILabel!
    
    @IBOutlet weak var holeNumber: UILabel!
    @IBOutlet weak var holeYards: UILabel!
    @IBOutlet weak var holeHandicap: UILabel!
    @IBOutlet weak var holePar: UILabel!
    
    @IBOutlet weak var holeYardsLabel: UILabel!
    @IBOutlet weak var holeHandicapLabel: UILabel!
    @IBOutlet weak var holeParLabel: UILabel!
    
    @IBOutlet weak var blueTeamScoreLabel: UILabel!
    @IBOutlet weak var blueTeamScore: UILabel!
    @IBOutlet weak var blueTeamScoreView: UIView!
    @IBOutlet weak var redTeamScoreLabel: UILabel!
    @IBOutlet weak var redTeamScore: UILabel!
    @IBOutlet weak var redTeamScoreView: UIView!
    
    @IBOutlet weak var strokeSelectView: UIView!
    
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var tenButton: UIButton!
    
    @IBOutlet weak var nextHoleButton: UIButton!
    @IBOutlet weak var previousHoleButton: UIButton!

    @IBOutlet weak var dimView: UIView!
    
    var latestStrokeSelected: String!

    @IBOutlet weak var scorecardButton: UIView!
    private var scoreEntryNavigationButtonsConfigured = false
    private var scoreEntryScoreCardsConfigured = false
    private var scoreEntryTableContainerConfigured = false
    
    private var strokeButtons: [UIButton?] {
        return [oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nineButton, tenButton]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIApplication.shared.statusBarStyle = .lightContent
        
        self.scorecardButton.isHidden = true
        
        self.tournament = Model.sharedInstance.getTournament()
        
        self.redTeamScoreLabel.text = String("Red Score")
        self.blueTeamScoreLabel.text = String("Blue Score")
        
        
        self.setupButtons()
        self.applyModernScoreEntryStyle()
        
        if let singles = self.tournament.getCurrentMatch(self.user.getPlayer()!)?.singles() {
            if singles {
                self.blueTeamScoreView.isHidden = true
                self.redTeamScoreView.isHidden = true
            }
        }
        
        self.strokeSelectView.isHidden = true
        self.dimView.isHidden = true
        
        // UIApplication.shared.statusBarStyle = .lightContent
        
        // Do any additional setup after loading the view.
    
        //Match is over, display last hole
    
        if self.match.getCurrentHole() > 18 || (self.match.getCurrentHole() == 10 && self.match.getMatchLength() == 9 && self.match.getStartingHole() == 1) {
            self.holeNumber.text = String(self.match.getCurrentHole() - 1)
            
            self.holeYards.text = String(self.tournament.getCourseWithName(name: self.match.getCourseName()).getHole(self.match.getCurrentHole() - 1).getLength())
            self.holeHandicap.text = String(self.tournament.getCourseWithName(name: self.match.getCourseName()).getHole(self.match.getCurrentHole() - 1).getHandicap())
            self.holePar.text = String(self.tournament.getCourseWithName(name: self.match.getCourseName()).getHole(self.match.getCurrentHole() - 1).getPar())
        }
        else {
            self.holeNumber.text = String(self.match.getCurrentHole())
            self.holeYards.text = String(self.tournament.getCourseWithName(name: self.match.getCourseName()).getHole(self.match.getCurrentHole()).getLength())
            self.holeHandicap.text = String(self.tournament.getCourseWithName(name: self.match.getCourseName()).getHole(self.match.getCurrentHole()).getHandicap())
            self.holePar.text = String(self.tournament.getCourseWithName(name: self.match.getCourseName()).getHole(self.match.getCurrentHole()).getPar())
        }
    
        //print(self.match.getCourseName())
        //print(self.tournament.getMatches().count)
        //print(String(self.tournament.getCourseWithName(name: self.match.getCourseName()).getName()))
        //print(String(self.match.getCurrentHole()))
        //print(String(self.tournament.getCourseWithName(name: self.match.getCourseName()).getHole(self.match.getCurrentHole()).getLength()))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        applyBCCPageHeaderSpacing(to: entryTitle)
        updateModernScoreEntryLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsTapped(_ sender: AnyObject) {
        
        delegate?.toggleTopPanelScoreEntry()
    }

    /*
    @IBAction func scorecardPressed(_ sender: Any) {
        
        delegate?.showScorecard()
        
    }*/
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "individualMatchSegue") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            matchTable = segue.destination as? IndividualMatchTableViewController
            matchTable.match = Model.sharedInstance.getTournament().getCurrentMatch(user.getPlayer()!)
            matchTable.delegate = self
            matchTable.viewingHoleNumber = self.viewingHoleNumber
            matchTable.tournament = Model.sharedInstance.getTournament()
            matchTable.user = self.user
        }
    }
    
    
    @IBAction func nextHoleTapped(_ sender: AnyObject) {
        
        let doubles = tournament.getCurrentMatch(user.getPlayer()!)?.doubles()
        let currentMatch = tournament.getCurrentMatch(user.getPlayer()!)
        
        if doubles == true {
            if blueTeamScore.text! != "" && redTeamScore.text! != "" {
                
                //let currentMatch = tournament.getCurrentMatch(user.getPlayer()!)
                let blueScore = Int(blueTeamScore.text!)
                let redScore = Int(redTeamScore.text!)
                
                //Check if on last hole
                if currentMatch!.getMatchLength() == 9 && viewingHoleNumber == 9 /*currentMatch!.onHole().getNumber() == 9*/ {
                    let endMatchAlert = UIAlertController(title: "Stop!", message: "Are you sure you want to end the match?", preferredStyle: UIAlertController.Style.alert)
                    
                    endMatchAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic here")
                        
                        if currentMatch?.getCurrentHole() == 9 {
                            if blueScore < redScore {
                                currentMatch?.blueTeamWinsHole(matchLength: currentMatch!.getMatchLength())
                                currentMatch?.setHoleWinner(hole: 9, winner: "Blue")
                            }
                            else if redScore < blueScore {
                                currentMatch?.redTeamWinsHole(matchLength: currentMatch!.getMatchLength())
                                currentMatch?.setHoleWinner(hole: 9, winner: "Red")
                            }
                            else {
                                currentMatch?.splitHole()
                                currentMatch?.setHoleWinner(hole: 9, winner: "Halved")
                            }
                        }
                        
                        
                        currentMatch?.updateCurrentScore(matchLength: currentMatch!.getMatchLength())
                        currentMatch?.updateMatch(matchLength: currentMatch!.getMatchLength()) {
                            User.sharedInstance.updateRole(tournamentName: self.tournament.getName()) {}
                        }
                        currentMatch?.updateHoleResults(holeNumber: self.viewingHoleNumber, round: currentMatch!.getRound())
                        
                        currentMatch?.finishMatch()
                        
                        //currentMatch?.clearPlayerHoleResults()
                        
                        //TODO: CODE TO END THE MATCH - INCREMENT TO NEXT HOLE
                        self.delegate?.updateTournament(self.tournament)
                        
                        self.delegate?.changeViewScoreEntry("Scoreboard")
                        
                        self.sendMatchNotification(currentMatch!)
                        
                    }))
                    
                    endMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                    }))
                    
                    present(endMatchAlert, animated: true, completion: nil)
                }
                    //Check if on the 18th hole
                else if Int(self.holeNumber.text!) == 18 /*currentMatch!.onHole().getNumber() == 18*/ {
                    let endMatchAlert = UIAlertController(title: "Stop!", message: "Are you sure you want to end the match?", preferredStyle: UIAlertController.Style.alert)
                    
                    endMatchAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic here")
                        
                        //TODO: Does this logic need to change?
                        if currentMatch?.getCurrentHole() == 19 {
                            if blueScore < redScore {
                                currentMatch?.blueTeamWinsHole(matchLength: currentMatch!.getMatchLength())
                                currentMatch?.setHoleWinner(hole: 18, winner: "Blue")
                            }
                            else if redScore < blueScore {
                                currentMatch?.redTeamWinsHole(matchLength: currentMatch!.getMatchLength())
                                currentMatch?.setHoleWinner(hole: 18, winner: "Red")
                            }
                            else {
                                currentMatch?.splitHole()
                                currentMatch?.setHoleWinner(hole: 18, winner: "Halved")
                            }
                        }
                        if blueScore < redScore {
                            currentMatch?.blueTeamWinsHole(matchLength: currentMatch!.getMatchLength())
                            currentMatch?.setHoleWinner(hole: 18, winner: "Blue")
                        }
                        else if redScore < blueScore {
                            currentMatch?.redTeamWinsHole(matchLength: currentMatch!.getMatchLength())
                            currentMatch?.setHoleWinner(hole: 18, winner: "Red")
                        }
                        else {
                            currentMatch?.splitHole()
                            currentMatch?.setHoleWinner(hole: 18, winner: "Halved")
                        }
                        
                        
                        
                        currentMatch?.updateCurrentScore(matchLength: currentMatch!.getMatchLength())
                        currentMatch?.updateMatch(matchLength: currentMatch!.getMatchLength()) {
                            User.sharedInstance.updateRole(tournamentName: self.tournament.getName()) {}
                        }
                        currentMatch?.updateHoleResults(holeNumber: 18, round: currentMatch!.getRound())
                        
                        currentMatch?.finishMatch()
                        
                        //currentMatch?.clearPlayerHoleResults()
                        
                        self.delegate?.updateTournament(self.tournament)
                        
                        self.delegate?.changeViewScoreEntry("Scoreboard")
                        
                        self.sendMatchNotification(currentMatch!)
                    }))
                    
                    endMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                    }))
                    
                    present(endMatchAlert, animated: true, completion: nil)
                }
                    //If not on the last hole
                else {
                    if currentMatch?.getCurrentHole() == viewingHoleNumber {
                        if blueScore < redScore {
                            currentMatch?.blueTeamWinsHole(matchLength: currentMatch!.getMatchLength())
                        }
                        else if redScore < blueScore {
                            currentMatch?.redTeamWinsHole(matchLength: currentMatch!.getMatchLength())
                        }
                        else {
                            currentMatch?.splitHole()
                        }
                    }
                    if blueScore < redScore {
                        currentMatch?.setHoleWinner(hole: viewingHoleNumber, winner: "Blue")
                    }
                    else if redScore < blueScore {
                        currentMatch?.setHoleWinner(hole: viewingHoleNumber, winner: "Red")
                    }
                    else {
                        currentMatch?.setHoleWinner(hole: viewingHoleNumber, winner: "Halved")
                    }
                    
                    //NEED TO RECALCULATE THE MATCH SCORE HERE
                    viewingHoleNumber = viewingHoleNumber + 1
                    
                    delegate?.updateTournament(tournament)
                    
                    updateHoleInformation()
                    
                    matchTable.match = tournament.getCurrentMatch(user.getPlayer()!)
                    matchTable.tournament = tournament
                    updateTeamScores(tournament.getCurrentMatch(user.getPlayer()!)!)
                    
                    matchTable.updateCellStrokes(viewingHoleNumber)
                    
                    currentMatch?.updateCurrentScore(matchLength: currentMatch!.getMatchLength())
                    currentMatch?.updateMatch(matchLength: currentMatch!.getMatchLength()) {}
                    currentMatch?.updateHoleResults(holeNumber: viewingHoleNumber-1, round: currentMatch!.getRound())
                }
                
                
                //UPDATE MATCH HERE
                
                
            }
                //Make sure all players' scores are entered
            else {
                let alert = UIAlertController(title: "Wait!", message: "Please enter all players' scores.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

        }
        else {
            //HANDLE SINGLES MATCH CHECK FOR SCORES
            
            if matchTable.allMatchScoresEntered() {
                if currentMatch!.getMatchLength() == 9 && viewingHoleNumber == 9 {
                    //HANDLE THE END OF 9 HOLE MATCH
                    let endMatchAlert = UIAlertController(title: "Stop!", message: "Are you sure you want to end the match?", preferredStyle: UIAlertController.Style.alert)
                    
                    endMatchAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic here")
                        
                        self.scoreSingleMatches()
                        
                        let singlesMatches = self.tournament.getSinglesGroupMatches(self.user.player!, round: self.tournament.getPlayerLastRound(self.user.player!))
                        
                        //UPDATE MATCH HERE
                        for singleMatch in singlesMatches {
                            singleMatch.updateCurrentScore(matchLength: singleMatch.getMatchLength())
                            singleMatch.updateMatch(matchLength: singleMatch.getMatchLength()) {}
                            singleMatch.updateHoleResults(holeNumber: self.viewingHoleNumber, round: currentMatch!.getRound())
                        }
                        
                        currentMatch?.finishMatch()
                        
                        User.sharedInstance.updateRole(tournamentName: self.tournament.getName()) {}
                        
                        //currentMatch?.clearPlayerHoleResults()
                        
                        self.delegate?.updateTournament(self.tournament)
                        
                        self.delegate?.changeViewScoreEntry("Scoreboard")
                        
                        self.sendMatchNotification(currentMatch!)
                        
 
                    }))
 
                    endMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                    }))
 
                    present(endMatchAlert, animated: true, completion: nil)
                    
                }
                else if viewingHoleNumber == 18 {
                    //HANDLE THE END OF MATCH
                    let endMatchAlert = UIAlertController(title: "Stop!", message: "Are you sure you want to end the match?", preferredStyle: UIAlertController.Style.alert)
                    
                    endMatchAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Ok logic here")
                        
                        self.scoreSingleMatches()

                        let singlesMatches = self.tournament.getSinglesGroupMatches(self.user.player!, round: self.tournament.getPlayerLastRound(self.user.player!))
                        //UPDATE MATCH HERE
                        for singleMatch in singlesMatches {
                            singleMatch.updateCurrentScore(matchLength: singleMatch.getMatchLength())
                            singleMatch.updateMatch(matchLength: singleMatch.getMatchLength()) {}
                            singleMatch.updateHoleResults(holeNumber: self.viewingHoleNumber, round: currentMatch!.getRound())
                        }
                        
                        currentMatch?.finishMatch()
                        
                        User.sharedInstance.updateRole(tournamentName: self.tournament.getName()) {}
                        
                        //currentMatch?.clearPlayerHoleResults()
                        
                        self.delegate?.updateTournament(self.tournament)
                        
                        self.delegate?.changeViewScoreEntry("Scoreboard")
                        
                        self.sendMatchNotification(currentMatch!)
                    }))
                    
                    endMatchAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                    }))
                    
                    present(endMatchAlert, animated: true, completion: nil)
                }
                else {
                    
                    scoreSingleMatches()
                    
                    viewingHoleNumber = viewingHoleNumber + 1
                    
                    delegate?.updateTournament(tournament)
                    
                    updateHoleInformation() //Update HUD hole information
                    
                    matchTable.match = currentMatch
                    matchTable.tournament = tournament
                    
                    matchTable.updateCellStrokes(viewingHoleNumber)
                    
                    let singlesMatches = self.tournament.getSinglesGroupMatches(user.player!, round: self.tournament.getPlayerLastRound(user.player!))
                    //UPDATE MATCH HERE
                    for singleMatch in singlesMatches {
                        singleMatch.updateCurrentScore(matchLength: singleMatch.getMatchLength())
                        singleMatch.updateMatch(matchLength: singleMatch.getMatchLength()) {}
                        singleMatch.updateHoleResults(holeNumber: viewingHoleNumber-1, round: currentMatch!.getRound())
                    }

                }
                

                
                
            }
            else {
                let alert = UIAlertController(title: "Wait!", message: "Please enter all players' scores.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func updateHoleInformation() {
        holeNumber.text = String(tournament.getCourseWithName(name: tournament.getCurrentMatch(user.getPlayer()!)!.getCourseName()).getHole(viewingHoleNumber).getNumber())
        holeYards.text = String(tournament.getCourseWithName(name: tournament.getCurrentMatch(user.getPlayer()!)!.getCourseName()).getHole(viewingHoleNumber).getLength())
        holeHandicap.text = String(tournament.getCourseWithName(name: tournament.getCurrentMatch(user.getPlayer()!)!.getCourseName()).getHole(viewingHoleNumber).getHandicap())
        holePar.text = String(tournament.getCourseWithName(name: tournament.getCurrentMatch(user.getPlayer()!)!.getCourseName()).getHole(viewingHoleNumber).getPar())
    }
    
    func scoreSingleMatches() {
        
        var match1BlueActualScore = Int()
        var match1RedActualScore = Int()
        var match2BlueActualScore = Int()
        var match2RedActualScore = Int()

        (match1BlueActualScore,match1RedActualScore,match2BlueActualScore,match2RedActualScore) = matchTable.getSinglesMatchScores()
        
        var is4playerGroup = true
        if tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!)).count == 1 { is4playerGroup = false }

        
        //Update hole scores for singles matches
        tournament.getSinglesGroupMatches(user.getPlayer()!, round: tournament.getPlayerLastRound(user.player!))[0].blueTeamPlayerOne().setHoleScore(viewingHoleNumber, score: match1BlueActualScore, round: tournament.getSinglesGroupMatches(user.getPlayer()!, round: tournament.getPlayerLastRound(user.player!))[0].getRound())
        tournament.getSinglesGroupMatches(user.getPlayer()!, round: tournament.getPlayerLastRound(user.player!))[0].blueTeamPlayerOne().setHoleResults(round: tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[0].getRound(),holeNumber: viewingHoleNumber, score: match1BlueActualScore)
        
        tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[0].redTeamPlayerOne().setHoleScore(viewingHoleNumber, score: match1RedActualScore, round: tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[0].getRound())
        tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[0].redTeamPlayerOne().setHoleResults(round: tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[0].getRound(), holeNumber: viewingHoleNumber, score: match1RedActualScore)
        
        if is4playerGroup {
            tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].blueTeamPlayerOne().setHoleScore(viewingHoleNumber, score: match2BlueActualScore, round: tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].getRound())
            tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].blueTeamPlayerOne().setHoleResults(round: tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].getRound(),holeNumber: viewingHoleNumber, score: match2BlueActualScore)
            
            tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].redTeamPlayerOne().setHoleScore(viewingHoleNumber, score: match2RedActualScore, round: tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].getRound())
            tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].redTeamPlayerOne().setHoleResults(round: tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].getRound(), holeNumber: viewingHoleNumber, score: match2RedActualScore)
        }
        
        
        
        //let holeHandicap = tournament.getCourseWithName(name: tournament.getCurrentMatch(user.getPlayer()!)!.getCourseName()).getHole(tournament.getCurrentMatch(user.getPlayer()!)!.getCurrentHole()).getHandicap()
        
        let holeHandicap = tournament.getCourseWithName(name: tournament.getCurrentMatch(user.getPlayer()!)!.getCourseName()).getHole(viewingHoleNumber).getHandicap()
            
        /*
        tournament.getCourseWithName(name: tournament.getCurrentMatch(user.getPlayer()!)?.getCourseName()).getHole(tournament.getCurrentMatch(user.getPlayer()!)?.getCurrentHole()).getHandicap()
            
            
            tournament.getCurrentMatch(user.getPlayer()!)?.onHole().getHandicap()*/
        
        let lowestHandicapM1 = tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[0].getLowestHandicap()
        let match1 = tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[0]
        let bP1M1Handicap = match1.blueTeamPlayerOne().getHandicapWithSlope(match1.getCourseSlope(),rating: match1.getCourseRating(), par: match1.getCoursePar())
        let rP1M1Handicap = match1.redTeamPlayerOne().getHandicapWithSlope(match1.getCourseSlope(),rating: match1.getCourseRating(), par: match1.getCoursePar())
        let match1BlueHandicapScore = handicapScore(match1BlueActualScore, playerHandicap: bP1M1Handicap - lowestHandicapM1, holeHandicap: holeHandicap)
        let match1RedHandicapScore = handicapScore(match1RedActualScore, playerHandicap: rP1M1Handicap - lowestHandicapM1, holeHandicap: holeHandicap)

        
        var lowestHandicapM2 : Int = 0
        var match2: Match!
        var bP1M2Handicap: Int = 0
        var rP1M2Handicap: Int = 0
        var match2BlueHandicapScore: Int = 0
        var match2RedHandicapScore: Int = 0
        
        if is4playerGroup {
            lowestHandicapM2 = tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1].getLowestHandicap()
            match2 = tournament.getSinglesGroupMatches(user.getPlayer()!,round: tournament.getPlayerLastRound(user.player!))[1]
            bP1M2Handicap = match2.blueTeamPlayerOne().getHandicapWithSlope(match2.getCourseSlope(),rating: match2.getCourseRating(), par: match2.getCoursePar())
            rP1M2Handicap = match2.redTeamPlayerOne().getHandicapWithSlope(match2.getCourseSlope(),rating: match2.getCourseRating(), par: match2.getCoursePar())
            match2BlueHandicapScore = handicapScore(match2BlueActualScore, playerHandicap: bP1M2Handicap - lowestHandicapM2, holeHandicap: holeHandicap)
            match2RedHandicapScore = handicapScore(match2RedActualScore, playerHandicap: rP1M2Handicap - lowestHandicapM2, holeHandicap: holeHandicap)
        }

        
        //Calculate winners based on handicaps
        if tournament.getCurrentMatch(user.getPlayer()!)?.currentScore() != 19 {
            if tournament.getCurrentMatch(user.getPlayer()!)?.getCurrentHole() == viewingHoleNumber {
                if match1BlueHandicapScore < match1RedHandicapScore {
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].blueTeamWinsHole(matchLength: tournament.getCurrentMatch(user.getPlayer()!)!.getMatchLength())
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].setHoleWinner(hole: viewingHoleNumber, winner: "Blue")
                }
                else if match1RedHandicapScore < match1BlueHandicapScore {
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].redTeamWinsHole(matchLength: tournament.getCurrentMatch(user.getPlayer()!)!.getMatchLength())
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].setHoleWinner(hole: viewingHoleNumber, winner: "Red")
                }
                else {
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].splitHole()
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].setHoleWinner(hole: viewingHoleNumber, winner: "Halved")
                }
                
                if is4playerGroup {
                    if match2BlueHandicapScore < match2RedHandicapScore {
                        tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].blueTeamWinsHole(matchLength: tournament.getCurrentMatch(user.getPlayer()!)!.getMatchLength())
                        tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].setHoleWinner(hole: viewingHoleNumber, winner: "Blue")
                    }
                    else if match2RedHandicapScore < match2BlueHandicapScore {
                        tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].redTeamWinsHole(matchLength: tournament.getCurrentMatch(user.getPlayer()!)!.getMatchLength())
                        tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].setHoleWinner(hole: viewingHoleNumber, winner: "Red")
                    }
                    else {
                        tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].splitHole()
                        tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].setHoleWinner(hole: viewingHoleNumber, winner: "Halved")
                    }
                }
                
            }
            
            //UPDATE HOLE SCORE REGARDLESS
            if match1BlueHandicapScore < match1RedHandicapScore {
                tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].setHoleWinner(hole: viewingHoleNumber, winner: "Blue")
            }
            else if match1RedHandicapScore < match1BlueHandicapScore {
                tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].setHoleWinner(hole: viewingHoleNumber, winner: "Red")
            }
            else {
                tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[0].setHoleWinner(hole: viewingHoleNumber, winner: "Halved")
            }
            
            if is4playerGroup {
                if match2BlueHandicapScore < match2RedHandicapScore {
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].setHoleWinner(hole: viewingHoleNumber, winner: "Blue")
                }
                else if match2RedHandicapScore < match2BlueHandicapScore {
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].setHoleWinner(hole: viewingHoleNumber, winner: "Red")
                }
                else {
                    tournament.getSinglesGroupMatches(user.getPlayer()! ,round: tournament.getPlayerLastRound(user.player!))[1].setHoleWinner(hole: viewingHoleNumber, winner: "Halved")
                }
            }
            
        }
    }
    
    func handicapScore(_ actualScore: Int, playerHandicap: Int, holeHandicap: Int) -> Int {
        var handicapScore = Int()
        
        if playerHandicap >= 36 {
            if (playerHandicap - 36) >= holeHandicap {
                handicapScore = actualScore - 3
            }
            else {
                handicapScore = actualScore - 2
            }
        }
        else if playerHandicap >= 18 {
            if (playerHandicap - 18) >= holeHandicap {
                handicapScore = actualScore - 2
            }
            else {
                handicapScore = actualScore - 1
            }
        }
        else {
            if playerHandicap >= holeHandicap {
                handicapScore = actualScore - 1
            }
            else {
                handicapScore = actualScore
            }
        }
        
        return handicapScore
    }
    
    func sendMatchNotification(_ match: Match) {
        
        var winnerNames = ""
        var loserNames = ""
    
        
        if match.singles() {
            if match.getMatchScore(matchLength: match.getMatchLength()).teamUp == "Blue" {
                winnerNames = match.blueTeamPlayerOne().getName()
                loserNames = match.redTeamPlayerOne().getName()
            }
            else if match.getMatchScore(matchLength: match.getMatchLength()).teamUp == "Red" {
                winnerNames = match.redTeamPlayerOne().getName()
                loserNames = match.blueTeamPlayerOne().getName()
            }
        }
        else {
            if match.getMatchScore(matchLength: match.getMatchLength()).teamUp == "Blue" {
                winnerNames = match.blueTeamPlayerOne().getLastName() + "/" + match.blueTeamPlayerTwo()!.getLastName()
                loserNames = match.redTeamPlayerOne().getLastName() + "/" + match.redTeamPlayerTwo()!.getLastName()
            }
            else if match.getMatchScore(matchLength: match.getMatchLength()).teamUp == "Red" {
                winnerNames = match.redTeamPlayerOne().getLastName() + "/" + match.redTeamPlayerTwo()!.getLastName()
                loserNames = match.blueTeamPlayerOne().getLastName() + "/" + match.blueTeamPlayerTwo()!.getLastName()            }
        }
        
        Model.sharedInstance.sendMatchNotification(winningTeam: match.winningTeam(),winnerNames: winnerNames, loserNames: loserNames, scoreString: match.getMatchScore(matchLength: match.getMatchLength()).scoreString, round: match.getRound(), match: match.getMatchNumber())
    }
    
    @IBAction func previousHoleTapped(_ sender: AnyObject) {
        if self.holeNumber.text == "1" {
            let alert = UIAlertController(title: "Idiot!", message: "You are on the first hole.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if self.holeNumber.text == "10" && tournament.getCurrentMatch(user.getPlayer()!)!.getMatchLength() == 9 {
            let alert = UIAlertController(title: "Sorry!", message: "You are on the 10th hole in a 9 hole match.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            //Insert code to go back a hole
            viewingHoleNumber = viewingHoleNumber - 1
            updateHoleInformation()
            
            matchTable.match = tournament.getCurrentMatch(user.getPlayer()!)
            matchTable.tournament = tournament
            matchTable.updateCellStrokes(viewingHoleNumber)  //send it the current viewing hole number
            updateTeamScores(tournament.getCurrentMatch(user.getPlayer()!)!)
        }
    }
    
    @IBAction func oneStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 1, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func twoStrokeSelected(_ sender: AnyObject) {
        //matchTable.updateCellWithScore(tempTableView, didSelectRowAtIndexPath: tempIndexPath, score: 2)
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 2, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func threeStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 3, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func fourStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 4, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func fiveStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 5, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func sixStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 6, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func sevenStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 7, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func eightStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 8, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func nineStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 9, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    @IBAction func tenStrokeSelected(_ sender: AnyObject) {
        matchTable.updateCellWithScore(tempCell, tableView: tempTableView, indexPath: tempIndexPath, score: 10, viewingHoleNumber: viewingHoleNumber)
        strokeSelectView.isHidden = true
        dimView.isHidden = true
    }
    
    func setupButtons() {
        for button in strokeButtons {
            button?.layer.cornerRadius = 18
            button?.layer.borderWidth = 1
            button?.layer.shadowColor = UIColorFromRGB(0x0F296B).cgColor
            button?.layer.shadowOpacity = 0.10
            button?.layer.shadowRadius = 8
            button?.layer.shadowOffset = CGSize(width: 0, height: 3)
            button?.layer.masksToBounds = false
        }
    }
    
    private func applyModernScoreEntryStyle() {
        view.backgroundColor = UIColorFromRGB(0xEEF1F5)
        
        applyBCCPageHeaderSpacing(to: entryTitle)
        entryTitle.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        
        configureTeamScoreCard(blueTeamScoreView, titleLabel: blueTeamScoreLabel, scoreLabel: blueTeamScore, color: UIColorFromRGB(0x0F296B))
        configureTeamScoreCard(redTeamScoreView, titleLabel: redTeamScoreLabel, scoreLabel: redTeamScore, color: UIColorFromRGB(0xB70A1C))
        configureScoreEntryScoreCards()
        
        blueTeamScoreLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        redTeamScoreLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        blueTeamScore.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
        redTeamScore.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
        
        [holePar, holeHandicap, holeYards].forEach { label in
            label?.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
            label?.textColor = .white
        }
        
        [holeParLabel, holeHandicapLabel, holeYardsLabel].forEach { label in
            label?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            label?.textColor = UIColor(white: 1.0, alpha: 0.82)
        }
        
        holeNumber.font = UIFont.monospacedDigitSystemFont(ofSize: 38, weight: .semibold)
        holeNumber.textColor = .white
        
        if let footerView = holePar.superview {
            footerView.backgroundColor = UIColorFromRGB(0x0F296B)
        }
        
        configureScoreEntryNavigationButtons()
        [previousHoleButton, nextHoleButton].forEach { button in
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColorFromRGB(0x0F296B)
            button.layer.cornerRadius = 9
            button.layer.borderWidth = 0
            button.layer.shadowColor = UIColorFromRGB(0x0F296B).cgColor
            button.layer.shadowOpacity = 0.20
            button.layer.shadowRadius = 10
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.masksToBounds = false
        }
        
        strokeSelectView.backgroundColor = .clear
        strokeSelectView.layer.cornerRadius = 0
        strokeSelectView.layer.shadowOpacity = 0
        strokeSelectView.layer.masksToBounds = false
        
        for button in strokeButtons {
            button?.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 25, weight: .semibold)
            button?.setTitleColor(UIColorFromRGB(0x0F296B), for: .normal)
            button?.backgroundColor = .white
            button?.layer.borderColor = UIColorFromRGB(0xD7DCE5).cgColor
            button?.layer.borderWidth = 1
        }
    }
    
    private func updateModernScoreEntryLayout() {
        holeNumber.layer.cornerRadius = min(holeNumber.bounds.width, holeNumber.bounds.height) / 2
        
        [previousHoleButton, nextHoleButton].forEach { button in
            if let button = button {
                button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
            }
        }
        
        positionScoreEntryTableContainer()
        positionScoreEntryScoreCards()
        positionScoreEntryNavigationButtons()
        positionStrokePickerButtons()
        
        if !strokeSelectView.bounds.isEmpty {
            strokeSelectView.layer.shadowPath = UIBezierPath(roundedRect: strokeSelectView.bounds, cornerRadius: strokeSelectView.layer.cornerRadius).cgPath
        }
        
        for button in strokeButtons {
            if let button = button {
                button.layer.cornerRadius = 15
                button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
            }
        }
    }

    private func positionStrokePickerButtons() {
        guard !view.bounds.isEmpty else { return }
        
        let pickerWidth = min(view.bounds.width - 48, 390)
        let pickerHeight: CGFloat = 560
        let pickerX = (view.bounds.width - pickerWidth) / 2
        let pickerY = max(entryTitle.superview?.frame.maxY ?? 88, (view.bounds.height - pickerHeight) / 2)
        strokeSelectView.frame = CGRect(x: pickerX, y: pickerY, width: pickerWidth, height: pickerHeight)
        
        let horizontalGap: CGFloat = 10
        let verticalGap: CGFloat = 18
        let buttonHeight: CGFloat = 66
        let buttonWidth = (pickerWidth - (horizontalGap * 2)) / 3
        let rowsTop: CGFloat = 8
        let rowStep = buttonHeight + verticalGap
        
        let orderedButtons = [oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nineButton]
        
        for index in 0..<orderedButtons.count {
            guard let button = orderedButtons[index] else { continue }
            let column = index % 3
            let row = index / 3
            let x = CGFloat(column) * (buttonWidth + horizontalGap)
            let y = rowsTop + CGFloat(row) * rowStep
            button.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
        }
        
        let tenWidth = buttonWidth
        tenButton?.frame = CGRect(
            x: (pickerWidth - tenWidth) / 2,
            y: rowsTop + (3 * rowStep) + 12,
            width: tenWidth,
            height: buttonHeight
        )
    }
    
    private func configureTeamScoreCard(_ scoreView: UIView, titleLabel: UILabel, scoreLabel: UILabel, color: UIColor) {
        scoreView.backgroundColor = UIColorFromRGB(0xFBFCFF)
        scoreView.layer.cornerRadius = 10
        scoreView.layer.borderWidth = 1.5
        scoreView.layer.borderColor = color.withAlphaComponent(0.75).cgColor
        scoreView.layer.masksToBounds = true
        titleLabel.textColor = color
        scoreLabel.textColor = color
    }
    
    private func configureScoreEntryNavigationButtons() {
        guard !scoreEntryNavigationButtonsConfigured else { return }
        scoreEntryNavigationButtonsConfigured = true
        
        for constraint in view.constraints {
            if constraint.firstItem === previousHoleButton || constraint.secondItem === previousHoleButton || constraint.firstItem === nextHoleButton || constraint.secondItem === nextHoleButton {
                constraint.isActive = false
            }
        }
        
        previousHoleButton.translatesAutoresizingMaskIntoConstraints = true
        nextHoleButton.translatesAutoresizingMaskIntoConstraints = true
    }
    
    private func configureScoreEntryScoreCards() {
        guard !scoreEntryScoreCardsConfigured else { return }
        scoreEntryScoreCardsConfigured = true
        
        for constraint in view.constraints {
            if constraint.firstItem === blueTeamScoreView || constraint.secondItem === blueTeamScoreView || constraint.firstItem === redTeamScoreView || constraint.secondItem === redTeamScoreView {
                constraint.isActive = false
            }
        }
        
        for scoreView in [blueTeamScoreView, redTeamScoreView] {
            scoreView?.constraints.forEach { $0.isActive = false }
            scoreView?.translatesAutoresizingMaskIntoConstraints = true
        }
        
        view.bringSubviewToFront(blueTeamScoreView)
        view.bringSubviewToFront(redTeamScoreView)
    }

    private func configureScoreEntryTableContainer() {
        guard !scoreEntryTableContainerConfigured else { return }
        guard let tableContainer = matchTable?.view.superview else { return }
        scoreEntryTableContainerConfigured = true
        
        for constraint in view.constraints {
            if constraint.firstItem === tableContainer || constraint.secondItem === tableContainer {
                constraint.isActive = false
            }
        }
        
        tableContainer.translatesAutoresizingMaskIntoConstraints = true
        matchTable.view.translatesAutoresizingMaskIntoConstraints = true
        matchTable.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @discardableResult
    private func positionScoreEntryTableContainer() -> CGRect? {
        guard let matchTable = matchTable else { return nil }
        guard let tableContainer = matchTable.view.superview else { return nil }
        
        configureScoreEntryTableContainer()
        
        let sideInset: CGFloat = 20
        let headerBottom = entryTitle.superview?.frame.maxY ?? 88
        let footerTop = holePar.superview?.frame.minY ?? (view.bounds.height - 75)
        let tableTop = headerBottom + 10
        let tableHeight = max(120, footerTop - tableTop - 12)
        let tableFrame = CGRect(x: sideInset, y: tableTop, width: view.bounds.width - (sideInset * 2), height: tableHeight)
        
        tableContainer.frame = tableFrame
        matchTable.view.frame = tableContainer.bounds
        matchTable.individualMatchTableView.layoutIfNeeded()
        
        return tableFrame
    }
    
    private func positionScoreEntryScoreCards() {
        guard scoreEntryScoreCardsConfigured else { return }
        guard let matchTable = matchTable else { return }
        
        if blueTeamScoreView.isHidden || redTeamScoreView.isHidden {
            matchTable.individualMatchTableView.tableHeaderView = nil
            return
        }
        
        let tableFrame = positionScoreEntryTableContainer() ?? matchTable.view.convert(matchTable.view.bounds, to: view)
        let cardGap: CGFloat = 8
        let cardHeight: CGFloat = 58
        let cardWidth = (tableFrame.width - cardGap) / 2
        let cardTop = tableFrame.minY
        
        blueTeamScoreView.frame = CGRect(x: tableFrame.minX, y: cardTop, width: cardWidth, height: cardHeight)
        redTeamScoreView.frame = CGRect(x: blueTeamScoreView.frame.maxX + cardGap, y: cardTop, width: cardWidth, height: cardHeight)
        
        let headerHeight = cardHeight + 10
        if matchTable.individualMatchTableView.tableHeaderView?.frame.height != headerHeight {
            matchTable.individualMatchTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableFrame.width, height: headerHeight))
            matchTable.individualMatchTableView.tableHeaderView?.backgroundColor = .clear
        }
    }
    
    private func positionScoreEntryNavigationButtons() {
        guard scoreEntryNavigationButtonsConfigured else { return }
        guard let matchTable = matchTable else { return }
        
        let tableFrame = positionScoreEntryTableContainer() ?? matchTable.view.convert(matchTable.view.bounds, to: view)
        let buttonGap: CGFloat = 8
        let buttonHeight: CGFloat = 48
        let buttonWidth = (tableFrame.width - buttonGap) / 2
        let contentHeight = matchTable.individualMatchTableView.contentSize.height
        let top = min(tableFrame.maxY - buttonHeight, tableFrame.minY + contentHeight + 12)
        
        previousHoleButton.frame = CGRect(x: tableFrame.minX, y: top, width: buttonWidth, height: buttonHeight)
        nextHoleButton.frame = CGRect(x: previousHoleButton.frame.maxX + buttonGap, y: top, width: buttonWidth, height: buttonHeight)
    }
    
    private func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func updateTeamScores(_ current_match: Match) {
        var blueScore = Int()
        var redScore = Int()
        
        let blueP1ActualScore = current_match.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: current_match.getRound())
        //let blueP2ActualScore = current_match.blueTeamPlayerTwo()!.getHoleScore(current_match.getHole(viewingHoleNumber).getNumber())
        let redP1ActualScore = current_match.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: current_match.getRound())
        //let redP2ActualScore = current_match.redTeamPlayerTwo()!.getHoleScore(current_match.getHole(viewingHoleNumber).getNumber())
        
        
        if current_match.getFormat() == "Alternate Shot" {
            var blue_team_handicap = current_match.getTeamHandicap().blueTeamHandicap
            var red_team_handicap = current_match.getTeamHandicap().redTeamHandicap
            
            
            //Adjust for match handicaps - strokes on hardest holes
            if blue_team_handicap < red_team_handicap {
                red_team_handicap = red_team_handicap - blue_team_handicap
                blue_team_handicap = 0
            }
            else {
                blue_team_handicap = blue_team_handicap - red_team_handicap
                red_team_handicap = 0
                
            }
                //Int(round(Double(current_match.blueTeamPlayerOne().handicap) * 0.6 + Double(current_match.blueTeamPlayerTwo()!.getHandicap()) * 0.4))
            
            if blue_team_handicap >= 36 {
                if (blue_team_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 3
                }
                else {
                    blueScore = blueP1ActualScore - 2
                }
            }
            else if blue_team_handicap >= 18 {
                if (blue_team_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 2
                }
                else {
                    blueScore = blueP1ActualScore - 1
                }
            }
            else {
                if blue_team_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 1
                }
                else {
                    blueScore = blueP1ActualScore
                }
            }
            
            
                //Int(round(Double(current_match.redTeamPlayerOne().handicap) * 0.6 + Double(current_match.redTeamPlayerTwo()!.getHandicap()) * 0.4))
            
            if red_team_handicap >= 36 {
                if (red_team_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 3
                }
                else {
                    redScore = redP1ActualScore - 2
                }
            }
            else if red_team_handicap >= 18 {
                if (red_team_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 2
                }
                else {
                    redScore = redP1ActualScore - 1
                }
            }
            else {
                if red_team_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 1
                }
                else {
                    redScore = redP1ActualScore
                }
            }
        }
        else if current_match.getFormat() == "Best Ball" {
            let lowestHandicap = current_match.getLowestHandicap()
            let blue_P1_handicap = current_match.blueTeamPlayerOne().getHandicapWithSlope(current_match.getCourseSlope(),rating: current_match.getCourseRating(), par: current_match.getCoursePar()) - lowestHandicap
            let blue_P2_handicap = current_match.blueTeamPlayerTwo()!.getHandicapWithSlope(current_match.getCourseSlope(),rating: current_match.getCourseRating(), par: current_match.getCoursePar()) - lowestHandicap
            let red_P1_handicap = current_match.redTeamPlayerOne().getHandicapWithSlope(current_match.getCourseSlope(),rating: current_match.getCourseRating(), par: current_match.getCoursePar()) - lowestHandicap
            let red_P2_handicap = current_match.redTeamPlayerTwo()!.getHandicapWithSlope(current_match.getCourseSlope(),rating: current_match.getCourseRating(), par: current_match.getCoursePar()) - lowestHandicap
            
            var blueScoreP1 = Int()
            var blueScoreP2 = Int()
            var redScoreP1 = Int()
            var redScoreP2 = Int()
            
            if blue_P1_handicap >= 36 {
                if (blue_P1_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScoreP1 = blueP1ActualScore - 3
                }
                else {
                    blueScoreP1 = blueP1ActualScore - 2
                }
            }
            else if blue_P1_handicap >= 18 {
                if (blue_P1_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScoreP1 = blueP1ActualScore - 2
                }
                else {
                    blueScoreP1 = blueP1ActualScore - 1
                }
            }
            else {
                if blue_P1_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScoreP1 = blueP1ActualScore - 1
                }
                else {
                    blueScoreP1 = blueP1ActualScore
                }
            }
            
            if red_P1_handicap >= 36 {
                if (red_P1_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScoreP1 = redP1ActualScore - 3
                }
                else {
                    redScoreP1 = redP1ActualScore - 2
                }
            }
            else if red_P1_handicap >= 18 {
                if (red_P1_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScoreP1 = redP1ActualScore - 2
                }
                else {
                    redScoreP1 = redP1ActualScore - 1
                }
            }
            else {
                if red_P1_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScoreP1 = redP1ActualScore - 1
                }
                else {
                    redScoreP1 = redP1ActualScore
                }
            }
            
            if let _ = current_match.blueTeamPlayerTwo() {
                let blueP2ActualScore = current_match.blueTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: current_match.getRound())
                
                if blue_P2_handicap >= 36 {
                    if (blue_P2_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        blueScoreP2 = blueP2ActualScore - 3
                    }
                    else {
                        blueScoreP2 = blueP2ActualScore - 2
                    }
                }
                else if blue_P2_handicap >= 18 {
                    if (blue_P2_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        blueScoreP2 = blueP2ActualScore - 2
                    }
                    else {
                        blueScoreP2 = blueP2ActualScore - 1
                    }
                }
                else {
                    if blue_P2_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        blueScoreP2 = blueP2ActualScore - 1
                    }
                    else {
                        blueScoreP2 = blueP2ActualScore
                    }
                }

            }
            
            if let _ = current_match.redTeamPlayerTwo() {
                let redP2ActualScore = current_match.redTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: current_match.getRound())
                
                if red_P2_handicap >= 36 {
                    if (red_P2_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        redScoreP2 = redP2ActualScore - 3
                    }
                    else {
                        redScoreP2 = redP2ActualScore - 2
                    }
                }
                else if red_P2_handicap >= 18 {
                    if (red_P2_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        redScoreP2 = redP2ActualScore - 2
                    }
                    else {
                        redScoreP2 = redP2ActualScore - 1
                    }
                }
                else {
                    if red_P2_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        redScoreP2 = redP2ActualScore - 1
                    }
                    else {
                        redScoreP2 = redP2ActualScore
                    }
                }

            }
            
            
            if blueScoreP1 == 0 && blueScoreP2 == 0 {
                blueScore = 0
            }
            else if blueScoreP1 == 0 {
                blueScore = blueScoreP2
            }
            else if blueScoreP2 == 0 {
                blueScore = blueScoreP1
            }
            else {
                if blueScoreP1 > blueScoreP2 {
                    blueScore = blueScoreP2
                }
                else {
                    blueScore = blueScoreP1
                }
            }
            
            if redScoreP1 == 0 && redScoreP2 == 0 {
                redScore = 0
            }
            else if redScoreP1 == 0 {
                redScore = redScoreP2
            }
            else if redScoreP2  == 0 {
                redScore = redScoreP1
            }
            else {
                if redScoreP1 > redScoreP2 {
                    redScore = redScoreP2
                }
                else {
                    redScore = redScoreP1
                }
            }
            
        }
        else if current_match.getFormat() == "Shamble" {
            let lowestHandicap = current_match.getLowestHandicap()
            let blue_P1_handicap = current_match.blueTeamPlayerOne().shambleHandicap(current_match.getCourseSlope(),rating: current_match.getCourseRating(), par: current_match.getCoursePar()) - lowestHandicap
            let blue_P2_handicap = current_match.blueTeamPlayerTwo()!.shambleHandicap(current_match.getCourseSlope(),rating: current_match.getCourseRating(), par: current_match.getCoursePar()) - lowestHandicap
            let red_P1_handicap = current_match.redTeamPlayerOne().shambleHandicap(current_match.getCourseSlope(),rating: current_match.getCourseRating(), par: current_match.getCoursePar()) - lowestHandicap
            let red_P2_handicap = current_match.redTeamPlayerTwo()!.shambleHandicap(current_match.getCourseSlope(),rating: current_match.getCourseRating(), par: current_match.getCoursePar()) - lowestHandicap
            
            var blueScoreP1 = Int()
            var blueScoreP2 = Int()
            var redScoreP1 = Int()
            var redScoreP2 = Int()
            
            if blue_P1_handicap >= 36 {
                if (blue_P1_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScoreP1 = blueP1ActualScore - 3
                }
                else {
                    blueScoreP1 = blueP1ActualScore - 2
                }
            }
            else if blue_P1_handicap >= 18 {
                if (blue_P1_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScoreP1 = blueP1ActualScore - 2
                }
                else {
                    blueScoreP1 = blueP1ActualScore - 1
                }
            }
            else {
                if blue_P1_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScoreP1 = blueP1ActualScore - 1
                }
                else {
                    blueScoreP1 = blueP1ActualScore
                }
            }
            
            if red_P1_handicap >= 36 {
                if (red_P1_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScoreP1 = redP1ActualScore - 3
                }
                else {
                    redScoreP1 = redP1ActualScore - 2
                }
            }
            else if red_P1_handicap >= 18 {
                if (red_P1_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScoreP1 = redP1ActualScore - 2
                }
                else {
                    redScoreP1 = redP1ActualScore - 1
                }
            }
            else {
                if red_P1_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScoreP1 = redP1ActualScore - 1
                }
                else {
                    redScoreP1 = redP1ActualScore
                }
            }
            
            if let _ = current_match.blueTeamPlayerTwo() {
                let blueP2ActualScore = current_match.blueTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: current_match.getRound())
                
                if blue_P2_handicap >= 36 {
                    if (blue_P2_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        blueScoreP2 = blueP2ActualScore - 3
                    }
                    else {
                        blueScoreP2 = blueP2ActualScore - 2
                    }
                }
                else if blue_P2_handicap >= 18 {
                    if (blue_P2_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        blueScoreP2 = blueP2ActualScore - 2
                    }
                    else {
                        blueScoreP2 = blueP2ActualScore - 1
                    }
                }
                else {
                    if blue_P2_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        blueScoreP2 = blueP2ActualScore - 1
                    }
                    else {
                        blueScoreP2 = blueP2ActualScore
                    }
                }

            }
            
            if let _ = current_match.redTeamPlayerTwo() {
                let redP2ActualScore = current_match.redTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: current_match.getRound())
                
                if red_P2_handicap >= 36 {
                    if (red_P2_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        redScoreP2 = redP2ActualScore - 3
                    }
                    else {
                        redScoreP2 = redP2ActualScore - 2
                    }
                }
                else if red_P2_handicap >= 18 {
                    if (red_P2_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        redScoreP2 = redP2ActualScore - 2
                    }
                    else {
                        redScoreP2 = redP2ActualScore - 1
                    }
                }
                else {
                    if red_P2_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                        redScoreP2 = redP2ActualScore - 1
                    }
                    else {
                        redScoreP2 = redP2ActualScore
                    }
                }

            }
            
            
            if blueScoreP1 == 0 && blueScoreP2 == 0 {
                blueScore = 0
            }
            else if blueScoreP1 == 0 {
                blueScore = blueScoreP2
            }
            else if blueScoreP2 == 0 {
                blueScore = blueScoreP1
            }
            else {
                if blueScoreP1 > blueScoreP2 {
                    blueScore = blueScoreP2
                }
                else {
                    blueScore = blueScoreP1
                }
            }
            
            if redScoreP1 == 0 && redScoreP2 == 0 {
                redScore = 0
            }
            else if redScoreP1 == 0 {
                redScore = redScoreP2
            }
            else if redScoreP2  == 0 {
                redScore = redScoreP1
            }
            else {
                if redScoreP1 > redScoreP2 {
                    redScore = redScoreP2
                }
                else {
                    redScore = redScoreP1
                }
            }
            
        }
        else if current_match.getFormat() == "Two Man Scramble" {
            
            var blue_team_handicap = current_match.getTeamHandicap().blueTeamHandicap
            var red_team_handicap = current_match.getTeamHandicap().redTeamHandicap
            
            
            //Adjust for match handicaps - strokes on hardest holes
            if blue_team_handicap < red_team_handicap {
                red_team_handicap = red_team_handicap - blue_team_handicap
                blue_team_handicap = 0
            }
            else {
                blue_team_handicap = blue_team_handicap - red_team_handicap
                red_team_handicap = 0
                
            }
            
            if blue_team_handicap >= 36 {
                if (blue_team_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 3
                }
                else {
                    blueScore = blueP1ActualScore - 2
                }
            }
            else if blue_team_handicap >= 18 {
                if (blue_team_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 2
                }
                else {
                    blueScore = blueP1ActualScore - 1
                }
            }
            else {
                if blue_team_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 1
                }
                else {
                    blueScore = blueP1ActualScore
                }
            }
            
            if red_team_handicap >= 36 {
                if (red_team_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 3
                }
                else {
                    redScore = redP1ActualScore - 2
                }
            }
            else if red_team_handicap >= 18 {
                if (red_team_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 2
                }
                else {
                    redScore = redP1ActualScore - 1
                }
            }
            else {
                if red_team_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 1
                }
                else {
                    redScore = redP1ActualScore
                }
            }
            
        }
        else if current_match.getFormat() == "Singles" {
            
            let lowestHandicap = current_match.getLowestHandicap()
            let blue_team_handicap = current_match.getSinglesHandicaps().blueTeamHandicap - lowestHandicap
                //current_match.blueTeamPlayerOne().handicap
            
            if blue_team_handicap >= 36 {
                if (blue_team_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 3
                }
                else {
                    blueScore = blueP1ActualScore - 2
                }
            }
            else if blue_team_handicap >= 18 {
                if (blue_team_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 2
                }
                else {
                    blueScore = blueP1ActualScore - 1
                }
            }
            else {
                if blue_team_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    blueScore = blueP1ActualScore - 1
                }
                else {
                    blueScore = blueP1ActualScore
                }
            }
            
            let red_team_handicap = current_match.getSinglesHandicaps().redTeamHandicap - lowestHandicap
                //current_match.redTeamPlayerOne().handicap
            
            if red_team_handicap >= 36 {
                if (red_team_handicap - 36) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 3
                }
                else {
                    redScore = redP1ActualScore - 2
                }
            }
            else if red_team_handicap >= 18 {
                if (red_team_handicap - 18) >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 2
                }
                else {
                    redScore = redP1ActualScore - 1
                }
            }
            else {
                if red_team_handicap >= tournament.getCourseWithName(name: current_match.getCourseName()).getHole(viewingHoleNumber).getHandicap() {
                    redScore = redP1ActualScore - 1
                }
                else {
                    redScore = redP1ActualScore
                }
            }
            
        }
        
        if blueScore <= 0 {
            blueTeamScore.text = ""
        }
        else {
            blueTeamScore.text = String(blueScore)
        }
        
        if redScore <= 0 {
            redTeamScore.text = ""
        }
        else {
            redTeamScore.text = String(redScore)
        }
    }
}

extension ScoreEntryViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        //Logic to change views?
        
        delegate?.collapseTopPanelScoreEntry()
        delegate?.changeViewScoreEntry(menu)
        
    }
}

extension ScoreEntryViewController: IndividualMatchTableViewControllerDelegate {
    
    func selectedRow(_ cell: IndividualMatchTableViewCell, tableView: UITableView, indexPath: IndexPath) {
        strokeSelectView.isHidden = false
        tempCell = cell
        tempTableView = tableView
        tempIndexPath = indexPath
        
        dimView.isHidden = false
        dimView.backgroundColor = UIColor.black
        dimView.alpha = 0.55
        view.bringSubviewToFront(dimView)
        view.bringSubviewToFront(strokeSelectView)
    }
    
    func updateTeamHoleScores(_ current_match: Match) {
        
        updateCurrentMatch(current_match)
        updateTeamScores(current_match)
        
        
    }
    
    func updateCurrentMatch(_ currentMatch: Match) {
        
        if currentMatch.getCurrentHole() < 19 {
            //let currentHole = currentMatch.getCurrentHole()
            tournament.getCurrentMatch(user.getPlayer()!)?.blueTeamPlayerOne().setHoleScore(viewingHoleNumber, score: currentMatch.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: currentMatch.getRound()), round: currentMatch.getRound())
            tournament.getCurrentMatch(user.getPlayer()!)?.blueTeamPlayerOne().setHoleResults(round: tournament.getCurrentMatch(user.getPlayer()!)!.getRound(),holeNumber: viewingHoleNumber, score: currentMatch.blueTeamPlayerOne().getHoleScore(viewingHoleNumber, round: currentMatch.getRound()))
            
            if tournament.getCurrentMatch(user.getPlayer()!)?.blueTeamPlayerTwo() != nil {
                tournament.getCurrentMatch(user.getPlayer()!)?.blueTeamPlayerTwo()!.setHoleScore(viewingHoleNumber, score: currentMatch.blueTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: currentMatch.getRound()), round: currentMatch.getRound())
                tournament.getCurrentMatch(user.getPlayer()!)?.blueTeamPlayerTwo()!.setHoleResults(round: tournament.getCurrentMatch(user.getPlayer()!)!.getRound(),holeNumber: viewingHoleNumber, score: currentMatch.blueTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: currentMatch.getRound()))
            }
            
            tournament.getCurrentMatch(user.getPlayer()!)?.redTeamPlayerOne().setHoleScore(viewingHoleNumber, score: currentMatch.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: currentMatch.getRound()), round: currentMatch.getRound())
            tournament.getCurrentMatch(user.getPlayer()!)?.redTeamPlayerOne().setHoleResults(round: tournament.getCurrentMatch(user.getPlayer()!)!.getRound(), holeNumber: viewingHoleNumber, score: currentMatch.redTeamPlayerOne().getHoleScore(viewingHoleNumber, round: currentMatch.getRound()))
            
            if tournament.getCurrentMatch(user.getPlayer()!)?.redTeamPlayerTwo() != nil {
                tournament.getCurrentMatch(user.getPlayer()!)?.redTeamPlayerTwo()!.setHoleScore(viewingHoleNumber, score: currentMatch.redTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: currentMatch.getRound()), round: currentMatch.getRound())
                tournament.getCurrentMatch(user.getPlayer()!)?.redTeamPlayerTwo()!.setHoleResults(round: tournament.getCurrentMatch(user.getPlayer()!)!.getRound(),holeNumber: viewingHoleNumber, score: currentMatch.redTeamPlayerTwo()!.getHoleScore(viewingHoleNumber, round: currentMatch.getRound()))
            }
            
            delegate?.updateTournament(tournament)
        }
    }
}
