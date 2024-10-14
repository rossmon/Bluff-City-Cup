//
//  MatchScorecardViewControllerNew.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 7/7/22.
//  Copyright © 2022 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

enum SideShowingNew {
    case front9
    case back9
}

enum ScorecardViewNew {
    case score
    case handicapStrokes
}

protocol MatchScorecardViewControllerDelegateNew {
    func closeMatchScorecard()
}

class MatchScorecardViewControllerNew: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scorecardTable: UITableView!

    var match: Match!
    var user: User = User.sharedInstance
    
    @IBOutlet weak var roundMatchLabel: UILabel!
    @IBOutlet weak var formatCourseLabel: UILabel!
    var delegate: MatchScorecardViewControllerDelegateNew?
    var sideShowing: SideShowingNew = .front9
    var scorecardView: ScorecardViewNew = .score
    
    
    @IBOutlet weak var team1Player1Pic: UIImageView!
    @IBOutlet weak var team1Player2Pic: UIImageView!
    @IBOutlet weak var team2Player1Pic: UIImageView!
    @IBOutlet weak var team2Player2Pic: UIImageView!
    
    @IBOutlet weak var team1Player1Name: UILabel!
    @IBOutlet weak var team1Player2Name: UILabel!
    @IBOutlet weak var team2Player1Name: UILabel!
    @IBOutlet weak var team2Player2Name: UILabel!
    
    @IBOutlet weak var teamHeaderView: UIView!

    @IBOutlet weak var scoreStrokeSwitch: UISegmentedControl!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var scoreStatus: UILabel!
    
    @IBOutlet weak var scorecardTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIApplication.shared.statusBarStyle = .lightContent
        //self.scorecardTable.separatorColor = UIColor.clear
        
        
        // selected option color
        scoreStrokeSwitch.setTitleTextAttributes([.foregroundColor: UIColorFromRGB(0x0F296B)], for: .selected)
        

        // color of other options
        scoreStrokeSwitch.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        team1Player1Pic.isHidden = true
        team1Player2Pic.isHidden = true
        team2Player1Pic.isHidden = true
        team2Player2Pic.isHidden = true
        
        self.backButton.titleLabel?.font = UIFont(name:"Arial", size: self.backButton.titleLabel?.font.pointSize ?? 24.0)
        
        self.scorecardTitleLabel.font = UIFont(name:"Arial", size: self.scorecardTitleLabel.font.pointSize)
        
        self.roundMatchLabel.font = UIFont(name:"Arial", size: self.roundMatchLabel.font.pointSize)
        self.formatCourseLabel.font = UIFont(name:"Arial", size: self.formatCourseLabel.font.pointSize)
        
        self.scoreStatus.font = UIFont(name:"Arial", size: self.scoreStatus.font.pointSize)
        self.scoreStatus.font = self.scoreStatus.font.bold
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
        
        
        roundMatchLabel.text = "Round " + String(match.getRound()) + ", Match " + String(match.getMatchNumber())
        
        formatCourseLabel.text = match.getCourseName() + " - \(match.getFormat())"
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
        
        
        /*var tableFrame = self.scorecardTable.frame
        tableFrame.size.height = tableHeight
        self.scorecardTable.frame = tableFrame
        self.scorecardTable.setNeedsDisplay()*/
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

    @IBAction func cancelScorecard(_ sender: Any) {
        delegate?.closeMatchScorecard()
    }
    
    
    @IBAction func scoreStrokeSwitch(_ sender: Any) {
        switch scoreStrokeSwitch.selectedSegmentIndex
        {
            case 0:
                scorecardView = .score
                //textLabel.text = "First Segment Selected"
            case 1:
            scorecardView = .handicapStrokes
                //textLabel.text = "Second Segment Selected"
            default:
                break
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let matchLength = Model.sharedInstance.tournament.getMatchLength()
        
        if match.doubles() && matchLength == 9 {
            if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" { return 7 }
            else { return 5 }
        }
        else if match.doubles() && matchLength == 18 {
            if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" { return 14 }
            else { return 10 }
        }
        else if matchLength == 9 {
            return 5
        }
        else if matchLength == 18 {
            return 10
        }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        var scoreSelected = true
        if scorecardView == .handicapStrokes { scoreSelected = false }
        
        let matchLength = Model.sharedInstance.tournament.getMatchLength()

            let cellIdentifier = "MatchScorecardCellNew"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchScorecardCellNew
            
            cell.cleanupForReuse()
            cell.blankCellFormatting()
            
            var front9 = true
            if matchLength == 9 && match.getStartingHole() == 10 {
                front9 = false
            }
            
            if indexPath.row == 0 {
                cell.setHoleNumber(front9: front9)
                cell.formatHoleHeader()
                cell.formatTopCell()

            }
            else if indexPath.row == 1 {
                cell.setHandicap(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.formatHoleHeader()
            }
            else if indexPath.row == 2 {
                cell.setParNumber(match: match, tournament: Model.sharedInstance.getTournament(), front9: front9)
                cell.formatHoleHeader()
            }
            else if indexPath.row == 3 {
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9, scoreSelected: scoreSelected, oppPlayer: match.redTeamPlayerOne())
                }
                else if match.doubles() {
                    cell.doublesCell(team: "Blue", match: match, tournament: Model.sharedInstance.getTournament(), front9: front9, scoreSelected: scoreSelected )
                }
                else {
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9, scoreSelected: scoreSelected, oppPlayer: match.redTeamPlayerOne())
                }
            }
            else if indexPath.row == 4 {
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: front9, scoreSelected: scoreSelected, oppPlayer: match.redTeamPlayerTwo()!)
                }
                else if match.doubles() {
                    cell.doublesCell(team: "Red", match: match, tournament: Model.sharedInstance.getTournament(), front9: front9, scoreSelected: scoreSelected)
                }
                else {
                    //SINGLES MATCH
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9, scoreSelected: scoreSelected, oppPlayer: match.blueTeamPlayerOne())
                }
            }
            else if indexPath.row == 5 {
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: front9, scoreSelected: scoreSelected, oppPlayer: match.blueTeamPlayerOne())
                }
                else if matchLength == 18 { //not best ball, only 18 hole matches apply
                    cell.setHoleNumber(front9: !front9)
                    cell.formatHoleHeader()
                }
            }
            else if indexPath.row == 6 {
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: front9, scoreSelected: scoreSelected, oppPlayer: match.blueTeamPlayerTwo()!)
                }
                else if matchLength == 18 { //not best ball, only 18 hole matches apply
                    cell.setHandicap(match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9)
                    cell.formatHoleHeader()
                }
            }
            else if indexPath.row == 7 {
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    cell.setHoleNumber(front9: !front9)
                    cell.formatHoleHeader()
                }
                else if matchLength == 18 { //not Best ball
                    cell.setParNumber(match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9)
                    cell.formatHoleHeader()
                }
            }
            else if indexPath.row == 8 { //Now only 18 hole rows
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    cell.setHandicap(match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9)
                    cell.formatHoleHeader()
                }
                else { //Par row
                    if match.getFormat() == "Singles" {
                        cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9, scoreSelected: scoreSelected, oppPlayer: match.redTeamPlayerOne())
                    }
                    else {
                        cell.doublesCell(team: "Blue", match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9, scoreSelected: scoreSelected )
                    }
                }
            }
            else if indexPath.row == 9 {
                if match.getFormat() == "Best Ball" || match.getFormat() == "Shamble" {
                    cell.setParNumber(match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9)
                    cell.formatHoleHeader()
                }
                else { //P1
                    if match.getFormat() == "Singles" {
                        cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9, scoreSelected: scoreSelected, oppPlayer: match.blueTeamPlayerOne())
                    }
                    else {
                        cell.doublesCell(team: "Red", match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9, scoreSelected: scoreSelected )
                    }
                    cell.formatBottomCell()
                }
            }
            else if indexPath.row == 10 { //Now only applicable for best ball
                cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9, scoreSelected: scoreSelected, oppPlayer: match.redTeamPlayerOne())
            }
            else if indexPath.row == 11 { //Now only applicable for best ball
                cell.playerBestBallOrSinglesCell(player: match.blueTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9, scoreSelected: scoreSelected, oppPlayer: match.redTeamPlayerTwo()!)
            }
            else if indexPath.row == 12 {
                cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerOne(), match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9, scoreSelected: scoreSelected, oppPlayer: match.blueTeamPlayerOne())
            }
            else if indexPath.row == 13 {
                cell.playerBestBallOrSinglesCell(player: match.redTeamPlayerTwo()!, match: match, tournament: Model.sharedInstance.getTournament(), front9: !front9, scoreSelected: scoreSelected, oppPlayer: match.blueTeamPlayerTwo()!)

                cell.formatBottomCell()
            }
                        
            return cell
        
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
