//
//  ContainerViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/13/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import CloudKit

enum SlideOutState {
    case topPanelExpanded
    case topPanelCollapsed
}

enum CurrentView {
    case scoreEntry
    case scoreboard
    case drinkCart
    case holeMap
    case settings
    case commishSettings
    case user
    case scorecard
    case container
    case matchScorecard
}

class ContainerViewController: UIViewController {
    
    //For Testing:
    var matches: [Match]!
    var players: [Player] = []
    let user: User  = User.sharedInstance
    var currentMatch: Match!
    var course: Course!
    var tournament: Tournament!
    
    let model: Model = Model.sharedInstance
    
    let actInd = UIActivityIndicatorView()
    var scorecardShowing: Bool!
    var matchScorecardShowing: Bool!
    //End Testing Variables
    
    var scoreEntryViewController: ScoreEntryViewController!
    var scoreboardViewController: ScoreboardViewController!
    //var scorecardViewController: ScorecardViewController!
    var matchScorecardViewController: MatchScorecardViewControllerNew!
    var drinkCartViewController: DrinkCartViewController!
    var holeMapViewController: HoleMapViewController!
    var settingsViewController: SettingsViewController!
    var commishSettingsViewController: CommishSettingsViewController!
    var navCommishController: UINavigationController!
    var topPanelViewController: TopPanelViewController?
    
    var userViewController: ViewController!

    
    var currentState: SlideOutState = .topPanelCollapsed {
        didSet {
            let shouldShowShadow = currentState != .topPanelCollapsed
            if currentView == .scoreEntry {
                showShadowForScoreEntryViewController(shouldShowShadow)
            }
            else if currentView == .scoreboard {
                showShadowForScoreboardViewController(shouldShowShadow)
            }
            else if currentView == .drinkCart {
                showShadowForDrinkCartViewController(shouldShowShadow)
            }
            else if currentView == .holeMap {
                showShadowForHoleMapViewController(shouldShowShadow)
            }
            else if currentView == .settings {
                showShadowForSettingsViewController(shouldShowShadow)
            }
            else if currentView == .commishSettings {
                showShadowForCommishSettingsViewController(shouldShowShadow)
            }
        }
    }
    
    var currentView: CurrentView = .scoreboard

    
    var scoreEntryPanelExpandedOffset: CGFloat =  200
    var scoreboardPanelExpandedOffset: CGFloat =  200
    var drinkCartPanelExpandedOffset: CGFloat =  200
    var holeMapPanelExpandedOffset: CGFloat =  200
    var settingsPanelExpandedOffset: CGFloat =  200
    var commishSettingsPanelExpandedOffset: CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UIApplication.shared.statusBarStyle = .lightContent
        
        currentView = .container
        
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        
        currentView = .scoreboard
        scorecardShowing = false
        
        self.view.backgroundColor = UIColorFromRGB(0x0F296B)
        
        actInd.style = UIActivityIndicatorView.Style.whiteLarge
        actInd.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(actInd)
        actInd.startAnimating()
        
        setupApp()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupApp() {
        let defaults = UserDefaults.standard
        
        //set to nil for testing
        //let userName: String? = nil
        
        let userName = defaults.object(forKey: "UserName") as? String
        let tournamentName = defaults.object(forKey: "TournamentName") as? String
        let userRole = defaults.object(forKey: "UserRole") as? String
        let scorekeeper = defaults.object(forKey: "Scorekeeper") as? Bool
        
        if userName != nil && tournamentName != nil && userRole != nil  && scorekeeper != nil && userName != "" && userName != " " {
            
            model.checkPlayerInCurrentMatch(userName!, tounamentName: tournamentName!)
            { found in
                
                self.user.setUser(name: userName!, role: userRole!, scorekeeper: scorekeeper!, isInMatch: found)
                self.loadData(tournamentName: tournamentName!) {}
            }
            
        }
        else {
            self.userViewController = UIStoryboard.userViewController()
            self.userViewController.delegate = self
            
            self.view.addSubview(self.userViewController.view)
            //self.userViewController.view.backgroundColor = UIColor.green

            self.currentView = .user
        }
    }
    
    
    func loadData(tournamentName: String, _ completion: @escaping () -> Void)  {
        model.loadData(tournamentName: tournamentName) { errorString in
            
            if errorString == "No Error" {
                print("Completed")
                //Prepare testing data
                
                self.prepareTestingData()
                
                DispatchQueue.main.sync {
                    if self.scoreboardViewController == nil {
                        self.scoreboardViewController = UIStoryboard.scoreboardViewController()
                        self.scoreboardViewController.delegate = self
                        
                        self.scoreboardViewController.user = self.user
                        //scoreboardViewController.matches = self.matches
                        self.scoreboardViewController.tournament = self.model.getTournament()
                        
                        
                        self.view.addSubview(self.scoreboardViewController.view)
                        print("Done Scoreboard Add View")
                        
                        self.actInd.stopAnimating()
                    }
                    
                    
                }
                
                self.currentView = .scoreboard
            }
            else {
                self.dataPullAlert(errorString)
            }
            
            completion()
            
        }
    }
    
    func dataPullAlert(_ errorDesc: String) {
        let alertController = UIAlertController(title: nil, message: errorDesc, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            
            self.viewDidLoad()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func prepareTestingData() {
        
        //Player and team setup
        players = model.getPlayers()
        
        for player in players {
            if player.getName() == self.user.getName() {
                self.user.player = player
            }
        }
        
        course = model.getCourse()

        matches = model.getMatches()
        
        for match in matches {
            if match.blueTeamPlayerOne().getName() == self.user.getName() ||
                match.blueTeamPlayerTwo()?.getName() == self.user.getName() ||
                match.redTeamPlayerOne().getName() == self.user.getName() ||
                match.redTeamPlayerTwo()?.getName() == self.user.getName() {
                    currentMatch = match
                    break
            }
        }
    
        tournament = model.getTournament()
        print("Done Preparing")
    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            
            
        } else {
            print("Portrait")
        }
    }
    
    override var shouldAutorotate: Bool {
        return false;
        /*
        if (currentView == .scorecard && !scorecardShowing) || currentView == .container || (currentView == .matchScorecard && !scorecardShowing){
            return true
        }
        else {
            return false
        }*/
    }
    
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    
    class func topPanelViewController() -> TopPanelViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "TopPanelViewController") as? TopPanelViewController
    }
    class func scoreEntryViewController() -> ScoreEntryViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ScoreEntryViewController") as? ScoreEntryViewController
    }
    /*
    class func scorecardViewController() -> ScorecardViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ScorecardViewController") as? ScorecardViewController
    }
    
    class func matchScorecardViewController() -> MatchScorecardViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MatchScorecardViewController") as? MatchScorecardViewController
    }*/
    class func matchScorecardViewControllerNew() -> MatchScorecardViewControllerNew? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MatchScorecardViewControllerNew") as? MatchScorecardViewControllerNew
    }
     
    class func scoreboardViewController() -> ScoreboardViewController? {
        print("Created Scoreboard View")
        return mainStoryboard().instantiateViewController(withIdentifier: "ScoreboardViewController") as? ScoreboardViewController
    }
    class func drinkCartViewController() -> DrinkCartViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "DrinkCartViewController") as? DrinkCartViewController
    }
    class func holeMapViewController() -> HoleMapViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "HoleMapViewController") as? HoleMapViewController
    }
    class func settingsViewController() -> SettingsViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
    }
    class func commishSettingsViewController() -> CommishSettingsViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "CommishSettingsViewController") as? CommishSettingsViewController
    }
    class func userViewController() -> ViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "UserViewController") as?ViewController
    }
    
    
}

// MARK: - ModelDelegate
extension ContainerViewController: ModelDelegate {
    
    func modelUpdated() {
        //refreshControl?.endRefreshing()
        //tableView.reloadData()
    }
    
    func errorUpdating(_ error: NSError) {
        let message: String
        if error.code == 1 {
            message = "Log into iCloud on your device and make sure the iCloud drive is turned on for this app."
        } else {
            message = error.localizedDescription
        }
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension ContainerViewController: ViewControllerDelegate {
    
    func loggedIn(tournamentName: String) {
        
        
        loadData(tournamentName: tournamentName) {
            //self.userViewController.stopActivity()
            DispatchQueue.main.async {
                if self.userViewController != nil {
                
                    self.userViewController!.view.removeFromSuperview()
                    self.userViewController = nil
                }
            }
        
        }
 
    }
}


extension ContainerViewController: ScoreboardViewControllerDelegate {
    
    func toggleTopPanelScoreboard() {
        let notAlreadyExpanded = (currentState != .topPanelExpanded)
        
        if notAlreadyExpanded {
            addTopPanelViewControllerScoreboard()
        }
        
        animateTopPanelScoreboard(notAlreadyExpanded)
    }
    
    func addChildTopPanelControllerScoreboard(_ topPanelController: TopPanelViewController) {
        topPanelController.delegate = scoreboardViewController
        
        topPanelController.user = self.user
        if user.getRole() == "Commissioner" {
            if tournament.isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings","Commish Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings","Commish Settings"]
            }
            
            if !user.isScorekeeper()
            {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Score Entry" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Spectator" {
            if tournament.isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Settings"]
            }
            
        }
        else if user.getRole() == "Player" {
            if tournament.isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Scorekeeper" {
            if tournament.isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else {
            topPanelController.menuItems = [String]()
        }
        
        
        
        if model.getTournament().getMatches().count == 0 {
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Score Entry" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Scorecard" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Hole Map" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Drink Cart" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
        }
        
        view.insertSubview(topPanelController.view, at: 0)
        
        addChild(topPanelController)
        
        
        topPanelController.didMove(toParent: self)
    }
    
    func addTopPanelViewControllerScoreboard() {
        if (topPanelViewController == nil) {
            topPanelViewController = UIStoryboard.topPanelViewController()
            addChildTopPanelControllerScoreboard(topPanelViewController!)
        }
    }
    
    func animateTopPanelScoreboard(_ shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .topPanelExpanded
            
            animateScoreboardPanelXPositionScoreboard(/*CGRectGetHeight(tempViewController.view.frame)*/ scoreboardPanelExpandedOffset)
            
        } else {
            animateScoreboardPanelXPositionScoreboard(0) { _ in
                self.currentState = .topPanelCollapsed
                
                if self.topPanelViewController != nil {
                    self.topPanelViewController!.view.removeFromSuperview()
                    self.topPanelViewController = nil
                }
                
            }
        }
    }
    
    func animateScoreboardPanelXPositionScoreboard(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.scoreboardViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateScoreboardPanelYPositionScoreboard(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.scoreboardViewController.view.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
    func showShadowForScoreboardViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            scoreboardViewController.view.layer.shadowOpacity = 1.0
        } else {
            scoreboardViewController.view.layer.shadowOpacity = 0.0
        }
    }
    
    
    func collapseTopPanelScoreboard() {
        switch (currentState) {
        case .topPanelExpanded:
            toggleTopPanelScoreboard()
        default:
            break
        }
    }
    
    func changeViewScoreboard(_ menu: String, scorecardMatch: Match?) {
        
        if menu == "Score Entry" {
            if currentView != .scoreEntry {
                scoreEntryViewController = UIStoryboard.scoreEntryViewController()
                scoreEntryViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                scoreEntryViewController.user = self.user
                scoreEntryViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                scoreEntryViewController.tournament = self.model.getTournament()
                if (scoreEntryViewController.match.getStartingHole() == 1 && tournament.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = tournament.getMatchLength()
                }
                else if scoreEntryViewController.match.getCurrentHole() > 18 {
                    scoreEntryViewController.viewingHoleNumber = 18
                }
                else {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getCurrentHole()
                }
                
                view.addSubview(scoreEntryViewController.view)
                
                
                
                currentView = .scoreEntry
            }
        }
        else if menu == "Scoreboard" {
            if currentView != .scoreboard {
                scoreboardViewController = UIStoryboard.scoreboardViewController()
                scoreboardViewController.delegate = self
                
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                scoreboardViewController.user = self.user
                //scoreboardViewController.matches = self.matches
                scoreboardViewController.tournament = self.model.getTournament()
                
                view.addSubview(scoreboardViewController.view)
                
                currentView = .scoreboard
            }
        }
        else if menu == "Scorecard" {
            if currentView != .matchScorecard {
                matchScorecardViewController = UIStoryboard.matchScorecardViewControllerNew()
                matchScorecardViewController.delegate = self
                
                if scorecardMatch != nil {
                    matchScorecardViewController.match = scorecardMatch
                }
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                currentView = .matchScorecard
                
                scorecardShowing = false
                
                if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    print("Landscape Left")
                }
                else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                    print("Landscape Right")
                }
                else {
                    print("Portrait")
                }
                
                if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
                }
                else {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
                }
                
                ContainerViewController.attemptRotationToDeviceOrientation()
                
                scorecardShowing = true
                
                view.addSubview(matchScorecardViewController.view)
                
            }
        }
        else if menu == "Drink Cart" {
            if currentView != .drinkCart {
                drinkCartViewController = UIStoryboard.drinkCartViewController()
                drinkCartViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                drinkCartViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                
                view.addSubview(drinkCartViewController.view)
                
                currentView = .drinkCart
            }
        }
        else if menu == "Hole Map" {
            if currentView != .holeMap {
                holeMapViewController = UIStoryboard.holeMapViewController()
                holeMapViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                holeMapViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                holeMapViewController.tournament = self.model.getTournament()
                
                view.addSubview(holeMapViewController.view)
                
                currentView = .holeMap
            }
        }
        else if menu == "Settings" {
            if currentView != .settings {
                settingsViewController = UIStoryboard.settingsViewController()
                settingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                settingsViewController.user = self.user
                settingsViewController.tournament = self.model.getTournament()
                
                view.addSubview(settingsViewController.view)
                
                currentView = .settings
            }
        }
        else if menu == "Commish Settings" {
            if currentView != .commishSettings {
                commishSettingsViewController = UIStoryboard.commishSettingsViewController()
                commishSettingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                commishSettingsViewController.user = self.user
                commishSettingsViewController.tournament = self.model.getTournament()
            
                navCommishController = UINavigationController(rootViewController: commishSettingsViewController) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.addChild(navCommishController)
                view.addSubview(navCommishController.view)
                
                currentView = .commishSettings
            }
        }
        
    }
    
    
}


extension ContainerViewController: ScoreEntryViewControllerDelegate {
    
    func updateTournament(_ newTournament: Tournament) {
        self.tournament = newTournament
        self.model.setTournament(newTournament)
    }
    
    func toggleTopPanelScoreEntry()
    {
        let notAlreadyExpanded = (currentState != .topPanelExpanded)
        
        if notAlreadyExpanded {
            addTopPanelViewControllerScoreEntry()
        }
        
        animateTopPanelScoreEntry(notAlreadyExpanded)
    }
    
    func addChildTopPanelControllerScoreEntry(_ topPanelController: TopPanelViewController)
    {
        topPanelController.delegate = scoreEntryViewController
        
        topPanelController.user = self.user
        if user.getRole() == "Commissioner" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings","Commish Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings","Commish Settings"]
            }
            
            if !user.isScorekeeper()
            {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Score Entry" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Spectator" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Settings"]
            }
            
        }
        else if user.getRole() == "Player" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Scorekeeper" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else {
            topPanelController.menuItems = [String]()
        }
        
        if tournament.getMatches().count == 0 {
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Score Entry" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Scorecard" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Hole Map" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Drink Cart" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
        }
        
        view.insertSubview(topPanelController.view, at: 0)
        
        addChild(topPanelController)
        topPanelController.didMove(toParent: self)
    }
    
    func addTopPanelViewControllerScoreEntry()
    {
        if (topPanelViewController == nil) {
            topPanelViewController = UIStoryboard.topPanelViewController()
            addChildTopPanelControllerScoreEntry(topPanelViewController!)
        }
    }
    
    func animateTopPanelScoreEntry(_ shouldExpand: Bool)
    {
        if (shouldExpand) {
            currentState = .topPanelExpanded
            
            animateScoreEntryPanelXPositionScoreEntry(/*CGRectGetHeight(tempViewController.view.frame)*/ scoreEntryPanelExpandedOffset)
            
        } else {
            animateScoreEntryPanelXPositionScoreEntry(0) { _ in
                self.currentState = .topPanelCollapsed
                
                if self.topPanelViewController != nil {
                    self.topPanelViewController!.view.removeFromSuperview()
                    self.topPanelViewController = nil
                }
                
            }
        }
    }
    
    func animateScoreEntryPanelXPositionScoreEntry(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil)
    {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.scoreEntryViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateScoreEntryPanelYPositionScoreEntry(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil)
    {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.scoreEntryViewController.view.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
    func showShadowForScoreEntryViewController(_ shouldShowShadow: Bool)
    {
        if (shouldShowShadow) {
            scoreEntryViewController.view.layer.shadowOpacity = 1.0
        } else {
            scoreEntryViewController.view.layer.shadowOpacity = 0.0
        }
    }
    
    
    func collapseTopPanelScoreEntry()
    {
        switch (currentState) {
        case .topPanelExpanded:
            toggleTopPanelScoreEntry()
        default:
            break
        }
    }
    
    func changeViewScoreEntry(_ menu: String)
    {
        
        if menu == "Score Entry" {
            if currentView != .scoreEntry {
                scoreEntryViewController = UIStoryboard.scoreEntryViewController()
                scoreEntryViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                scoreEntryViewController.user = self.user
                scoreEntryViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                scoreEntryViewController.tournament = self.model.getTournament()
                if (scoreEntryViewController.match.getStartingHole() == 1 && tournament.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = tournament.getMatchLength()
                }
                else if scoreEntryViewController.match.getCurrentHole() > 18 {
                    scoreEntryViewController.viewingHoleNumber = 18
                }
                else {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getCurrentHole()
                }
                
                view.addSubview(scoreEntryViewController.view)
                
                currentView = .scoreEntry
            }
        }
        else if menu == "Scoreboard" {
            if currentView != .scoreboard {
                scoreboardViewController = UIStoryboard.scoreboardViewController()
                scoreboardViewController.delegate = self
                
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                //scoreboardViewController.matches = self.matches
                scoreboardViewController.user = self.user
                scoreboardViewController.tournament = self.model.getTournament()
                
                view.addSubview(scoreboardViewController.view)
                
                currentView = .scoreboard
            }
        }
        else if menu == "Scorecard" {
            if currentView != .matchScorecard {
                matchScorecardViewController = UIStoryboard.matchScorecardViewControllerNew()
                matchScorecardViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                currentView = .matchScorecard
                
                scorecardShowing = false
                
                if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    print("Landscape Left")
                }
                else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                    print("Landscape Right")
                }
                else {
                    print("Portrait")
                }
                
                if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
                }
                else {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
                }
                
                ContainerViewController.attemptRotationToDeviceOrientation()
                
                scorecardShowing = true
                
                view.addSubview(matchScorecardViewController.view)
                
            }
        }
        else if menu == "Drink Cart" {
            if currentView != .drinkCart {
                drinkCartViewController = UIStoryboard.drinkCartViewController()
                drinkCartViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                drinkCartViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                
                view.addSubview(drinkCartViewController.view)
                
                currentView = .drinkCart
            }
        }
        else if menu == "Hole Map" {
            if currentView != .holeMap {
                holeMapViewController = UIStoryboard.holeMapViewController()
                holeMapViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                holeMapViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                holeMapViewController.tournament = self.model.getTournament()
                
                view.addSubview(holeMapViewController.view)
                
                currentView = .holeMap
            }
        }
        else if menu == "Settings" {
            if currentView != .settings {
                settingsViewController = UIStoryboard.settingsViewController()
                settingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                settingsViewController.user = self.user
                
                view.addSubview(settingsViewController.view)
                
                currentView = .settings
            }
        }
        else if menu == "Commish Settings" {
            if currentView != .commishSettings {
                commishSettingsViewController = UIStoryboard.commishSettingsViewController()
                //commishSettingsViewController.delegate = self
                
                commishSettingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                commishSettingsViewController.user = self.user
                commishSettingsViewController.tournament = self.model.getTournament()
                
                navCommishController = UINavigationController(rootViewController: commishSettingsViewController) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.addChild(navCommishController)
                view.addSubview(navCommishController.view)
                
                currentView = .commishSettings
            }
        }
    }
    
    /*
    func showScorecard() {
        
        if currentView == .scoreEntry {
            scorecardViewController = UIStoryboard.scorecardViewController()
            scorecardViewController.match = scoreEntryViewController.match
            scorecardViewController.delegate = self
            currentView = .scorecard
            
            scorecardShowing = false
            
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                print("Landscape Left")
            }
            else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                print("Landscape Right")
            }
            else {
                print("Portrait")
            }

            if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
            }
            else {
                UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
            }
            
            ContainerViewController.attemptRotationToDeviceOrientation()
            
            scorecardShowing = true
            view.addSubview(scorecardViewController.view)
            
        }
    }
 */
}

/*
extension ContainerViewController: ScorecardViewControllerDelegate {
    
    
    func closeScorecard() {
        DispatchQueue.main.async {
            if self.currentView == .scorecard {
                if self.scorecardViewController != nil {
                    self.scorecardViewController!.view.removeFromSuperview()
                    self.scorecardViewController = nil
                    
                    self.scorecardShowing = false
                    
                    if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                        print("Close Landscape Left")
                    }
                    else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                        print("Close Landscape Right")
                    }
                    else {
                        print("Close Portrait")
                    }
                    
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
                    
                    ContainerViewController.attemptRotationToDeviceOrientation()
                    
                    self.currentView = .scoreEntry
                }
            }
        }
    }
 
}
 */

extension ContainerViewController: MatchScorecardViewControllerDelegateNew {
    func closeMatchScorecard() {
        DispatchQueue.main.async {
            if self.currentView == .matchScorecard {
                if self.matchScorecardViewController != nil {
                    self.matchScorecardViewController!.view.removeFromSuperview()
                    self.matchScorecardViewController = nil
                    
                    self.scorecardShowing = false
                    
                    if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                        print("Close Landscape Left")
                    }
                    else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                        print("Close Landscape Right")
                    }
                    else {
                        print("Close Portrait")
                    }
                    
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
                    
                    ContainerViewController.attemptRotationToDeviceOrientation()
                    
                    self.scoreboardViewController = UIStoryboard.scoreboardViewController()
                    self.scoreboardViewController.delegate = self
                    
                    self.scoreboardViewController.user = self.user
                    self.scoreboardViewController.tournament = self.model.getTournament()
                    
                    self.view.addSubview(self.scoreboardViewController.view)
                    
                    self.currentView = .scoreboard
                }
            }
        }
    }
}


extension ContainerViewController: DrinkCartViewControllerDelegate {
    
    func toggleTopPanelDrinkCart() {
        let notAlreadyExpanded = (currentState != .topPanelExpanded)
        
        if notAlreadyExpanded {
            addTopPanelViewControllerDrinkCart()
        }
        
        animateTopPanelDrinkCart(notAlreadyExpanded)
    }
    
    func addChildTopPanelControllerDrinkCart(_ topPanelController: TopPanelViewController) {
        topPanelController.delegate = drinkCartViewController
        
        topPanelController.user = self.user
        if user.getRole() == "Commissioner" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings","Commish Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings","Commish Settings"]
            }
            
            if !user.isScorekeeper()
            {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Score Entry" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Spectator" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Settings"]
            }
            
        }
        else if user.getRole() == "Player" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Scorekeeper" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else {
            topPanelController.menuItems = [String]()
        }
        
        if model.getTournament().getMatches().count == 0 {
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Score Entry" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Scorecard" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Hole Map" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Drink Cart" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
        }
        
        view.insertSubview(topPanelController.view, at: 0)
        
        addChild(topPanelController)
        topPanelController.didMove(toParent: self)
    }
    
    func addTopPanelViewControllerDrinkCart() {
        if (topPanelViewController == nil) {
            topPanelViewController = UIStoryboard.topPanelViewController()
            addChildTopPanelControllerDrinkCart(topPanelViewController!)
        }
    }
    
    func animateTopPanelDrinkCart(_ shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .topPanelExpanded
            
            animateDrinkCartPanelXPositionDrinkCart(/*CGRectGetHeight(tempViewController.view.frame)*/ drinkCartPanelExpandedOffset)
            
        } else {
            animateDrinkCartPanelXPositionDrinkCart(0) { _ in
                self.currentState = .topPanelCollapsed
                
                if self.topPanelViewController != nil {
                    self.topPanelViewController!.view.removeFromSuperview()
                    self.topPanelViewController = nil
                }
                
            }
        }
    }
    
    func animateDrinkCartPanelXPositionDrinkCart(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.drinkCartViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateDrinkCartPanelYPositionDrinkCart(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.drinkCartViewController.view.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
    func showShadowForDrinkCartViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            drinkCartViewController.view.layer.shadowOpacity = 1.0
        } else {
            drinkCartViewController.view.layer.shadowOpacity = 0.0
        }
    }
    
    
    func collapseTopPanelDrinkCart() {
        switch (currentState) {
        case .topPanelExpanded:
            toggleTopPanelDrinkCart()
        default:
            break
        }
    }
    
    func changeViewDrinkCart(_ menu: String) {
        
        if menu == "Score Entry" {
            if currentView != .scoreEntry {
                scoreEntryViewController = UIStoryboard.scoreEntryViewController()
                scoreEntryViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                scoreEntryViewController.user = self.user
                scoreEntryViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                scoreEntryViewController.tournament = self.model.getTournament()
                if (scoreEntryViewController.match.getStartingHole() == 1 && tournament.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = tournament.getMatchLength()
                }
                else if scoreEntryViewController.match.getCurrentHole() > 18 {
                    scoreEntryViewController.viewingHoleNumber = 18
                }
                else {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getCurrentHole()
                }
                                
                view.addSubview(scoreEntryViewController.view)
                
                currentView = .scoreEntry
            }
        }
        else if menu == "Scoreboard" {
            if currentView != .scoreboard {
                scoreboardViewController = UIStoryboard.scoreboardViewController()
                scoreboardViewController.delegate = self
                
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                scoreboardViewController.user = self.user
                //scoreboardViewController.matches = self.matches
                scoreboardViewController.tournament = self.model.getTournament()
                
                view.addSubview(scoreboardViewController.view)
                
                currentView = .scoreboard
            }
        }
        else if menu == "Scorecard" {
            if currentView != .matchScorecard {
                matchScorecardViewController = UIStoryboard.matchScorecardViewControllerNew()
                matchScorecardViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                currentView = .matchScorecard
                
                scorecardShowing = false
                
                if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    print("Landscape Left")
                }
                else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                    print("Landscape Right")
                }
                else {
                    print("Portrait")
                }
                
                if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
                }
                else {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
                }
                
                ContainerViewController.attemptRotationToDeviceOrientation()
                
                scorecardShowing = true
                
                view.addSubview(matchScorecardViewController.view)
                
            }
        }
        else if menu == "Drink Cart" {
            if currentView != .drinkCart {
                drinkCartViewController = UIStoryboard.drinkCartViewController()
                drinkCartViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                drinkCartViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                
                view.addSubview(drinkCartViewController.view)
                
                currentView = .drinkCart
            }
        }
        else if menu == "Hole Map" {
            if currentView != .holeMap {
                holeMapViewController = UIStoryboard.holeMapViewController()
                holeMapViewController.delegate = self
                
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                holeMapViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                holeMapViewController.tournament = self.model.getTournament()
                view.addSubview(holeMapViewController.view)
                
                currentView = .holeMap
            }
        }
        else if menu == "Settings" {
            if currentView != .settings {
                settingsViewController = UIStoryboard.settingsViewController()
                settingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                settingsViewController.user = self.user
                
                view.addSubview(settingsViewController.view)
                
                currentView = .settings
            }
        }
        else if menu == "Commish Settings" {
            if currentView != .commishSettings {
                commishSettingsViewController = UIStoryboard.commishSettingsViewController()
                //commishSettingsViewController.delegate = self
                
                commishSettingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                commishSettingsViewController.user = self.user
                commishSettingsViewController.tournament = self.model.getTournament()
                
                navCommishController = UINavigationController(rootViewController: commishSettingsViewController) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.addChild(navCommishController)
                view.addSubview(navCommishController.view)
                
                currentView = .commishSettings
            }
        }
    }
}

extension ContainerViewController: HoleMapViewControllerDelegate {
    
    func toggleTopPanelHoleMap() {
        let notAlreadyExpanded = (currentState != .topPanelExpanded)
        
        if notAlreadyExpanded {
            addTopPanelViewControllerHoleMap()
        }
        
        animateTopPanelHoleMap(notAlreadyExpanded)
    }
    
    func addChildTopPanelControllerHoleMap(_ topPanelController: TopPanelViewController) {
        topPanelController.delegate = holeMapViewController
        
        topPanelController.user = self.user
        if user.getRole() == "Commissioner" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings","Commish Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings","Commish Settings"]
            }
            
            if !user.isScorekeeper()
            {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Score Entry" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Spectator" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Settings"]
            }
            
        }
        else if user.getRole() == "Player" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Scorekeeper" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else {
            topPanelController.menuItems = [String]()
        }
        
        if model.getTournament().getMatches().count == 0 {
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Score Entry" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Scorecard" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Hole Map" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Drink Cart" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
        }
        
        view.insertSubview(topPanelController.view, at: 0)
        
        addChild(topPanelController)
        
        topPanelController.didMove(toParent: self)
    }
    
    func addTopPanelViewControllerHoleMap() {
        if (topPanelViewController == nil) {
            topPanelViewController = UIStoryboard.topPanelViewController()
            addChildTopPanelControllerHoleMap(topPanelViewController!)
        }
    }
    
    func animateTopPanelHoleMap(_ shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .topPanelExpanded
            
            animateHoleMapPanelXPositionHoleMap(/*CGRectGetHeight(tempViewController.view.frame)*/ holeMapPanelExpandedOffset)
            
        } else {
            animateHoleMapPanelXPositionHoleMap(0) { _ in
                self.currentState = .topPanelCollapsed
                
                if self.topPanelViewController != nil {
                    self.topPanelViewController!.view.removeFromSuperview()
                    self.topPanelViewController = nil
                }
                
            }
        }
    }
    
    func animateHoleMapPanelXPositionHoleMap(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.holeMapViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateHoleMapPanelYPositionHoleMap(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.holeMapViewController.view.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
    func showShadowForHoleMapViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            holeMapViewController.view.layer.shadowOpacity = 1.0
        } else {
            holeMapViewController.view.layer.shadowOpacity = 0.0
        }
    }
    
    
    func collapseTopPanelHoleMap() {
        switch (currentState) {
        case .topPanelExpanded:
            toggleTopPanelHoleMap()
        default:
            break
        }
    }
    
    func changeViewHoleMap(_ menu: String) {
        
        if menu == "Score Entry" {
            if currentView != .scoreEntry {
                scoreEntryViewController = UIStoryboard.scoreEntryViewController()
                scoreEntryViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                scoreEntryViewController.user = self.user
                scoreEntryViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                scoreEntryViewController.tournament = self.model.getTournament()
                if (scoreEntryViewController.match.getStartingHole() == 1 && tournament.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = tournament.getMatchLength()
                }
                else if scoreEntryViewController.match.getCurrentHole() > 18 {
                    scoreEntryViewController.viewingHoleNumber = 18
                }
                else {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getCurrentHole()
                }
                
                view.addSubview(scoreEntryViewController.view)
                
                currentView = .scoreEntry
            }
        }
        else if menu == "Scoreboard" {
            if currentView != .scoreboard {
                scoreboardViewController = UIStoryboard.scoreboardViewController()
                scoreboardViewController.delegate = self
                
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                scoreboardViewController.user = self.user
                //scoreboardViewController.matches = self.matches
                scoreboardViewController.tournament = self.model.getTournament()
                
                view.addSubview(scoreboardViewController.view)
                
                currentView = .scoreboard
            }
        }
        else if menu == "Scorecard" {
            if currentView != .matchScorecard {
                matchScorecardViewController = UIStoryboard.matchScorecardViewControllerNew()
                matchScorecardViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                currentView = .matchScorecard
                
                scorecardShowing = false
                
                if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    print("Landscape Left")
                }
                else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                    print("Landscape Right")
                }
                else {
                    print("Portrait")
                }
                
                if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
                }
                else {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
                }
                
                ContainerViewController.attemptRotationToDeviceOrientation()
                
                scorecardShowing = true
                
                view.addSubview(matchScorecardViewController.view)
                
            }
        }
        else if menu == "Drink Cart" {
            if currentView != .drinkCart {
                drinkCartViewController = UIStoryboard.drinkCartViewController()
                drinkCartViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                drinkCartViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                
                view.addSubview(drinkCartViewController.view)
                
                currentView = .drinkCart
            }
        }
        else if menu == "Hole Map" {
            if currentView != .holeMap {
                holeMapViewController = UIStoryboard.holeMapViewController()
                holeMapViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                holeMapViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                holeMapViewController.tournament = self.model.getTournament()
                
                view.addSubview(holeMapViewController.view)
                
                currentView = .holeMap
            }
        }
        else if menu == "Settings" {
            if currentView != .settings {
                settingsViewController = UIStoryboard.settingsViewController()
                settingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                settingsViewController.user = self.user
                
                view.addSubview(settingsViewController.view)
                
                currentView = .settings
            }
        }
        else if menu == "Commish Settings" {
            if currentView != .commishSettings {
                commishSettingsViewController = UIStoryboard.commishSettingsViewController()
                //commishSettingsViewController.delegate = self
                
                commishSettingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                commishSettingsViewController.user = self.user
                commishSettingsViewController.tournament = self.model.getTournament()
                
                navCommishController = UINavigationController(rootViewController: commishSettingsViewController) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.addChild(navCommishController)
                view.addSubview(navCommishController.view)
                
                currentView = .commishSettings
            }
        }
    }
}

extension ContainerViewController: SettingsViewControllerDelegate {
    
    func changeTournament() {
        if settingsViewController != nil {
            self.settingsViewController!.view.removeFromSuperview()
            self.settingsViewController = nil
        }
        
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "TournamentName")
        defaults.set(nil, forKey: "UserName")
        
        self.setupApp()
    }
    
    func toggleTopPanelSettings() {
        let notAlreadyExpanded = (currentState != .topPanelExpanded)
        
        if notAlreadyExpanded {
            addTopPanelViewControllerSettings()
        }
        
        animateTopPanelSettings(notAlreadyExpanded)
    }
    
    func addChildTopPanelControllerSettings(_ topPanelController: TopPanelViewController) {
        topPanelController.delegate = settingsViewController
        
        topPanelController.user = self.user
        if user.getRole() == "Commissioner" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings","Commish Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings","Commish Settings"]
            }
            
            if !user.isScorekeeper()
            {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Score Entry" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Spectator" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Settings"]
            }
            
        }
        else if user.getRole() == "Player" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Scorekeeper" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else {
            topPanelController.menuItems = [String]()
        }
        
        if model.getTournament().getMatches().count == 0 {
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Score Entry" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Scorecard" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Hole Map" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Drink Cart" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
        }
        
        
        view.insertSubview(topPanelController.view, at: 0)
        
        addChild(topPanelController)
        topPanelController.didMove(toParent: self)
    }
    
    func addTopPanelViewControllerSettings() {
        if (topPanelViewController == nil) {
            topPanelViewController = UIStoryboard.topPanelViewController()
            addChildTopPanelControllerSettings(topPanelViewController!)
        }
    }
    
    func animateTopPanelSettings(_ shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .topPanelExpanded
            
            animateSettingsPanelXPositionSettings(/*CGRectGetHeight(tempViewController.view.frame)*/ settingsPanelExpandedOffset)
            
        } else {
            animateSettingsPanelXPositionSettings(0) { _ in
                self.currentState = .topPanelCollapsed
                
                if self.topPanelViewController != nil {
                    self.topPanelViewController!.view.removeFromSuperview()
                    self.topPanelViewController = nil
                }
                
            }
        }
    }
    
    func animateSettingsPanelXPositionSettings(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.settingsViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateSettingsPanelYPositionSettings(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.settingsViewController.view.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
    func showShadowForSettingsViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            settingsViewController.view.layer.shadowOpacity = 1.0
        } else {
            settingsViewController.view.layer.shadowOpacity = 0.0
        }
    }
    
    
    func collapseTopPanelSettings() {
        switch (currentState) {
        case .topPanelExpanded:
            toggleTopPanelSettings()
        default:
            break
        }
    }
    
    func changeViewSettings(_ menu: String) {
        
        if menu == "Score Entry" {
            if currentView != .scoreEntry {
                scoreEntryViewController = UIStoryboard.scoreEntryViewController()
                scoreEntryViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                scoreEntryViewController.user = self.user
                scoreEntryViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                scoreEntryViewController.tournament = self.model.getTournament()
                if (scoreEntryViewController.match.getStartingHole() == 1 && tournament.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = tournament.getMatchLength()
                }
                else if scoreEntryViewController.match.getCurrentHole() > 18 {
                    scoreEntryViewController.viewingHoleNumber = 18
                }
                else {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getCurrentHole()
                }
                
                view.addSubview(scoreEntryViewController.view)
                
                currentView = .scoreEntry
            }
        }
        else if menu == "Scoreboard" {
            if currentView != .scoreboard {
                scoreboardViewController = UIStoryboard.scoreboardViewController()
                scoreboardViewController.delegate = self
                
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                scoreboardViewController.user = self.user
                //scoreboardViewController.matches = self.matches
                scoreboardViewController.tournament = self.model.getTournament()
                
                view.addSubview(scoreboardViewController.view)
                
                currentView = .scoreboard
            }
        }
        else if menu == "Scorecard" {
            if currentView != .matchScorecard {
                matchScorecardViewController = UIStoryboard.matchScorecardViewControllerNew()
                matchScorecardViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                currentView = .matchScorecard
                
                scorecardShowing = false
                
                if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    print("Landscape Left")
                }
                else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                    print("Landscape Right")
                }
                else {
                    print("Portrait")
                }
                
                if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
                }
                else {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
                }
                
                ContainerViewController.attemptRotationToDeviceOrientation()
                
                scorecardShowing = true
                
                view.addSubview(matchScorecardViewController.view)
                
            }
        }
        else if menu == "Drink Cart" {
            if currentView != .drinkCart {
                drinkCartViewController = UIStoryboard.drinkCartViewController()
                drinkCartViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                drinkCartViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                
                view.addSubview(drinkCartViewController.view)
                
                currentView = .drinkCart
            }
        }
        else if menu == "Hole Map" {
            if currentView != .holeMap {
                holeMapViewController = UIStoryboard.holeMapViewController()
                holeMapViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                holeMapViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                holeMapViewController.tournament = self.model.getTournament()
                
                view.addSubview(holeMapViewController.view)
                
                currentView = .holeMap
            }
        }
        else if menu == "Settings" {
            if currentView != .settings {
                settingsViewController = UIStoryboard.settingsViewController()
                settingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                settingsViewController.user = self.user
                
                view.addSubview(settingsViewController.view)
                
                currentView = .settings
            }
        }
        else if menu == "Commish Settings" {
            if currentView != .commishSettings {
                commishSettingsViewController = UIStoryboard.commishSettingsViewController()
                //commishSettingsViewController.delegate = self
                
                commishSettingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                commishSettingsViewController.user = self.user
                commishSettingsViewController.tournament = self.model.getTournament()
                
                navCommishController = UINavigationController(rootViewController: commishSettingsViewController) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.addChild(navCommishController)
                view.addSubview(navCommishController.view)
                
                currentView = .commishSettings
            }
        }
    }
}

extension ContainerViewController: CommishSettingsViewControllerDelegate {
    
    func toggleTopPanelCommishSettings() {
        let notAlreadyExpanded = (currentState != .topPanelExpanded)
        
        if notAlreadyExpanded {
            addTopPanelViewControllerCommishSettings()
        }
        
        animateTopPanelCommishSettings(notAlreadyExpanded)
    }
    
    func addChildTopPanelControllerCommishSettings(_ topPanelController: TopPanelViewController) {
        topPanelController.delegate = commishSettingsViewController
        
        topPanelController.user = self.user
        if user.getRole() == "Commissioner" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings","Commish Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings","Commish Settings"]
            }
            
            if !user.isScorekeeper()
            {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Score Entry" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Spectator" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Settings"]
            }
            
        }
        else if user.getRole() == "Player" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else if user.getRole() == "Scorekeeper" {
            if model.getTournament().isDrinkCartAvailable() {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Drink Cart","Settings"]
            }
            else {
                topPanelController.menuItems = ["Scoreboard","Score Entry","Scorecard","Hole Map","Settings"]
            }
            
            if model.getTournament().getCurrentMatch(user.getPlayer()!) == nil {
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Scorecard" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
                
                for item in 0...(topPanelController.menuItems.count-1) {
                    if topPanelController.menuItems[item] == "Hole Map" {
                        topPanelController.menuItems.remove(at: item)
                        break
                    }
                }
            }
        }
        else {
            topPanelController.menuItems = [String]()
        }
        
        if model.getTournament().getMatches().count == 0 {
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Score Entry" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Scorecard" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Hole Map" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
            for item in 0...(topPanelController.menuItems.count-1) {
                if topPanelController.menuItems[item] == "Drink Cart" {
                    topPanelController.menuItems.remove(at: item)
                    break
                }
            }
        }
        
        view.insertSubview(topPanelController.view, at: 0)
        
        addChild(topPanelController)
        topPanelController.didMove(toParent: self)
    }
    
    func addTopPanelViewControllerCommishSettings() {
        if (topPanelViewController == nil) {
            topPanelViewController = UIStoryboard.topPanelViewController()
            addChildTopPanelControllerCommishSettings(topPanelViewController!)
        }
    }
    
    func animateTopPanelCommishSettings(_ shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .topPanelExpanded
            
            animateCommishSettingsPanelXPositionCommishSettings(/*CGRectGetHeight(tempViewController.view.frame)*/ commishSettingsPanelExpandedOffset)
            
        } else {
            animateCommishSettingsPanelXPositionCommishSettings(0) { _ in
                self.currentState = .topPanelCollapsed
                
                if self.topPanelViewController != nil {
                    self.topPanelViewController!.view.removeFromSuperview()
                    self.topPanelViewController = nil
                }
                
            }
        }
    }
    
    func animateCommishSettingsPanelXPositionCommishSettings(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.commishSettingsViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateCommishSettingsPanelYPositionCommishSettings(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.commishSettingsViewController.view.frame.origin.y = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCommishSettingsViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            commishSettingsViewController.view.layer.shadowOpacity = 1.0
        } else {
            commishSettingsViewController.view.layer.shadowOpacity = 0.0
        }
    }
    
    
    func collapseTopPanelCommishSettings() {
        switch (currentState) {
        case .topPanelExpanded:
            toggleTopPanelCommishSettings()
        default:
            break
        }
    }
    
    func changeViewCommishSettings(_ menu: String) {
        
        if menu == "Score Entry" {
            if currentView != .scoreEntry {
                scoreEntryViewController = UIStoryboard.scoreEntryViewController()
                scoreEntryViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                scoreEntryViewController.user = self.user
                scoreEntryViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                scoreEntryViewController.tournament = self.model.getTournament()
                if (scoreEntryViewController.match.getStartingHole() == 1 && tournament.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = tournament.getMatchLength()
                }
                else if scoreEntryViewController.match.getCurrentHole() > 18 {
                    scoreEntryViewController.viewingHoleNumber = 18
                }
                else {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getCurrentHole()
                }
                
                view.addSubview(scoreEntryViewController.view)
                
                currentView = .scoreEntry
            }
        }
        else if menu == "Scoreboard" {
            if currentView != .scoreboard {
                scoreboardViewController = UIStoryboard.scoreboardViewController()
                scoreboardViewController.delegate = self
                
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                scoreboardViewController.user = self.user
                //scoreboardViewController.matches = self.matches
                scoreboardViewController.tournament = self.model.getTournament()
                
                view.addSubview(scoreboardViewController.view)
                
                currentView = .scoreboard
            }
        }
        else if menu == "Scorecard" {
            if currentView != .matchScorecard {
                matchScorecardViewController = UIStoryboard.matchScorecardViewControllerNew()
                matchScorecardViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                
                currentView = .matchScorecard
                
                scorecardShowing = false
                
                if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    print("Landscape Left")
                }
                else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                    print("Landscape Right")
                }
                else {
                    print("Portrait")
                }
                
                if UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
                }
                else {
                    UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
                }
                
                ContainerViewController.attemptRotationToDeviceOrientation()
                
                scorecardShowing = true
                
                view.addSubview(matchScorecardViewController.view)
                
            }
        }
        else if menu == "Drink Cart" {
            if currentView != .drinkCart {
                drinkCartViewController = UIStoryboard.drinkCartViewController()
                drinkCartViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                drinkCartViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                
                view.addSubview(drinkCartViewController.view)
                
                currentView = .drinkCart
            }
        }
        else if menu == "Hole Map" {
            if currentView != .holeMap {
                holeMapViewController = UIStoryboard.holeMapViewController()
                holeMapViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                holeMapViewController.match = self.model.getTournament().getCurrentMatch(self.user.getPlayer()!)
                holeMapViewController.tournament = self.model.getTournament()
                
                view.addSubview(holeMapViewController.view)
                
                currentView = .holeMap
            }
        }
        else if menu == "Settings" {
            if currentView != .settings {
                settingsViewController = UIStoryboard.settingsViewController()
                settingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if commishSettingsViewController != nil {
                    self.navCommishController.willMove(toParent: nil)
                    self.navCommishController.view.removeFromSuperview()
                    self.navCommishController.removeFromParent()
                }
                settingsViewController.user = self.user
                
                view.addSubview(settingsViewController.view)
                
                currentView = .settings
            }
        }
        else if menu == "Commish Settings" {
            if currentView != .commishSettings {
                commishSettingsViewController = UIStoryboard.commishSettingsViewController()
                commishSettingsViewController.delegate = self
                
                if scoreboardViewController != nil {
                    self.scoreboardViewController!.view.removeFromSuperview()
                    self.scoreboardViewController = nil
                }
                if scoreEntryViewController != nil {
                    self.scoreEntryViewController!.view.removeFromSuperview()
                    self.scoreEntryViewController = nil
                }
                if drinkCartViewController != nil {
                    self.drinkCartViewController!.view.removeFromSuperview()
                    self.drinkCartViewController = nil
                }
                if holeMapViewController != nil {
                    self.holeMapViewController!.view.removeFromSuperview()
                    self.holeMapViewController = nil
                }
                if settingsViewController != nil {
                    self.settingsViewController!.view.removeFromSuperview()
                    self.settingsViewController = nil
                }
                commishSettingsViewController.user = self.user
                commishSettingsViewController.tournament = self.model.getTournament()
                
                navCommishController = UINavigationController(rootViewController: commishSettingsViewController) // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.addChild(navCommishController)
                view.addSubview(navCommishController.view)
                
                currentView = .commishSettings
            }
        }
    }
}



