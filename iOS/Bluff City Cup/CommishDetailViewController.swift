
//  CommishDetailViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 4/25/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class CommishDetailViewController: UITableViewController {

    private static let bccBlue = UIColor(red: 0.071, green: 0.176, blue: 0.451, alpha: 1.0)
    private static let bccRed = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1.0)
    private static let surfaceColor = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1.0)
    private static let textColor = UIColor(red: 0.071, green: 0.082, blue: 0.102, alpha: 1.0)
    private static let secondaryTextColor = UIColor(red: 0.365, green: 0.392, blue: 0.439, alpha: 1.0)
    private static let iconTag = 811_024
    private static let cardTag = 811_025
    private static let chevronTag = 811_026
    
    var tournament: Tournament!
    fileprivate var tournamentUpdated: Tournament!
    var settingSelected: String!
    var path: IndexPath?
    private var configuredHeaderWidth: CGFloat = 0
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.title = settingSelected
        self.navBar.backBarButtonItem?.title = "Back"
        self.tableView.delegate = self
        configureTableAppearance()
        configureNavigationAppearance()

        tournamentUpdated = tournament
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if abs(configuredHeaderWidth - tableView.bounds.width) > 0.5 {
            configureTableHeader()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBOutlet weak var navBar: UINavigationItem!
 
    @IBAction func addButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "addElement", sender: self)
        
    }
    
    // MARK: - Navigation
  
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "addElement" {
            if self.settingSelected == "Edit Players" {
                if let destViewController = segue.destination as? AddPlayerOrMatchView {
                    destViewController.editType = "Player"
                    destViewController.tournament = tournament
                    destViewController.delegate = self
                }
            }
            else if self.settingSelected == "Edit Matches" {
                if let destViewController = segue.destination as? AddPlayerOrMatchView {
                    destViewController.editType = "Match"
                    destViewController.tournament = tournament
                    destViewController.delegate = self
                }
            }
        }
        else {
            let indexPath = self.tableView.indexPathForSelectedRow
            //tableView.deselectRow(at: indexPath!, animated: true)
            //self.tableView.reloadData()
            
                if self.settingSelected == "Edit Players" {
                    if let destViewController = segue.destination as? AddPlayerOrMatchView {
                        destViewController.editType = "EditPlayer"
                        let player = self.tournament.sortPlayersByTeamAndHandicap()[(indexPath! as NSIndexPath).row]
                        destViewController.player = player
                        destViewController.tournament = tournament
                        destViewController.delegate = self
                    }
                }
                else if self.settingSelected == "Edit Matches" {
                    if let destViewController = segue.destination as? AddPlayerOrMatchView {
                        destViewController.editType = "EditMatch"
                        let match = self.tournament.getMatchesSorted()[(indexPath! as NSIndexPath).row]
                        destViewController.match = match
                        destViewController.tournament = tournament
                        destViewController.delegate = self
                    }
                }
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return settingSelected == "Edit Matches" ? 66 : 62
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if settingSelected == "Edit Players" {
            return tournament.getPlayers().count
        }
        else if settingSelected == "Edit Matches" {
            return tournament.getMatches().count
        }
        else if settingSelected == "Edit Rounds" {
            return tournament.getCourseRounds().count
        }
        else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell()
        
        if settingSelected == "Edit Players" {
            let cellIdentifier = "PlayerCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlayerViewCell
            let player = self.tournament.sortPlayersByTeamAndHandicap()[(indexPath as NSIndexPath).row]
            
            cell.playerName.text = player.getName()
            cell.playerHandicap.text = String(player.getHandicap())
            
            let teamColor = player.getTeam() == "Red" ? CommishDetailViewController.bccRed : CommishDetailViewController.bccBlue
            stylePlayerCell(cell, player: player, teamColor: teamColor)
            return cell
        }
        else if settingSelected == "Edit Matches" {
            let cellIdentifier = "MatchCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MatchViewCell
            
            let match = self.tournament.getMatchesSorted()[(indexPath as NSIndexPath).row]
            
            if match.getFormat() == "Singles" {
                cell.playersName.text = "\(match.blueTeamPlayerOne().getLastName()) vs. \(match.redTeamPlayerOne().getLastName())"
            }
            else if (match.getFormat() == "Best Ball" || match.getFormat() == "Alternate Shot" || match.getFormat() == "Two Man Scramble" || match.getFormat() == "Shamble") {
                cell.playersName.text = "\(match.blueTeamPlayerOne().getLastName())/\(match.blueTeamPlayerTwo()!.getLastName()) vs. \(match.redTeamPlayerOne().getLastName())/\(match.redTeamPlayerTwo()!.getLastName())"
            }
            
            cell.roundMatchGroup.text = "R\(match.getRound())M\(match.getMatchNumber())G\(match.getGroup())"
            styleMatchCell(cell)
            
            return cell
        }
        let cell = UITableViewCell()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        styleCardCell(cell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableHeader()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            if settingSelected == "Edit Players" {
                let player = self.tournament.sortPlayersByTeamAndHandicap()[(indexPath as NSIndexPath).row]
                
                if !tournament.deletePlayer(player) {
                    playerRemovalAlert()
                }
                else {
                    Model.sharedInstance.deletePlayer(player)
                }

                self.tableView.reloadData()
            }
            else if settingSelected == "Edit Matches" {
                let match = self.tournament.getMatchesSorted()[(indexPath as NSIndexPath).row]
                
                if !tournament.deleteMatch(match) {
                    matchRemovalAlert()
                }
                else {
                    Model.sharedInstance.deleteMatch(match)
                }
                
                self.tableView.reloadData()
            }

            
        }
    }
    
    func playerRemovalAlert() {
        let alert = UIAlertController(title: "Oops!", message: "This player is already in a match. Please delete the match first.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func matchRemovalAlert() {
        let alert = UIAlertController(title: "Oops!", message: "This match has already started. It cannot be deleted.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
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

private extension CommishDetailViewController {
    
    func configureTableAppearance() {
        view.backgroundColor = CommishDetailViewController.surfaceColor
        tableView.backgroundColor = CommishDetailViewController.surfaceColor
        tableView.separatorStyle = .none
        tableView.rowHeight = 62
        tableView.estimatedRowHeight = 62
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 18, right: 0)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func configureNavigationAppearance() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = CommishDetailViewController.bccBlue
        appearance.titleTextAttributes = titleAttributes
        appearance.shadowColor = UIColor.clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    func configureTableHeader() {
        let width = tableView.bounds.width
        guard width > 0 else { return }
        configuredHeaderWidth = width
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 94))
        headerView.backgroundColor = CommishDetailViewController.surfaceColor
        
        let card = UIView(frame: CGRect(x: 16, y: 10, width: width - 32, height: 70))
        card.autoresizingMask = [.flexibleWidth]
        card.backgroundColor = UIColor.white
        card.layer.cornerRadius = 10
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        headerView.addSubview(card)
        
        let iconView = UIImageView(frame: CGRect(x: 16, y: 15, width: 40, height: 40))
        iconView.backgroundColor = settingSelected == "Edit Matches" ? CommishDetailViewController.bccRed : CommishDetailViewController.bccBlue
        iconView.tintColor = UIColor.white
        iconView.layer.cornerRadius = 20
        iconView.contentMode = .center
        iconView.image = UIImage(systemName: settingSelected == "Edit Matches" ? "flag.2.crossed.fill" : "person.2.fill")
        card.addSubview(iconView)
        
        let titleLabel = UILabel(frame: CGRect(x: 72, y: 14, width: card.bounds.width - 140, height: 22))
        titleLabel.autoresizingMask = [.flexibleWidth]
        titleLabel.text = settingSelected
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = CommishDetailViewController.textColor
        card.addSubview(titleLabel)
        
        let count = settingSelected == "Edit Matches" ? tournament.getMatches().count : tournament.getPlayers().count
        let noun = settingSelected == "Edit Matches" ? "matches" : "players"
        let subtitleLabel = UILabel(frame: CGRect(x: 72, y: 38, width: card.bounds.width - 140, height: 20))
        subtitleLabel.autoresizingMask = [.flexibleWidth]
        subtitleLabel.text = "\(count) \(noun)"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = CommishDetailViewController.secondaryTextColor
        card.addSubview(subtitleLabel)
        
        tableView.tableHeaderView = headerView
    }
    
    func stylePlayerCell(_ cell: PlayerViewCell, player: Player, teamColor: UIColor) {
        styleCardCell(cell)
        
        cell.playerName.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.playerName.textColor = CommishDetailViewController.textColor
        cell.playerName.frame = CGRect(x: 86, y: 8, width: tableView.bounds.width - 202, height: 46)
        cell.playerName.autoresizingMask = [.flexibleWidth]
        
        cell.playerHandicap.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        cell.playerHandicap.textColor = teamColor
        cell.playerHandicap.textAlignment = .center
        cell.playerHandicap.backgroundColor = teamColor.withAlphaComponent(0.12)
        cell.playerHandicap.layer.cornerRadius = 13
        cell.playerHandicap.layer.masksToBounds = true
        cell.playerHandicap.frame = CGRect(x: tableView.bounds.width - 136, y: 18, width: 50, height: 26)
        cell.playerHandicap.autoresizingMask = [.flexibleLeftMargin]
        
        let iconView = iconImageView(in: cell.contentView)
        configurePlayerAvatar(iconView, for: player, teamColor: teamColor)
        styleChevron(in: cell.contentView)
    }
    
    func styleMatchCell(_ cell: MatchViewCell) {
        styleCardCell(cell)
        
        cell.roundMatchGroup.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        cell.roundMatchGroup.textColor = CommishDetailViewController.bccBlue
        cell.roundMatchGroup.textAlignment = .center
        cell.roundMatchGroup.backgroundColor = CommishDetailViewController.bccBlue.withAlphaComponent(0.10)
        cell.roundMatchGroup.layer.cornerRadius = 13
        cell.roundMatchGroup.layer.masksToBounds = true
        cell.roundMatchGroup.frame = CGRect(x: 34, y: 20, width: 86, height: 26)
        
        cell.playersName.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        cell.playersName.textColor = CommishDetailViewController.textColor
        cell.playersName.textAlignment = .right
        cell.playersName.frame = CGRect(x: 132, y: 12, width: tableView.bounds.width - 220, height: 42)
        cell.playersName.autoresizingMask = [.flexibleWidth]
        cell.playersName.numberOfLines = 2
        
        cell.contentView.viewWithTag(CommishDetailViewController.iconTag)?.removeFromSuperview()
        styleChevron(in: cell.contentView)
    }
    
    func styleCardCell(_ cell: UITableViewCell) {
        cell.backgroundColor = CommishDetailViewController.surfaceColor
        if #available(iOS 14.0, *) {
            cell.backgroundConfiguration = UIBackgroundConfiguration.clear()
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = CommishDetailViewController.surfaceColor
        cell.backgroundView = backgroundView
        cell.selectedBackgroundView = UIView()
        cell.contentView.backgroundColor = UIColor.clear
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.masksToBounds = false
        cell.clipsToBounds = false
        cell.selectionStyle = .default
        cell.accessoryType = .none
        
        let cardView: UIView
        if let existing = cell.contentView.viewWithTag(CommishDetailViewController.cardTag) {
            cardView = existing
        } else {
            cardView = UIView()
            cardView.tag = CommishDetailViewController.cardTag
            cardView.isUserInteractionEnabled = false
            cell.contentView.insertSubview(cardView, at: 0)
        }
        
        let rowHeight: CGFloat = settingSelected == "Edit Matches" ? 66 : 62
        cardView.frame = CGRect(x: 16, y: 4, width: tableView.bounds.width - 32, height: rowHeight - 8)
        cardView.autoresizingMask = [.flexibleWidth]
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 8
        cardView.layer.masksToBounds = true
    }
    
    func iconImageView(in contentView: UIView) -> UIImageView {
        if let existing = contentView.viewWithTag(CommishDetailViewController.iconTag) as? UIImageView {
            return existing
        }
        
        let iconView = UIImageView(frame: CGRect(x: 32, y: 13, width: 36, height: 36))
        iconView.tag = CommishDetailViewController.iconTag
        iconView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin]
        iconView.layer.cornerRadius = 18
        iconView.layer.masksToBounds = true
        iconView.contentMode = .center
        contentView.addSubview(iconView)
        return iconView
    }
    
    func configurePlayerAvatar(_ imageView: UIImageView, for player: Player, teamColor: UIColor) {
        let cacheKey = avatarCacheKey(for: player.getName())
        imageView.accessibilityIdentifier = cacheKey
        imageView.frame = CGRect(x: 32, y: 13, width: 36, height: 36)
        imageView.layer.cornerRadius = 18
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = teamColor.withAlphaComponent(0.58).cgColor
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = teamColor.withAlphaComponent(0.12)
        imageView.tintColor = teamColor
        imageView.contentMode = .center
        imageView.image = UIImage(systemName: "person.fill")
        
        if let cachedImage = UserDefaults.standard.object(forKey: cacheKey) as? NSData,
           let image = UIImage(data: cachedImage as Data) {
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            return
        }
        
        guard let url = URL(string: "https://glizzyattheturn.app/bcc/" + cacheKey + ".png") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data), let pngImage = image.pngData() else { return }
            UserDefaults.standard.set(pngImage, forKey: cacheKey)
            DispatchQueue.main.async {
                if imageView.accessibilityIdentifier == cacheKey {
                    imageView.contentMode = .scaleAspectFill
                    imageView.image = image
                }
            }
        }.resume()
    }
    
    func avatarCacheKey(for name: String) -> String {
        return name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    func styleChevron(in contentView: UIView) {
        let chevron: UIImageView
        if let existing = contentView.viewWithTag(CommishDetailViewController.chevronTag) as? UIImageView {
            chevron = existing
        } else {
            chevron = UIImageView()
            chevron.tag = CommishDetailViewController.chevronTag
            chevron.contentMode = .center
            contentView.addSubview(chevron)
        }
        
        let rowHeight: CGFloat = settingSelected == "Edit Matches" ? 66 : 62
        chevron.frame = CGRect(x: tableView.bounds.width - 72, y: 0, width: 28, height: rowHeight)
        chevron.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = UIColor(red: 0.686, green: 0.710, blue: 0.753, alpha: 1.0)
    }
}

extension CommishDetailViewController: AddPlayerOrMatchViewDelegate {
    func updateTournament(_ tournament: Tournament) {
        self.tournament = tournament
    }
    
    func reload() {
        self.tableView.reloadData()
    }
}
