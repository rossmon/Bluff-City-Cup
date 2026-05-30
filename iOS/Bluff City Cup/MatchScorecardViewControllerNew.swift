//
//  MatchScorecardViewControllerNew.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 7/7/22.
//  Copyright © 2022 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

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

    // Win probability footer
    private var winProbChartHost: UIHostingController<ProbabilityChartView>?
    private weak var winProbBluePct: UILabel?
    private weak var winProbRedPct: UILabel?
    private weak var winProbTiePct: UILabel?
    private weak var winProbFooterWrapper: UIView?
    private let winProbFooterBaseHeight: CGFloat = 271
    
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
        configureTeamAvatars()
        
        // Title bar — match Scoreboard/ScoreEntry style
        scorecardTitleLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        scorecardTitleLabel.textColor = .white
        applyBCCPageHeaderSpacing(to: scorecardTitleLabel)

        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        backButton.setTitleColor(.white, for: .normal)

        // Info row below title bar
        roundMatchLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        roundMatchLabel.textColor = UIColorFromRGB(0x172033)
        formatCourseLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        formatCourseLabel.textColor = UIColorFromRGB(0x5A6272)

        scoreStatus.font = UIFont.systemFont(ofSize: 22, weight: .bold)

        // teamHeaderView background to match scoreboardSurfaceColor
        teamHeaderView.backgroundColor = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1.0)
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
                downloadImage(urlstr: "https://glizzyattheturn.app/bcc/" + t1p2name + ".png", imageView: self.team1Player2Pic, playerName: t1p2name)
            }
            if let retrievedImage = UserDefaults.standard.object(forKey: t2p2name) {
                self.team2Player2Pic.image = UIImage(data: (retrievedImage as! NSData) as Data)
                self.team2Player2Pic.isHidden = false
            }
            else {
                downloadImage(urlstr: "https://glizzyattheturn.app/bcc/" + t2p2name + ".png", imageView: self.team2Player2Pic, playerName: t2p2name)
            }
        }
        
        
        if let retrievedImage = UserDefaults.standard.object(forKey: t1p1name) {
            self.team1Player1Pic.image = UIImage(data: (retrievedImage as! NSData) as Data)
            self.team1Player1Pic.isHidden = false
        }
        else {
            downloadImage(urlstr: "https://glizzyattheturn.app/bcc/" + t1p1name + ".png", imageView: self.team1Player1Pic, playerName: t1p1name)
        }
        if let retrievedImage = UserDefaults.standard.object(forKey: t2p1name) {
            self.team2Player1Pic.image = UIImage(data: (retrievedImage as! NSData) as Data)
            self.team2Player1Pic.isHidden = false
        }
        else {
            downloadImage(urlstr: "https://glizzyattheturn.app/bcc/" + t2p1name + ".png", imageView: self.team2Player1Pic, playerName: t2p1name)
        }
        
       
        
        //End setting user images
        
        scorecardTable.delegate = self
        scorecardTable.dataSource = self
        scorecardTable.contentInsetAdjustmentBehavior = .never
        
        
        roundMatchLabel.text = String(
            format: "Round %d, Match %d (%.1f pts)",
            match.getRound(),
            match.getMatchNumber(),
            match.getPoints()
        )
        
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
        if match.getCurrentHole() == 10 && match.getMatchLength() == 9 && match.getStartingHole() == 1 {
            front9 = true
        }
        
        if front9 { sideShowing = .front9 }
        else { sideShowing = .back9 }
        
        
        
        
        //TESTING FOR PERFORMANCE OF MATCH PREDICTION
        /*
        var currentDateTime = Date()

        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none

        var timeString = formatter.string(from: currentDateTime)
        print("Current time: \(timeString)")
        
        
        print("Round: \(match.getRound())")
        print("Match: \(match.getMatchNumber())")
        
        var currentHole = Hole()
        
        if match.isCompleted() {
            currentHole = Model.sharedInstance.getTournament().getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole()-1)
        }
        else {
            currentHole = Model.sharedInstance.getTournament().getCourseWithName(name: match.getCourseName()).getHole(match.getCurrentHole())
        }
        
        var blueTeamHandicap: Int = 0
        var redTeamHandicap: Int = 0
        
        if match.singles() {
            blueTeamHandicap = match.getSinglesHandicaps().blueTeamHandicap
            redTeamHandicap = match.getSinglesHandicaps().redTeamHandicap
        }
        else {
            blueTeamHandicap = match.getTeamHandicap().blueTeamHandicap
            redTeamHandicap = match.getTeamHandicap().redTeamHandicap
        }
        
        print(match.getMatchOutcomeProbabilitiesPerHole(currentHole: currentHole,  blueTeamHandicap: blueTeamHandicap, redTeamHandicap: redTeamHandicap, matchLength: match.getMatchLength()))
        
        
        currentDateTime = Date()
        timeString = formatter.string(from: currentDateTime)
        print("Current time: \(timeString)")
         */
         
        /*var tableFrame = self.scorecardTable.frame
        tableFrame.size.height = tableHeight
        self.scorecardTable.frame = tableFrame
        self.scorecardTable.setNeedsDisplay()*/

        setupWinProbabilityFooter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        configureTeamAvatars()
        applyBCCPageHeaderSpacing(to: scorecardTitleLabel)
        updateWinProbabilityFooterHeight()
    }
    
    private func configureTeamAvatars() {
        configureAvatar(team1Player1Pic, color: UIColorFromRGB(0x0F296B))
        configureAvatar(team1Player2Pic, color: UIColorFromRGB(0x0F296B))
        configureAvatar(team2Player1Pic, color: UIColorFromRGB(0xB70A1C))
        configureAvatar(team2Player2Pic, color: UIColorFromRGB(0xB70A1C))
    }
    
    private func configureAvatar(_ imageView: UIImageView, color: UIColor) {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = min(imageView.bounds.width, imageView.bounds.height) / 2
        imageView.layer.borderWidth = 2.5
        imageView.layer.borderColor = color.cgColor
        imageView.backgroundColor = color.withAlphaComponent(0.10)
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
                self.configureTeamAvatars()
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
        updateWinProbabilityFooterHeight()
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
        
        //let matchLength = Model.sharedInstance.tournament.getMatchLength()
        let matchLength = match.getMatchLength()

        
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
        
        //let matchLength = Model.sharedInstance.tournament.getMatchLength()
        let matchLength = match.getMatchLength()

        
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
    
    // MARK: - Win Probability Footer

    private func setupWinProbabilityFooter() {
        let footerWrapper = UIView(frame: CGRect(x: 0, y: 0,
                                                 width: scorecardTable.bounds.width,
                                                 height: winProbFooterBaseHeight))
        footerWrapper.backgroundColor = .clear
        winProbFooterWrapper = footerWrapper

        // Card
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10
        cardView.layer.masksToBounds = true
        footerWrapper.addSubview(cardView)

        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Match Projections"
        titleLabel.font = UIFont.italicSystemFont(ofSize: 11)
        titleLabel.textColor = UIColorFromRGB(0x5A6272)
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)

        // Chart container
        let chartContainer = UIView()
        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.backgroundColor = .clear
        cardView.addSubview(chartContainer)

        // Separator
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColorFromRGB(0xE5E9F0)
        cardView.addSubview(separator)

        // Probability rows
        let (blueRowView, blueLabel) = makeProbRow(color: UIColorFromRGB(0x0F296B), teamCode: "BLUE")
        let (tieRowView,  tieLabel)  = makeProbRow(color: UIColorFromRGB(0x5A6272), teamCode: "TIE")
        let (redRowView,  redLabel)  = makeProbRow(color: UIColorFromRGB(0xB70A1C), teamCode: "RED")
        [blueRowView, tieRowView, redRowView].forEach { cardView.addSubview($0) }

        winProbBluePct = blueLabel
        winProbTiePct  = tieLabel
        winProbRedPct  = redLabel

        // Powered-by footer
        let poweredLabel = UILabel()
        poweredLabel.translatesAutoresizingMaskIntoConstraints = false
        poweredLabel.text = "POWERED BY MontyRatings AI"
        poweredLabel.font = UIFont.systemFont(ofSize: 8, weight: .regular)
        poweredLabel.textColor = UIColorFromRGB(0xA0A9BB)
        poweredLabel.textAlignment = .center
        cardView.addSubview(poweredLabel)

        NSLayoutConstraint.activate([
            // Card inside wrapper — match scorecard cell width (edge-to-edge)
            cardView.leadingAnchor.constraint(equalTo: footerWrapper.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: footerWrapper.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: footerWrapper.topAnchor, constant: 12),
            cardView.bottomAnchor.constraint(equalTo: footerWrapper.bottomAnchor),

            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 18),

            // Chart
            chartContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chartContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            chartContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            chartContainer.heightAnchor.constraint(equalToConstant: 130),

            // Separator
            separator.topAnchor.constraint(equalTo: chartContainer.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            // Blue row
            blueRowView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 7),
            blueRowView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            blueRowView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            blueRowView.heightAnchor.constraint(equalToConstant: 18),

            // Tie row
            tieRowView.topAnchor.constraint(equalTo: blueRowView.bottomAnchor, constant: 3),
            tieRowView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            tieRowView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            tieRowView.heightAnchor.constraint(equalToConstant: 18),

            // Red row
            redRowView.topAnchor.constraint(equalTo: tieRowView.bottomAnchor, constant: 3),
            redRowView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            redRowView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            redRowView.heightAnchor.constraint(equalToConstant: 18),

            // Powered-by
            poweredLabel.topAnchor.constraint(equalTo: redRowView.bottomAnchor, constant: 5),
            poweredLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            poweredLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            poweredLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
        ])

        // Embed the SwiftUI chart
        let chartHost = UIHostingController(rootView: ProbabilityChartView(data: [], maxHole: match?.getMatchLength() ?? 18))
        addChild(chartHost)
        chartHost.view.translatesAutoresizingMaskIntoConstraints = false
        chartHost.view.backgroundColor = .clear
        chartContainer.addSubview(chartHost.view)
        NSLayoutConstraint.activate([
            chartHost.view.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
            chartHost.view.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor),
            chartHost.view.topAnchor.constraint(equalTo: chartContainer.topAnchor),
            chartHost.view.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor),
        ])
        chartHost.didMove(toParent: self)
        winProbChartHost = chartHost

        scorecardTable.tableFooterView = footerWrapper
        updateWinProbabilityFooterHeight()
        updateWinProbabilityFooter()
    }

    private func updateWinProbabilityFooterHeight() {
        guard let footerWrapper = winProbFooterWrapper,
              let currentFooter = scorecardTable.tableFooterView,
              currentFooter === footerWrapper else { return }

        let desiredHeight = winProbFooterBaseHeight

        guard abs(footerWrapper.frame.height - desiredHeight) > 1 else { return }

        var frame = footerWrapper.frame
        frame.size.width = scorecardTable.bounds.width
        frame.size.height = desiredHeight
        footerWrapper.frame = frame
        scorecardTable.tableFooterView = footerWrapper
    }

    /// Creates a single probability row: colored dot · team code · right-aligned percentage.
    private func makeProbRow(color: UIColor, teamCode: String) -> (UIView, UILabel) {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4
        row.addSubview(dot)

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = teamCode
        nameLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        nameLabel.textColor = color
        row.addSubview(nameLabel)

        let pctLabel = UILabel()
        pctLabel.translatesAutoresizingMaskIntoConstraints = false
        pctLabel.text = "–"
        pctLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        pctLabel.textColor = color
        pctLabel.textAlignment = .right
        row.addSubview(pctLabel)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),

            nameLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 5),
            nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            pctLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            pctLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        return (row, pctLabel)
    }

    private func updateWinProbabilityFooter() {
        guard let match = match else { return }

        var blueHoleProbabilities = [PredictionPerHole]()
        var redHoleProbabilities  = [PredictionPerHole]()
        var tieHoleProbabilities  = [PredictionPerHole]()

        let status        = match.getMatchCompletionDetails()
        let probabilities = Model.sharedInstance.tournament.getMatchWinProbabilities(
            forFormat: match.getFormat(),
            matchLength: match.getMatchLength(),
            startingHole: match.getStartingHole(),
            scoreDiffs: status.scoreDiffs)

        for each in probabilities {
            let isCurrent = each.hole == match.getCurrentHole()
            let isFinished = each.hole == status.lastHoleCompleted && status.matchFinished

            if isCurrent || isFinished {
                if isFinished {
                    let blueWins = status.matchWinner == "Blue"
                    let redWins  = status.matchWinner == "Red"
                    winProbBluePct?.text = blueWins ? "100.0%" : "0.0%"
                    winProbRedPct?.text  = redWins  ? "100.0%" : "0.0%"
                    winProbTiePct?.text  = (!blueWins && !redWins) ? "100.0%" : "0.0%"
                } else {
                    winProbBluePct?.text = "\(round(10 * 100 * each.blueWinProbability) / 10.0)%"
                    winProbRedPct?.text  = "\(round(10 * 100 * each.redWinProbability)  / 10.0)%"
                    winProbTiePct?.text  = "\(round(10 * 100 * each.tieProbability)     / 10.0)%"
                }
            }

            let displayHole = each.hole - match.getStartingHole() + 1
            blueHoleProbabilities.append(PredictionPerHole(hole: displayHole, probability: round(10 * 100 * each.blueWinProbability) / 10.0))
            redHoleProbabilities.append( PredictionPerHole(hole: displayHole, probability: round(10 * 100 * each.redWinProbability)  / 10.0))
            tieHoleProbabilities.append( PredictionPerHole(hole: displayHole, probability: round(10 * 100 * each.tieProbability)     / 10.0))
        }

        // Extend chart to 100% when match finishes before last hole
        if status.matchFinished && status.lastHoleCompleted < match.getMatchLength() {
            let nextHole = status.lastHoleCompleted - match.getStartingHole() + 2
            let blueWins = status.matchWinner == "Blue"
            let redWins  = status.matchWinner == "Red"
            blueHoleProbabilities.append(PredictionPerHole(hole: nextHole, probability: blueWins ? 100.0 : 0.0))
            redHoleProbabilities.append( PredictionPerHole(hole: nextHole, probability: redWins  ? 100.0 : 0.0))
            tieHoleProbabilities.append( PredictionPerHole(hole: nextHole, probability: (!blueWins && !redWins) ? 100.0 : 0.0))
        }

        let chartData = [
            MatchPredictionData(team: "Blue", probabilities: blueHoleProbabilities),
            MatchPredictionData(team: "Red",  probabilities: redHoleProbabilities),
            MatchPredictionData(team: "Tie",  probabilities: tieHoleProbabilities),
        ]
        winProbChartHost?.rootView = ProbabilityChartView(data: chartData, maxHole: match.getMatchLength())
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
