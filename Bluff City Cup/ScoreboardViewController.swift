//
//  ScoreboardViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/14/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

@objc
protocol ScoreboardViewControllerDelegate {
    
    @objc optional func toggleTopPanelScoreboard()
    @objc optional func collapseTopPanelScoreboard()
    @objc optional func changeViewScoreboard(_ menu: String, scorecardMatch: Match?)

}


class ScoreboardViewController: UIViewController, MatchTableViewControllerDelegate, MatchTableViewNewControllerDelegate {
    
    var delegate: ScoreboardViewControllerDelegate?
    
    var tournament: Tournament!
    var user: User!
    
    var exampleBlueScore = 3.5
    var exampleRedScore = 2.5
    var exampleBlueLiveScore = 5
    var exampleRedLiveScore = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIApplication.shared.statusBarStyle = .lightContent
        
        
        
        DispatchQueue.main.async {
            self.updateScores()
        }
        
        self.scoreboardTitleLabel.font = UIFont(name:"Arial", size: self.scoreboardTitleLabel.font.pointSize)
        
        self.blueTeamCompletedScore.font = UIFont(name:"Arial", size: self.blueTeamCompletedScore.font.pointSize)
        self.blueLiveScoreLabel.font = UIFont(name:"Arial", size: self.blueLiveScoreLabel.font.pointSize)
        self.redTeamCompletedScore.font = UIFont(name:"Arial", size: self.redTeamCompletedScore.font.pointSize)
        self.redLiveScoreLabel.font = UIFont(name:"Arial", size: self.redLiveScoreLabel.font.pointSize)
        self.blueTeamName.font = UIFont(name:"Arial", size: self.blueTeamName.font.pointSize)
        self.redTeamName.font = UIFont(name:"Arial", size: self.redTeamName.font.pointSize)
        self.liveLabel.font = UIFont(name:"Arial", size: self.liveLabel.font.pointSize)
        
        print("Updated Scores")
        
        User.sharedInstance.updateRole(tournamentName: tournament.getName()) {}
        
        
        liveScoreImage.layer.cornerRadius = 5.0
        liveScoreImage.layer.masksToBounds = true
        
        self.blueTeamView.layer.cornerRadius = 5.0
        self.blueTeamView.layer.shadowColor = UIColor.black.cgColor
        self.blueTeamView.layer.shadowOpacity = 0.5
        self.blueTeamView.layer.shadowOffset = .zero
        self.blueTeamView.layer.shadowRadius = 10
        self.blueTeamView.layer.masksToBounds = true
        
        self.redTeamView.layer.cornerRadius = 5.0
        self.redTeamView.layer.shadowColor = UIColor.black.cgColor
        self.redTeamView.layer.shadowOpacity = 0.5
        self.redTeamView.layer.shadowOffset = .zero
        self.redTeamView.layer.shadowRadius = 10
        self.redTeamView.layer.masksToBounds = true
        // Do any additional setup after loading the view.

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingsTapped(_ sender: AnyObject) {
        
        delegate?.toggleTopPanelScoreboard?()
    }
    
    @IBOutlet weak var liveLabel: UILabel!
    
    @IBOutlet weak var blueTeamName: UILabel!
    @IBOutlet weak var redTeamName: UILabel!

    
    @IBOutlet weak var liveScoreImage: UIImageView!
    
    @IBOutlet weak var blueTeamCompletedScore: UILabel!
    @IBOutlet weak var blueLiveScoreLabel: UILabel!
    
    @IBOutlet weak var redTeamCompletedScore: UILabel!
    @IBOutlet weak var redLiveScoreLabel: UILabel!
    
    @IBOutlet weak var matchTableView: UITableViewCell!
    
    @IBOutlet weak var scoreboardTitleLabel: UILabel!
    
    @IBOutlet weak var scoreboardContainerView: UIView!
    
    @IBOutlet weak var blueTeamView: UIView!
    @IBOutlet weak var redTeamView: UIView!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    

    //OLD CODE
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "scoreboardSegue") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let scoreboardTable = segue.destination as! MatchTableViewController
            //scoreboardTable.matches = self.matches
            scoreboardTable.tournament = self.tournament
            scoreboardTable.delegate = self
        }
    }*/
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "scoreboardSegueNew") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let scoreboardTable = segue.destination as! MatchTableViewControllerNew
            //scoreboardTable.matches = self.matches
            scoreboardTable.tournament = self.tournament
            scoreboardTable.delegate = self
        }
    }
    
    func updateScores() {
        
        let (blueScore,redScore) = tournament.getCompletedScores()
        
        blueTeamCompletedScore.text = String(blueScore)
        redTeamCompletedScore.text = String(redScore)
        
        let (blueLiveWins, redLiveWins) = tournament.liveScores()
        
        blueLiveScoreLabel.text = String(blueScore + blueLiveWins)
        redLiveScoreLabel.text = String(redScore + redLiveWins)
    }
    
    func updateScoreboard(_ newTournament: Tournament) {
        self.tournament = newTournament
        DispatchQueue.main.async {
            // update label
            self.updateScores()

        }
    }
    
    func showScorecard(_ match: Match) {
        
        settingSelected("Scorecard", scorecardMatch: match)
    }
    
    
}

extension ScoreboardViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        //Logic to change views?
        
        delegate?.collapseTopPanelScoreboard?()
        delegate?.changeViewScoreboard?(menu, scorecardMatch: scorecardMatch)
    }
}



