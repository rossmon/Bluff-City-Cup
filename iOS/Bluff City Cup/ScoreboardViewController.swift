//
//  ScoreboardViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/14/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

extension UIViewController {
    func applyBCCPageHeaderSpacing(to titleLabel: UILabel) {
        guard let headerView = titleLabel.superview else { return }
        
        let headerHeight: CGFloat = 100
        let titleBottomInset: CGFloat = 10
        
        for constraint in headerView.constraints {
            if constraint.firstAttribute == .height && constraint.secondItem == nil {
                constraint.constant = headerHeight
            }
            
            let pinsHeaderBottomToTitle = constraint.firstItem === headerView &&
                constraint.firstAttribute == .bottom &&
                constraint.secondItem === titleLabel &&
                constraint.secondAttribute == .bottom
            
            if pinsHeaderBottomToTitle {
                constraint.constant = titleBottomInset
            }
        }
        
        headerView.setNeedsLayout()
    }
}

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
    
    private let liveHeaderLayerName = "liveHeaderLayer"
    private let scoreboardSurfaceColor = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIApplication.shared.statusBarStyle = .lightContent
        
        
        
        DispatchQueue.main.async {
            self.updateScores()
        }
        
        configureScoreboardHeader()
        
        print("Updated Scores")
        
        User.sharedInstance.updateRole(tournamentName: tournament.getName()) {}
        // Do any additional setup after loading the view.

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        applyBCCPageHeaderSpacing(to: scoreboardTitleLabel)
        applyScoreboardSurfaceLayout()
        updateScorePanelShadow(blueTeamView)
        updateScorePanelShadow(redTeamView)
        updateScorePanelShadow(liveScoreImage)
        updateLiveScoreHeaderLayer()
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
    
    private func configureScoreboardHeader() {
        view.backgroundColor = scoreboardSurfaceColor
        scoreboardContainerView.backgroundColor = scoreboardSurfaceColor
        blueTeamView.superview?.backgroundColor = scoreboardSurfaceColor
        applyBCCPageHeaderSpacing(to: scoreboardTitleLabel)
        applyScoreboardSurfaceLayout()
        scoreboardTitleLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        scoreboardTitleLabel.textColor = UIColor.white
        
        configureTeamPanel(blueTeamView, color: UIColorFromRGB(0x122D73))
        configureTeamPanel(redTeamView, color: UIColorFromRGB(0xB70A1C))
        configureLivePanel()

        blueTeamName.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        redTeamName.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        blueTeamCompletedScore.font = UIFont.monospacedDigitSystemFont(ofSize: 19, weight: .semibold)
        redTeamCompletedScore.font = UIFont.monospacedDigitSystemFont(ofSize: 19, weight: .semibold)
        blueLiveScoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .medium)
        redLiveScoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .medium)
        liveLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)

        [blueTeamCompletedScore, redTeamCompletedScore, blueLiveScoreLabel, redLiveScoreLabel].forEach { label in
            label?.adjustsFontSizeToFitWidth = true
            label?.minimumScaleFactor = 0.75
        }

        // Default text colors — overridden by applyTeamPanelLeadingState once scores load
        blueTeamName.textColor = UIColorFromRGB(0x122D73)
        blueTeamCompletedScore.textColor = UIColorFromRGB(0x122D73)
        redTeamName.textColor = UIColorFromRGB(0xB70A1C)
        redTeamCompletedScore.textColor = UIColorFromRGB(0xB70A1C)
        blueLiveScoreLabel.textColor = UIColorFromRGB(0x122D73)
        redLiveScoreLabel.textColor = UIColorFromRGB(0xB70A1C)
        liveLabel.textColor = UIColor.white
    }
    
    private func applyScoreboardSurfaceLayout() {
        guard let titleHeader = scoreboardTitleLabel.superview,
              let scoreHeader = blueTeamView.superview else { return }
        
        scoreHeader.backgroundColor = scoreboardSurfaceColor
        scoreboardContainerView.backgroundColor = scoreboardSurfaceColor
        
        for constraint in view.constraints {
            let scoreHeaderBelowTitle = constraint.firstItem === scoreHeader &&
                constraint.firstAttribute == .top &&
                constraint.secondItem === titleHeader &&
                constraint.secondAttribute == .bottom
            
            if scoreHeaderBelowTitle {
                constraint.constant = 8
            }
            
            let matchListBelowScoreHeader = constraint.firstItem === scoreboardContainerView &&
                constraint.firstAttribute == .top &&
                constraint.secondItem === scoreHeader &&
                constraint.secondAttribute == .bottom
            
            if matchListBelowScoreHeader {
                constraint.constant = 12
            }
        }
    }
    
    private func configureTeamPanel(_ panel: UIView, color: UIColor) {
        panel.backgroundColor = UIColor.white
        panel.layer.cornerRadius = 8
        panel.layer.borderWidth = 1.5
        panel.layer.borderColor = color.cgColor
        panel.layer.shadowOpacity = 0
        panel.layer.masksToBounds = false
    }

    private func applyTeamPanelLeadingState() {
        let (blueScore, redScore) = tournament.getCompletedScores()
        let blueColor = UIColorFromRGB(0x122D73)
        let redColor = UIColorFromRGB(0xB70A1C)

        let blueLeading = blueScore > redScore
        let redLeading = redScore > blueScore

        // Blue panel
        blueTeamView.backgroundColor = blueLeading ? blueColor : UIColor.white
        blueTeamView.layer.borderColor = blueColor.cgColor
        blueTeamName.textColor = blueLeading ? UIColor.white : blueColor
        blueTeamCompletedScore.textColor = blueLeading ? UIColor.white : blueColor

        // Red panel
        redTeamView.backgroundColor = redLeading ? redColor : UIColor.white
        redTeamView.layer.borderColor = redColor.cgColor
        redTeamName.textColor = redLeading ? UIColor.white : redColor
        redTeamCompletedScore.textColor = redLeading ? UIColor.white : redColor
    }
    
    private func configureLivePanel() {
        liveScoreImage.image = nil
        liveScoreImage.backgroundColor = UIColor.white
        liveScoreImage.layer.cornerRadius = 8
        liveScoreImage.layer.borderWidth = 1
        liveScoreImage.layer.borderColor = UIColorFromRGB(0xE4E8EF).cgColor
        liveScoreImage.layer.shadowColor = UIColor.black.cgColor
        liveScoreImage.layer.shadowOpacity = 0.05
        liveScoreImage.layer.shadowOffset = CGSize(width: 0, height: 1)
        liveScoreImage.layer.shadowRadius = 4
        liveScoreImage.layer.masksToBounds = false
    }
    
    private func updateScorePanelShadow(_ panel: UIView) {
        panel.layer.shadowPath = UIBezierPath(roundedRect: panel.bounds, cornerRadius: panel.layer.cornerRadius).cgPath
    }
    
    private func updateLiveScoreHeaderLayer() {
        liveScoreImage.layer.sublayers?.removeAll(where: { $0.name == liveHeaderLayerName })
        
        let headerLayer = CALayer()
        headerLayer.name = liveHeaderLayerName
        headerLayer.frame = CGRect(x: 0, y: 0, width: liveScoreImage.bounds.width, height: 29)
        headerLayer.backgroundColor = UIColorFromRGB(0x101318).cgColor
        headerLayer.cornerRadius = liveScoreImage.layer.cornerRadius
        headerLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        liveScoreImage.layer.insertSublayer(headerLayer, at: 0)
    }
    
    private func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
        let (blueScore, redScore) = tournament.getCompletedScores()

        blueTeamCompletedScore.text = String(blueScore)
        redTeamCompletedScore.text = String(redScore)

        let (blueLiveWins, redLiveWins) = tournament.liveScores()

        blueLiveScoreLabel.text = String(blueScore + blueLiveWins)
        redLiveScoreLabel.text = String(redScore + redLiveWins)

        applyTeamPanelLeadingState()
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
