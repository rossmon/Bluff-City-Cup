//
//  MatchScorecardViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 1/31/17.
//  Copyright © 2017 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

enum SideShowing {
    case front9
    case back9
}

enum ScorecardView {
    case score
    case handicapStrokes
}

protocol MatchScorecardViewControllerDelegate {
    func closeMatchScorecard()
}

class MatchScorecardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scorecardTable: UITableView!

    var match: Match!
    var user: User = User.sharedInstance
    @IBOutlet weak var titleLabel: UILabel!
    var delegate: MatchScorecardViewControllerDelegate?
    var sideShowing: SideShowing = .front9
    var scorecardView: ScorecardView = .score
    
    
    @IBOutlet weak var team1Player1Pic: UIImageView!
    
    @IBOutlet weak var team1Player2Pic: UIImageView!
    @IBOutlet weak var team2Player1Pic: UIImageView!
    @IBOutlet weak var team2Player2Pic: UIImageView!
    
    @IBOutlet weak var team1Player1Name: UILabel!
    @IBOutlet weak var team1Player2Name: UILabel!
    @IBOutlet weak var team2Player1Name: UILabel!
    @IBOutlet weak var team2Player2Name: UILabel!
    
    @IBOutlet weak var scoreSelectionView: UIView!
    @IBOutlet weak var teamHeaderView: UIView!
    @IBOutlet weak var front9back9View: UIView!
    @IBOutlet weak var front9Button: UIButton!
    @IBOutlet weak var back9Button: UIButton!
    @IBOutlet weak var scoresButton: UIButton!
    @IBOutlet weak var strokesButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var scoreStatus: UILabel!
    
    @IBOutlet weak var scorecardTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIApplication.shared.statusBarStyle = .lightContent
        //self.scorecardTable.separatorColor = UIColor.clear
        team1Player1Pic.isHidden = true
        team1Player2Pic.isHidden = true
        team2Player1Pic.isHidden = true
        team2Player2Pic.isHidden = true
        
        scoresButton.frame.origin.x = (self.view.frame.width / 3) - 70
        strokesButton.frame.origin.x = (2 * self.view.frame.width / 3)
        front9Button.frame.origin.x = (self.view.frame.width / 3) - 70
        back9Button.frame.origin.x = (2 * self.view.frame.width / 3)
        
        self.backButton.titleLabel?.font = UIFont(name:"Arial", size: self.backButton.titleLabel?.font.pointSize ?? 24.0)
        
        self.scorecardTitleLabel.font = UIFont(name:"Arial", size: self.scorecardTitleLabel.font.pointSize)
        
        
//
        if match == nil {
            match = Model.sharedInstance.tournament.getCurrentMatch(user.getPlayer()!)
        }
        
        reloadScoreStatus()
        
        
        //Get player images
        let t1p1name = match.blueTeamPlayerOne().getName().lowercased().replacingOccurrences(of: " ", with: "_")
        let t2p1name = match.redTeamPlayerOne().getName().lowercased().replacingOccurrences(of: " ", with: "_")
        if match.doubles() {
            let t1p2name = match.blueTeamPlayerTwo()!.getName().lowercased().replacingOccurrences(of: " ", with: "_")
            let t2p2name = match.redTeamPlayerTwo()!.getName().lowercased().replacingOccurrences(of: " ", with: "_")
            
            if let retrievedImage = UserDefaults.standard.object(forKey: t1p2name) {
                self.team1Player2Pic.image = UIImage(data: (retrievedImage as! NSData) as Data)
                self.team1Player2Pic.isHidden = false
            }
            else {
                downloadImage(urlstr: "http://www.montyratings.com/bcc/" + t1p2name + ".png", imageView: self.team1Player2Pic, playerName: t1p2name)
            }
            if let retrievedImage = UserDefaults.standard.object(forKey: t2p2name) {
                self.team2Player2Pic.image = UIImage(data: (retrievedImage as! NSData) as Data)
                self.team2Player2Pic.isHidden = false
            }
            else {
                downloadImage(urlstr: "http://www.montyratings.com/bcc/" + t2p2name + ".png", imageView: self.team2Player2Pic, playerName: t2p2name)
            }
        }
        
        
        if let retrievedImage = UserDefaults.standard.object(forKey: t1p1name) {
            self.team1Player1Pic.image = UIImage(data: (retrievedImage as! NSData) as Data)
            self.team1Player1Pic.isHidden = false
        }
        else {
            downloadImage(urlstr: "http://www.montyratings.com/bcc/" + t1p1name + ".png", imageView: self.team1Player1Pic, playerName: t1p1name)
        }
        if let retrievedImage = UserDefaults.standard.object(forKey: t2p1name) {
            self.team2Player1Pic.image = UIImage(data: (retrievedImage as! NSData) as Data)
            self.team2Player1Pic.isHidden = false
        }
        else {
            downloadImage(urlstr: "http://www.montyratings.com/bcc/" + t2p1name + ".png", imageView: self.team2Player1Pic, playerName: t2p1name)
        }
        
       
        
        //End setting user images
        
        scorecardTable.delegate = self
        scorecardTable.dataSource = self
        
        
        
        titleLabel.text = match.getCourseName() + " - \(match.getFormat())"
        team1Player1Name.text = match.blueTeamPlayerOne().getLastName().uppercased() + " (\(match.blueTeamPlayerOne().getHandicap()))"
        
        team2Player1Name.text = match.redTeamPlayerOne().getLastName().uppercased() + " (\(match.redTeamPlayerOne().getHandicap()))"
        
        if match.getFormat() != "Singles" {
            team1Player2Name.text = (match.blueTeamPlayerTwo()?.getLastName().uppercased())! + " (\(match.blueTeamPlayerTwo()!.getHandicap()))"
            
            team2Player2Name.text = (match.redTeamPlayerTwo()?.getLastName().uppercased())! + " (\(match.redTeamPlayerTwo()!.getHandicap()))"
        }
        else {
            team1Player2Pic.isHidden = true
            team1Player2Name.isHidden = true
            team2Player2Pic.isHidden = true
            team2Player2Name.isHidden = true
        }
        
        var front9 = true
        if match.getCurrentHole() > 9 {
            front9 = false
        }
        if match.getCurrentHole() == 10 && Model.sharedInstance.getTournament().getMatchLength() == 9 && match.getStartingHole() == 1 {
            front9 = true
        }
        
        if front9 { sideShowing = .front9 }
        else { sideShowing = .back9 }
        
        if Model.sharedInstance.getTournament().getMatchLength() == 9 {
            front9back9View.isHidden = true
            
            print(teamHeaderView.frame.size)
            teamHeaderView.frame.size.height = teamHeaderView.frame.size.height - 32
            scoreSelectionView.frame.origin.y = scoreSelectionView.frame.origin.y - 32
            titleLabel.frame.origin.y = titleLabel.frame.origin.y - 32
            scorecardTable.frame.origin.y = scorecardTable.frame.origin.y - 32
            print(teamHeaderView.frame.size)
        }
        
        scoresButton.setTitleColor(self.view.tintColor, for: .selected)
        scoresButton.setTitleColor(UIColor.lightGray, for: .normal)
        scoresButton.adjustsImageWhenHighlighted = false
        scoresButton.isSelected = true
        
        strokesButton.setTitleColor(self.view.tintColor, for: .selected)
        strokesButton.setTitleColor(UIColor.lightGray, for: .normal)
        strokesButton.adjustsImageWhenHighlighted = false
        strokesButton.isSelected = false;
        
        front9Button.setTitleColor(self.view.tintColor, for: .selected)
        front9Button.setTitleColor(UIColor.lightGray, for: .normal)
        front9Button.adjustsImageWhenHighlighted = false
        front9Button.isSelected = front9
        
        back9Button.setTitleColor(self.view.tintColor, for: .selected)
        back9Button.setTitleColor(UIColor.lightGray, for: .normal)
        back9Button.adjustsImageWhenHighlighted = false
        back9Button.isSelected = !front9
        
        titleLabel.frame.origin.y = titleLabel.frame.origin.y + 10
        scorecardTable.frame.origin.y = scorecardTable.frame.origin.y + 10
        
        DispatchQueue.main.async {
            var frameTemp = self.scorecardTable.frame
            frameTemp.size.height = self.scorecardTable.contentSize.height + 5
            self.scorecardTable.frame = frameTemp
        }
    }
    
    func downloadImage(urlstr: String, imageView: UIImageView, playerName: String) {
        let url = URL(string: urlstr)!
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async { // Make sure you're on the main thread here
                if let imageData = UIImage(data: data) {
                    imageView.image = imageData
                    let pngImage = imageData.pngData()
                    UserDefaults.standard.set(pngImage, forKey: playerName)
                }

                imageView.isHidden = false
            }
        }
        task.resume()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    
    @IBAction func front9ButtonPressed(_ sender: Any) {
        if sideShowing != .front9 {
            sideShowing = .front9
            front9Button.isSelected = true
            back9Button.isSelected = false
        }
        self.scorecardTable.reloadData()
        reloadScoreStatus()
        
    }
    @IBAction func back9ButtonPressed(_ sender: Any) {
        if sideShowing != .back9 {
            sideShowing = .back9
            front9Button.isSelected = false
            back9Button.isSelected = true
        }
        self.scorecardTable.reloadData()
        reloadScoreStatus()
        
    }
    
    @IBAction func scoresButtonPressed(_ sender: Any) {
        
        if scorecardView != .score {
            scorecardView = .score
            scoresButton.isSelected = true
            strokesButton.isSelected = false
        }
        self.scorecardTable.reloadData()
        reloadScoreStatus()
    }
    @IBAction func strokesButtonPressed(_ sender: Any) {
        
        if scorecardView != .handicapStrokes {
            scorecardView = .handicapStrokes
            scoresButton.isSelected = false
            strokesButton.isSelected = true
        }
        self.scorecardTable.reloadData()
        reloadScoreStatus()
    }
    
    func reloadScoreStatus() {
        scoreStatus.text = match.currentScoreString()
        if match.winningTeam() == "Blue" {
            scoreStatus.textColor = UIColorFromRGB(0x0F296B)
        }
        else if match.winningTeam() == "Red" {
            scoreStatus.textColor = UIColorFromRGB(0xB70A1C)
        }
        else {
            if !match.isCompleted() { scoreStatus.text = "AS" }
            scoreStatus.textColor = UIColor.black
        }
    }

    @IBAction func cancelScorecard(_ sender: Any) {
        delegate?.closeMatchScorecard()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if match.doubles() {
            if match.getFormat() == "Best Ball" {
                return 8
            }
            else {
                return 5
            }
        }

        else {
            //return 8 - COMMENT OUT 8/14/18
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        if scorecardView == .score {
            let cellIdentifier = "MatchScorecardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchScorecardCell
            
            var front9 = true
            if sideShowing != .front9 {
                front9 = false
            }
            
            if indexPath.row == 0 {
                //cell.setYards(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.setHoleNumber(front9: front9)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
            }
            else if indexPath.row == 1 {
                cell.setHandicap(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
            }
            else if indexPath.row == 2 {
                //cell.setHoleNumber(front9: front9)
                cell.setParNumber(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: CGFloat(0), bottom: CGFloat(0), right: CGFloat(0))
            }
            else if indexPath.row == 3 {
                //cell.backgroundColor = UIColorFromRGB(0x0F296B)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                if match.getFormat() == "Best Ball" {
                    
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else if match.doubles() {
                    cell.doublesCell(team: "Blue", match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else {
                    //SINGLES MATCH
                    
                    //cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                    
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(match.blueTeamPlayerOne(), round: match.getRound()) - COMMENT OUT 8/14/18
                    
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    //cell.playerBestBallOrSinglesCell(player: singlesMatches[0].blueTeamPlayerOne(), match: singlesMatches[0], tournament: Model.sharedInstance.getTournament(), front9: front9) - COMMENT OUT 8/14/18
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
            }
            else if indexPath.row == 4 {
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                if match.getFormat() == "Best Ball" {
                    //cell.backgroundColor = UIColorFromRGB(0x0F296B)
                    
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else if match.doubles() {
                    //cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                    cell.doublesCell(team: "Red", match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else {
                    //SINGLES MATCH
                    //cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                    //cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                    
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(match.blueTeamPlayerOne(), round: match.getRound()) - COMMENT OUT 8/14/18
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    //cell.playerBestBallOrSinglesCell(player: singlesMatches[0].redTeamPlayerOne(), match: singlesMatches[0], tournament: Model.sharedInstance.getTournament(), front9: front9) - COMMENT OUT 8/14/18
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
            }
            else if indexPath.row == 5 {
                cell.blankCellFormatting()
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
            }
            else if indexPath.row == 6 {
                //cell.backgroundColor = UIColorFromRGB(0x0F296B)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                if match.getFormat() == "Best Ball" {
                    //cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                    
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else {
                    //SINGLES MATCH
                    
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(match.blueTeamPlayerOne(), round: match.getRound()) - COMMENT OUT 8/14/18
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    //cell.playerBestBallOrSinglesCell(player: singlesMatches[1].blueTeamPlayerOne(), match: singlesMatches[1], tournament: Model.sharedInstance.getTournament(), front9: front9) - COMMENT OUT 8/14/18
                }
            }
            else if indexPath.row == 7 {
                //cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                if match.getFormat() == "Best Ball" {
                    
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else {
                    //SINGLES MATCH
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(match.blueTeamPlayerOne(), round: match.getRound()) - COMMENT OUT 8/14/18
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player! ,round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    //cell.playerBestBallOrSinglesCell(player: singlesMatches[1].redTeamPlayerOne(), match: singlesMatches[1], tournament: Model.sharedInstance.getTournament(), front9: front9) - COMMENT OUT 8/14/18
                }
            }
            
            cell.setSizes(front9)
            
            return cell
        }
        else {
            /*
            let cellIdentifier = "MatchScorecardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchScorecardCell
            */
            
            let cellIdentifier = "ScorecardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ScorecardCell
            
            var front9 = true
            if sideShowing != .front9 {
                front9 = false
            }
            
            /*
            var front9 = true
            if match.getCurrentHole() > 9 {
                front9 = false
            }
            if match.getCurrentHole() == 10 && Model.sharedInstance.getTournament().getMatchLength() == 9 && match.getStartingHole() == 1 {
                front9 = true
            }*/
            
            if indexPath.row == 0 {
                //cell.setYards(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.setHoleNumber(front9: front9)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
            }
            else if indexPath.row == 1 {
                cell.setHandicap(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
            }
            else if indexPath.row == 2 {
                //cell.setHoleNumber(front9: front9)
                cell.setParNumber(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: CGFloat(0), bottom: CGFloat(0), right: CGFloat(0))
            }
            else if indexPath.row == 3 {
                //cell.backgroundColor = UIColorFromRGB(0x0F296B)
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), oppPlayer: match.redTeamPlayerOne(),match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else if match.doubles() {
                    cell.doublesCell(team: "Blue", match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else {
                    //SINGLES MATCH
                    //cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                    
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(match.blueTeamPlayerOne(), round: match.getRound()) - COMMENT OUT 8/14/18
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player! ,round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    //cell.playerBestBallOrSinglesCell(player: singlesMatches[0].blueTeamPlayerOne(), oppPlayer: singlesMatches[0].redTeamPlayerOne(),match: singlesMatches[0], tournament: Model.sharedInstance.getTournament(), front9: front9) - COMMENT OUT 8/14/18
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), oppPlayer: match.redTeamPlayerOne(),match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
            }
            else if indexPath.row == 4 {
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    //cell.backgroundColor = UIColorFromRGB(0x0F296B)
                    
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerTwo()!, oppPlayer: match.redTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else if match.doubles() {
                    //cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                    cell.doublesCell(team: "Red", match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else {
                    //SINGLES MATCH
                    //cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                    //cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                    
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(match.blueTeamPlayerOne(), round: match.getRound()) - COMMENT OUT 8/14/18
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    //cell.playerBestBallOrSinglesCell(player: singlesMatches[0].redTeamPlayerOne(), oppPlayer: singlesMatches[0].blueTeamPlayerOne(), match: singlesMatches[0], tournament: Model.sharedInstance.getTournament(), front9: front9) - COMMENT OUT 8/14/18
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), oppPlayer: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
            }
            else if indexPath.row == 5 {
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                cell.blankCellFormatting()
            }
            else if indexPath.row == 6 {
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                //cell.backgroundColor = UIColorFromRGB(0x0F296B)
                
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    //cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                    
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), oppPlayer: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else {
                    //SINGLES MATCH
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(match.blueTeamPlayerOne(), round: match.getRound()) - COMMENT OUT 8/14/18
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    //cell.playerBestBallOrSinglesCell(player: singlesMatches[1].blueTeamPlayerOne(), oppPlayer: singlesMatches[1].redTeamPlayerOne(), match: singlesMatches[1], tournament: Model.sharedInstance.getTournament(), front9: front9) - COMMENT OUT 8/14/18
                }
            }
            else if indexPath.row == 7 {
                cell.separatorInset = UIEdgeInsets.init(top: CGFloat(0), left: cell.bounds.size.width, bottom: CGFloat(0), right: CGFloat(0))
                //cell.backgroundColor = UIColorFromRGB(0xB70A1C)
                
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerTwo()!, oppPlayer: match.blueTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                }
                else {
                    //SINGLES MATCH
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(match.blueTeamPlayerOne(), round: match.getRound()) - COMMENT OUT 8/14/18
                    //let singlesMatches = Model.sharedInstance.getTournament().getSinglesGroupMatches(user.player!, round: Model.sharedInstance.getTournament().getPlayerLastRound(user.player!))
                    
                    //cell.playerBestBallOrSinglesCell(player: singlesMatches[1].redTeamPlayerOne(), oppPlayer: singlesMatches[1].blueTeamPlayerOne(), match: singlesMatches[1], tournament: Model.sharedInstance.getTournament(), front9: front9) - COMMENT OUT 8/14/18
                }
            }
            
            cell.setSizes(front9)
            
            return cell
        }
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeLeft
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
