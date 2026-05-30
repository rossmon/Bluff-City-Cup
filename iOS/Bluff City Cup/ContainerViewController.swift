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
    case schedule
    case records
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
    var scheduleNavigationController: UINavigationController!
    var scheduleViewController: ScheduleViewController!
    var recordsNavigationController: UINavigationController!
    var recordsViewController: RecordsViewController!
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
            else if currentView == .schedule {
                showShadowForScheduleViewController(shouldShowShadow)
            }
            else if currentView == .records {
                showShadowForRecordsViewController(shouldShowShadow)
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
    var schedulePanelExpandedOffset: CGFloat = 200
    var recordsPanelExpandedOffset: CGFloat = 200
    var commishSettingsPanelExpandedOffset: CGFloat = 200
    var topPanelBackdropView: UIView?
    var scheduleAvailable = false
    var scheduleTournamentName: String?

    var topPanelOverlayWidth: CGFloat {
        return min(320, max(260, view.bounds.width * 0.78))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIApplication.shared.statusBarStyle = .lightContent
        
        currentView = .container
        
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        
        currentView = .scoreboard
        scorecardShowing = false
        
        self.view.backgroundColor = UIColorFromRGB(0x0F296B)
        
        actInd.style = UIActivityIndicatorView.Style.large
        actInd.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(actInd)
        actInd.startAnimating()
        
        setupApp()
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleEventsDidChange(_:)), name: .bccScheduleEventsDidChange, object: nil)
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func installTopPanelOverlay(_ topPanelController: TopPanelViewController) {
        topPanelBackdropView?.removeFromSuperview()

        let backdropView = UIView(frame: view.bounds)
        backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        backdropView.alpha = 0
        backdropView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topPanelBackdropTapped)))
        view.addSubview(backdropView)
        topPanelBackdropView = backdropView

        let drawerWidth = topPanelOverlayWidth
        topPanelController.currentMenuItem = currentMenuItemName()
        topPanelController.view.frame = CGRect(x: -drawerWidth, y: 0, width: drawerWidth, height: view.bounds.height)
        topPanelController.view.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        view.addSubview(topPanelController.view)
    }

    func animateTopPanelOverlay(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        let shouldShow = targetPosition > 0
        let drawerWidth = topPanelOverlayWidth

        UIView.animate(withDuration: 0.24, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.topPanelViewController?.view.frame.origin.x = shouldShow ? 0 : -drawerWidth
            self.topPanelBackdropView?.backgroundColor = UIColor.black.withAlphaComponent(shouldShow ? 0.34 : 0.0)
            self.topPanelBackdropView?.alpha = shouldShow ? 1 : 0
        }, completion: completion)
    }

    @objc func topPanelBackdropTapped() {
        switch currentView {
        case .scoreEntry:
            collapseTopPanelScoreEntry()
        case .scoreboard:
            collapseTopPanelScoreboard()
        case .drinkCart:
            collapseTopPanelDrinkCart()
        case .holeMap:
            collapseTopPanelHoleMap()
        case .settings:
            collapseTopPanelSettings()
        case .schedule:
            collapseTopPanelSchedule()
        case .records:
            collapseTopPanelRecords()
        case .commishSettings:
            collapseTopPanelCommishSettings()
        default:
            break
        }
    }

    func removeTopPanelOverlayViews() {
        topPanelBackdropView?.removeFromSuperview()
        topPanelBackdropView = nil

        if topPanelViewController != nil {
            topPanelViewController!.view.removeFromSuperview()
            topPanelViewController = nil
        }
    }

    func currentMenuItemName() -> String? {
        switch currentView {
        case .scoreEntry:
            return "Score Entry"
        case .scoreboard:
            return "Scoreboard"
        case .drinkCart:
            return "Drink Cart"
        case .holeMap:
            return "Hole Map"
        case .settings:
            return "Settings"
        case .schedule:
            return TopPanelViewController.scheduleMenuTitle
        case .records:
            return TopPanelViewController.recordsMenuTitle
        case .commishSettings:
            return "Commish Settings"
        case .matchScorecard:
            return "Scorecard"
        default:
            return nil
        }
    }
    
    private func appendOptionalMenuItemsIfNeeded(to topPanelController: TopPanelViewController) {
        appendScheduleMenuItemIfNeeded(to: topPanelController)
        appendRecordsMenuItemIfNeeded(to: topPanelController)
    }

    private func appendScheduleMenuItemIfNeeded(to topPanelController: TopPanelViewController) {
        guard tournamentSupportsSchedule() else { return }
        guard topPanelController.menuItems != nil else { return }
        guard !topPanelController.menuItems.contains(TopPanelViewController.scheduleMenuTitle) else { return }

        if let recordsIndex = topPanelController.menuItems.firstIndex(of: TopPanelViewController.recordsMenuTitle) {
            topPanelController.menuItems.insert(TopPanelViewController.scheduleMenuTitle, at: recordsIndex)
        } else if let settingsIndex = topPanelController.menuItems.firstIndex(of: "Settings") {
            topPanelController.menuItems.insert(TopPanelViewController.scheduleMenuTitle, at: settingsIndex)
        } else {
            topPanelController.menuItems.append(TopPanelViewController.scheduleMenuTitle)
        }
    }

    private func appendRecordsMenuItemIfNeeded(to topPanelController: TopPanelViewController) {
        guard tournamentSupportsHistoricalRecords() else { return }
        guard topPanelController.menuItems != nil else { return }
        guard !topPanelController.menuItems.contains(TopPanelViewController.recordsMenuTitle) else { return }
        
        if let settingsIndex = topPanelController.menuItems.firstIndex(of: "Settings") {
            topPanelController.menuItems.insert(TopPanelViewController.recordsMenuTitle, at: settingsIndex)
        } else {
            topPanelController.menuItems.append(TopPanelViewController.recordsMenuTitle)
        }
    }
    
    private func tournamentSupportsHistoricalRecords() -> Bool {
        guard let currentTournament = model.tournament else { return false }
        return currentTournament.getName().hasPrefix("Bluff City Cup")
    }

    private func tournamentSupportsSchedule() -> Bool {
        guard let currentTournament = model.tournament else { return false }
        let name = currentTournament.getName()
        return scheduleAvailable && scheduleTournamentName == name
    }

    private func refreshScheduleAvailability(tournamentName: String? = nil, completion: (() -> Void)? = nil) {
        let name = tournamentName ?? model.tournament?.getName()
        guard let currentName = name, !currentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            scheduleAvailable = false
            scheduleTournamentName = nil
            completion?()
            return
        }

        ScheduleAPIService.shared.fetchSchedule(tournamentName: currentName) { [weak self] payload, _ in
            guard let self = self else { return }
            guard self.model.tournament == nil || self.model.tournament.getName() == currentName else {
                completion?()
                return
            }

            self.scheduleTournamentName = currentName
            self.scheduleAvailable = payload?.events.isEmpty == false
            self.refreshOpenTopPanelMenuItems()
            completion?()
        }
    }

    private func refreshOpenTopPanelMenuItems() {
        guard let topPanelController = topPanelViewController else { return }
        topPanelController.menuItems = menuItemsForCurrentUser()
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        topPanelController.currentMenuItem = currentMenuItemName()
        topPanelController.tableView.reloadData()
    }

    @objc private func scheduleEventsDidChange(_ notification: Notification) {
        let changedTournamentName = notification.userInfo?["tournamentName"] as? String
        guard changedTournamentName == nil || changedTournamentName == model.tournament?.getName() else { return }
        refreshScheduleAvailability(tournamentName: changedTournamentName ?? model.tournament?.getName())
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
        scheduleAvailable = false
        scheduleTournamentName = nil
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
                self.refreshScheduleAvailability(tournamentName: tournamentName)
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

    private func removeRecordsViewControllerIfNeeded() {
        if recordsNavigationController != nil {
            recordsNavigationController.willMove(toParent: nil)
            recordsNavigationController.view.removeFromSuperview()
            recordsNavigationController.removeFromParent()
            recordsNavigationController = nil
            recordsViewController = nil
        }
    }

    private func removeScheduleViewControllerIfNeeded() {
        if scheduleNavigationController != nil {
            scheduleNavigationController.willMove(toParent: nil)
            scheduleNavigationController.view.removeFromSuperview()
            scheduleNavigationController.removeFromParent()
            scheduleNavigationController = nil
            scheduleViewController = nil
        }
    }

    private func removeActiveViewControllersForRecords() {
        if scoreboardViewController != nil {
            scoreboardViewController.view.removeFromSuperview()
            scoreboardViewController = nil
        }
        if scoreEntryViewController != nil {
            scoreEntryViewController.view.removeFromSuperview()
            scoreEntryViewController = nil
        }
        if matchScorecardViewController != nil {
            matchScorecardViewController.view.removeFromSuperview()
            matchScorecardViewController = nil
        }
        if drinkCartViewController != nil {
            drinkCartViewController.view.removeFromSuperview()
            drinkCartViewController = nil
        }
        if holeMapViewController != nil {
            holeMapViewController.view.removeFromSuperview()
            holeMapViewController = nil
        }
        if settingsViewController != nil {
            settingsViewController.view.removeFromSuperview()
            settingsViewController = nil
        }
        removeScheduleViewControllerIfNeeded()
        if navCommishController != nil {
            navCommishController.willMove(toParent: nil)
            navCommishController.view.removeFromSuperview()
            navCommishController.removeFromParent()
            navCommishController = nil
            commishSettingsViewController = nil
        }
    }

    private func showRecordsView() {
        guard tournamentSupportsHistoricalRecords() else { return }
        guard currentView != .records else { return }

        removeActiveViewControllersForRecords()
        removeScheduleViewControllerIfNeeded()
        recordsViewController = RecordsViewController()
        recordsViewController.delegate = self
        recordsNavigationController = UINavigationController(rootViewController: recordsViewController)
        addChild(recordsNavigationController)
        recordsNavigationController.view.frame = view.bounds
        recordsNavigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(recordsNavigationController.view)
        recordsNavigationController.didMove(toParent: self)
        currentView = .records
    }

    private func showScheduleView() {
        guard tournamentSupportsSchedule() else { return }
        guard currentView != .schedule else { return }
        guard let tournamentName = model.tournament?.getName() else { return }

        removeActiveViewControllersForRecords()
        removeRecordsViewControllerIfNeeded()
        scheduleViewController = ScheduleViewController(tournamentName: tournamentName)
        scheduleViewController.delegate = self
        scheduleNavigationController = UINavigationController(rootViewController: scheduleViewController)
        addChild(scheduleNavigationController)
        scheduleNavigationController.view.frame = view.bounds
        scheduleNavigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scheduleNavigationController.view)
        scheduleNavigationController.didMove(toParent: self)
        currentView = .schedule
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
        
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        
        installTopPanelOverlay(topPanelController)
        
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
                
                self.removeTopPanelOverlayViews()
                
            }
        }
    }
    
    func animateScoreboardPanelXPositionScoreboard(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        animateTopPanelOverlay(targetPosition, completion: completion)
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
        if menu == TopPanelViewController.scheduleMenuTitle {
            showScheduleView()
            return
        }

        if menu == TopPanelViewController.recordsMenuTitle {
            showRecordsView()
            return
        }
        
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
                if (scoreEntryViewController.match.getStartingHole() == 1 && scoreEntryViewController.match.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getMatchLength()
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
        
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        
        installTopPanelOverlay(topPanelController)
        
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
                
                self.removeTopPanelOverlayViews()
                
            }
        }
    }
    
    func animateScoreEntryPanelXPositionScoreEntry(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil)
    {
        animateTopPanelOverlay(targetPosition, completion: completion)
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
        if menu == TopPanelViewController.scheduleMenuTitle {
            showScheduleView()
            return
        }

        if menu == TopPanelViewController.recordsMenuTitle {
            showRecordsView()
            return
        }
        
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
                if (scoreEntryViewController.match.getStartingHole() == 1 && scoreEntryViewController.match.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getMatchLength()
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
        
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        
        installTopPanelOverlay(topPanelController)
        
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
                
                self.removeTopPanelOverlayViews()
                
            }
        }
    }
    
    func animateDrinkCartPanelXPositionDrinkCart(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        animateTopPanelOverlay(targetPosition, completion: completion)
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
        if menu == TopPanelViewController.scheduleMenuTitle {
            showScheduleView()
            return
        }

        if menu == TopPanelViewController.recordsMenuTitle {
            showRecordsView()
            return
        }
        
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
                if (scoreEntryViewController.match.getStartingHole() == 1 && scoreEntryViewController.match.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getMatchLength()
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
        
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        
        installTopPanelOverlay(topPanelController)
        
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
                
                self.removeTopPanelOverlayViews()
                
            }
        }
    }
    
    func animateHoleMapPanelXPositionHoleMap(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        animateTopPanelOverlay(targetPosition, completion: completion)
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
        if menu == TopPanelViewController.scheduleMenuTitle {
            showScheduleView()
            return
        }

        if menu == TopPanelViewController.recordsMenuTitle {
            showRecordsView()
            return
        }
        
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
                if (scoreEntryViewController.match.getStartingHole() == 1 && scoreEntryViewController.match.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getMatchLength()
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
        
        
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        
        installTopPanelOverlay(topPanelController)
        
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
                
                self.removeTopPanelOverlayViews()
                
            }
        }
    }
    
    func animateSettingsPanelXPositionSettings(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        animateTopPanelOverlay(targetPosition, completion: completion)
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
        if menu == TopPanelViewController.scheduleMenuTitle {
            showScheduleView()
            return
        }

        if menu == TopPanelViewController.recordsMenuTitle {
            showRecordsView()
            return
        }
        
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
                if (scoreEntryViewController.match.getStartingHole() == 1 && scoreEntryViewController.match.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getMatchLength()
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
        
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        
        installTopPanelOverlay(topPanelController)
        
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
                
                self.removeTopPanelOverlayViews()
                
            }
        }
    }
    
    func animateCommishSettingsPanelXPositionCommishSettings(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        animateTopPanelOverlay(targetPosition, completion: completion)
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
        if menu == TopPanelViewController.scheduleMenuTitle {
            showScheduleView()
            return
        }

        if menu == TopPanelViewController.recordsMenuTitle {
            showRecordsView()
            return
        }
        
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
                if (scoreEntryViewController.match.getStartingHole() == 1 && scoreEntryViewController.match.getMatchLength() < scoreEntryViewController.match.getCurrentHole()) {
                    scoreEntryViewController.viewingHoleNumber = scoreEntryViewController.match.getMatchLength()
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

extension ContainerViewController: RecordsViewControllerDelegate {
    func toggleTopPanelRecords() {
        let notAlreadyExpanded = (currentState != .topPanelExpanded)
        if notAlreadyExpanded {
            addTopPanelViewControllerRecords()
        }
        animateTopPanelRecords(notAlreadyExpanded)
    }

    func addTopPanelViewControllerRecords() {
        if topPanelViewController == nil {
            topPanelViewController = UIStoryboard.topPanelViewController()
            addChildTopPanelControllerRecords(topPanelViewController!)
        }
    }

    func addChildTopPanelControllerRecords(_ topPanelController: TopPanelViewController) {
        topPanelController.delegate = recordsViewController
        topPanelController.user = self.user
        topPanelController.menuItems = menuItemsForCurrentUser()
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        installTopPanelOverlay(topPanelController)
        addChild(topPanelController)
        topPanelController.didMove(toParent: self)
    }

    fileprivate func menuItemsForCurrentUser() -> [String] {
        var items: [String]
        let drinkCartAvailable = model.getTournament().isDrinkCartAvailable()
        let currentPlayer = user.getPlayer()
        let hasCurrentMatch = currentPlayer != nil ? model.getTournament().getCurrentMatch(currentPlayer!) != nil : false

        if user.getRole() == "Commissioner" {
            items = drinkCartAvailable
                ? ["Scoreboard", "Score Entry", "Scorecard", "Hole Map", "Drink Cart", "Settings", "Commish Settings"]
                : ["Scoreboard", "Score Entry", "Scorecard", "Hole Map", "Settings", "Commish Settings"]

            if !user.isScorekeeper() {
                items.removeAll { $0 == "Score Entry" }
            }
        } else if user.getRole() == "Spectator" {
            items = drinkCartAvailable ? ["Scoreboard", "Drink Cart", "Settings"] : ["Scoreboard", "Settings"]
        } else if user.getRole() == "Player" {
            items = drinkCartAvailable ? ["Scoreboard", "Scorecard", "Hole Map", "Drink Cart", "Settings"] : ["Scoreboard", "Scorecard", "Hole Map", "Settings"]
        } else if user.getRole() == "Scorekeeper" {
            items = drinkCartAvailable ? ["Scoreboard", "Score Entry", "Scorecard", "Hole Map", "Drink Cart", "Settings"] : ["Scoreboard", "Score Entry", "Scorecard", "Hole Map", "Settings"]
        } else {
            items = []
        }

        if !hasCurrentMatch {
            items.removeAll { $0 == "Scorecard" || $0 == "Hole Map" }
        }

        if model.getTournament().getMatches().count == 0 {
            items.removeAll { $0 == "Score Entry" || $0 == "Scorecard" || $0 == "Hole Map" || $0 == "Drink Cart" }
        }

        return items
    }

    func animateTopPanelRecords(_ shouldExpand: Bool) {
        if shouldExpand {
            currentState = .topPanelExpanded
            animateRecordsPanelXPosition(recordsPanelExpandedOffset)
        } else {
            animateRecordsPanelXPosition(0) { _ in
                self.currentState = .topPanelCollapsed
                self.removeTopPanelOverlayViews()
            }
        }
    }

    func animateRecordsPanelXPosition(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        animateTopPanelOverlay(targetPosition, completion: completion)
    }

    func showShadowForRecordsViewController(_ shouldShowShadow: Bool) {
        guard recordsNavigationController != nil else { return }
        recordsNavigationController.view.layer.shadowOpacity = shouldShowShadow ? 1.0 : 0.0
    }

    func collapseTopPanelRecords() {
        switch currentState {
        case .topPanelExpanded:
            toggleTopPanelRecords()
        default:
            break
        }
    }

    func changeViewRecords(_ menu: String, scorecardMatch: Match?) {
        if menu == TopPanelViewController.recordsMenuTitle {
            return
        }

        if menu == TopPanelViewController.scheduleMenuTitle {
            removeRecordsViewControllerIfNeeded()
            currentView = .container
            showScheduleView()
            return
        }

        removeRecordsViewControllerIfNeeded()
        currentView = .container
        changeViewScoreboard(menu, scorecardMatch: scorecardMatch)
    }
}

extension ContainerViewController: ScheduleViewControllerDelegate {
    func toggleTopPanelSchedule() {
        let notAlreadyExpanded = (currentState != .topPanelExpanded)
        if notAlreadyExpanded {
            addTopPanelViewControllerSchedule()
        }
        animateTopPanelSchedule(notAlreadyExpanded)
    }

    func addTopPanelViewControllerSchedule() {
        if topPanelViewController == nil {
            topPanelViewController = UIStoryboard.topPanelViewController()
            addChildTopPanelControllerSchedule(topPanelViewController!)
        }
    }

    func addChildTopPanelControllerSchedule(_ topPanelController: TopPanelViewController) {
        topPanelController.delegate = scheduleViewController
        topPanelController.user = self.user
        topPanelController.menuItems = menuItemsForCurrentUser()
        appendOptionalMenuItemsIfNeeded(to: topPanelController)
        installTopPanelOverlay(topPanelController)
        addChild(topPanelController)
        topPanelController.didMove(toParent: self)
    }

    func animateTopPanelSchedule(_ shouldExpand: Bool) {
        if shouldExpand {
            currentState = .topPanelExpanded
            animateSchedulePanelXPosition(schedulePanelExpandedOffset)
        } else {
            animateSchedulePanelXPosition(0) { _ in
                self.currentState = .topPanelCollapsed
                self.removeTopPanelOverlayViews()
            }
        }
    }

    func animateSchedulePanelXPosition(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        animateTopPanelOverlay(targetPosition, completion: completion)
    }

    func showShadowForScheduleViewController(_ shouldShowShadow: Bool) {
        guard scheduleNavigationController != nil else { return }
        scheduleNavigationController.view.layer.shadowOpacity = shouldShowShadow ? 1.0 : 0.0
    }

    func collapseTopPanelSchedule() {
        switch currentState {
        case .topPanelExpanded:
            toggleTopPanelSchedule()
        default:
            break
        }
    }

    func changeViewSchedule(_ menu: String, scorecardMatch: Match?) {
        if menu == TopPanelViewController.scheduleMenuTitle {
            return
        }

        if menu == TopPanelViewController.recordsMenuTitle {
            removeScheduleViewControllerIfNeeded()
            currentView = .container
            showRecordsView()
            return
        }

        removeScheduleViewControllerIfNeeded()
        currentView = .container
        changeViewScoreboard(menu, scorecardMatch: scorecardMatch)
    }
}
