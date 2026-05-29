//
//  TestTableViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 3/11/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

protocol CommishSettingsViewControllerDelegate {
    
    func toggleTopPanelCommishSettings()
    func collapseTopPanelCommishSettings()
    func changeViewCommishSettings(_ menu: String)
    
}

class CommishSettingsViewController: UITableViewController {
    
    private static let bccBlue = UIColor(red: 0.071, green: 0.176, blue: 0.451, alpha: 1.0)
    private static let bccRed = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1.0)
    private static let surfaceColor = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1.0)
    private static let secondarySurfaceColor = UIColor(red: 0.957, green: 0.965, blue: 0.976, alpha: 1.0)
    private static let textColor = UIColor(red: 0.071, green: 0.082, blue: 0.102, alpha: 1.0)
    private static let secondaryTextColor = UIColor(red: 0.365, green: 0.392, blue: 0.439, alpha: 1.0)
    private static let iconTag = 711_024
    
    var delegate: CommishSettingsViewControllerDelegate?
    var user = User.sharedInstance
    var tournament: Tournament!
    var model = Model.sharedInstance
    @IBOutlet weak var navBar: UINavigationItem!
    var selectedCell: String!
    private var configuredHeaderWidth: CGFloat = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        selectedCell = ""
        self.navBar.backBarButtonItem?.title = "Back"
        configureTableAppearance()
        configureNavigationAppearance()
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        }
        else if section == 1 {
            return 2
        }
        else if section == 2 {
            return 2
        }
        else if section == 3 {
            return 1
        }
        else if section == 4 {
            return 1
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            return 56
        }
        
        return 58
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 4 ? 24 : 8
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = CommishSettingsViewController.surfaceColor
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = sectionTitle(section)
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = CommishSettingsViewController.secondaryTextColor
        label.letterSpacing(0.8)
        
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        return container
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if (indexPath as NSIndexPath).section == 0 {
            /*if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "matchLengthCell", for: indexPath) as! MatchLengthCell
                cell.settingLabel.text = "Match Length"
                //tournament.getMatchLength()
                /*if .getMatchLength() == 9 {
                    cell.matchLengthSelector.selectedSegmentIndex = 0
                }
                else {
                    cell.matchLengthSelector.selectedSegmentIndex = 1
                }*/
                
                cell.tournament = self.tournament
            }
            else*/ if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "numberOfRoundsCell", for: indexPath) as! NumberOfRoundsCell
                cell.settingLabel.text = "Number of Rounds"
                cell.numberOfRoundsSelector.selectedSegmentIndex = tournament.getNumberOfRounds() - 1
                cell.tournament = self.tournament
                styleSettingsCell(cell, label: cell.settingLabel, iconName: "calendar.badge.clock", tint: CommishSettingsViewController.bccBlue, labelWidth: 145)
                styleSegmentedControl(cell.numberOfRoundsSelector, tint: CommishSettingsViewController.bccBlue)
            }
            else if (indexPath as NSIndexPath).row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "maxHandicapCell", for: indexPath) as! MaxHandicapCell
                cell.settingLabel.text = "Max Handicap"
                cell.tournament = self.tournament
                cell.maxHandicapField.text = String(self.tournament.getMaxHandicap())
                styleSettingsCell(cell, label: cell.settingLabel, iconName: "number", tint: CommishSettingsViewController.bccBlue)
                styleTextField(cell.maxHandicapField, width: 58)
                cell.maxHandicapField.keyboardType = .numberPad
            }
            else if (indexPath as NSIndexPath).row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commishPasswordCell", for: indexPath) as! CommishPasswordCell
                cell.settingLabel.text = "Commissioner Password"
                cell.tournament = self.tournament
                cell.commishPasswordField.text = String(self.tournament.getCommissionerPassword())
                styleSettingsCell(cell, label: cell.settingLabel, iconName: "lock.fill", tint: CommishSettingsViewController.bccRed, labelWidth: 156)
                styleTextField(cell.commishPasswordField, width: 142)
            }
        }
        else if (indexPath as NSIndexPath).section == 1 {
            if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCartOnCell", for: indexPath) as! DrinkCartOnCell
                cell.settingLabel.text = "Drink Cart"
                cell.drinkCartSwitch.isOn = tournament.isDrinkCartAvailable()
                cell.tournament = self.tournament
                styleSettingsCell(cell, label: cell.settingLabel, iconName: "cart.fill", tint: CommishSettingsViewController.bccBlue)
                cell.drinkCartSwitch.onTintColor = CommishSettingsViewController.bccBlue
                styleSwitch(cell.drinkCartSwitch)
            }
            else if (indexPath as NSIndexPath).row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCartNumberCell", for: indexPath) as! DrinkCartNumberCell
                cell.settingLabel.text = "Drink Cart Number"
                cell.tournament = self.tournament
                cell.drinkCartNumber.text = self.tournament.getDrinkCartNumber()
                styleSettingsCell(cell, label: cell.settingLabel, iconName: "phone.fill", tint: CommishSettingsViewController.bccRed, labelWidth: 150)
                styleTextField(cell.drinkCartNumber, width: 142)
                cell.drinkCartNumber.keyboardType = .phonePad
            }
        }
        else if (indexPath as NSIndexPath).section == 2 {
            if (indexPath as NSIndexPath).row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commishSettingsCell", for: indexPath) as! CommishSettingsCell
                cell.settingLabel.text = "Players"
                cell.settingStatus.text = "Edit"
                styleSettingsCell(cell, label: cell.settingLabel, iconName: "person.2.fill", tint: CommishSettingsViewController.bccBlue)
                styleStatusLabel(cell.settingStatus)
                
            }
            else if (indexPath as NSIndexPath).row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commishSettingsCell", for: indexPath) as! CommishSettingsCell
                cell.settingLabel.text = "Matches"
                cell.settingStatus.text = "Edit"
                styleSettingsCell(cell, label: cell.settingLabel, iconName: "flag.2.crossed.fill", tint: CommishSettingsViewController.bccRed)
                styleStatusLabel(cell.settingStatus)
            }
            else if (indexPath as NSIndexPath).row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commishSettingsCell", for: indexPath) as! CommishSettingsCell
                cell.settingLabel.text = "Courses for Rounds"
                cell.settingStatus.text = ""
                styleSettingsCell(cell, label: cell.settingLabel, iconName: "map.fill", tint: CommishSettingsViewController.bccBlue)
                styleStatusLabel(cell.settingStatus)
            }
        }
        else if (indexPath as NSIndexPath).section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCourseCell", for: indexPath) as! AddCourseCell
            cell.settingLabel.text = "Add Course"
            styleSettingsCell(cell, label: cell.settingLabel, iconName: "plus.circle.fill", tint: CommishSettingsViewController.bccBlue)
        }
        else if (indexPath as NSIndexPath).section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteMatchesCell", for: indexPath) as! DeleteMatchesCell
            cell.settingLabel.text = "Delete All Matches"
            styleDestructiveCell(cell, label: cell.settingLabel)
        }
        
        return cell
        
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let path = self.tableView.indexPathForSelectedRow
        tableView.deselectRow(at: path!, animated: true)
        self.tableView.reloadData()
        
        if (path! as NSIndexPath).section == 0 {
            /*
             if (path! as NSIndexPath).row == 0 {
             self.selectedCell = "Match Length"
             }
             else if (path! as NSIndexPath).row == 1 {
             self.selectedCell = "Number of Matches"
             }
             else if (path! as NSIndexPath).row == 2 {
             self.selectedCell = "Drink Cart"
             }
             */
        }
        else if (path! as NSIndexPath).section == 1 {
            
        }
        else if (path! as NSIndexPath).section == 2 {
            if (path! as NSIndexPath).row == 0 {
                self.selectedCell = "Edit Players"
            }
            else if (path! as NSIndexPath).row == 1 {
                self.selectedCell = "Edit Matches"
            }
            else if (path! as NSIndexPath).row == 2 {
                self.selectedCell = "Edit Rounds"
            }
        }
        
        if let destViewController = segue.destination as? CommishDetailViewController {
            
            destViewController.tournament = self.tournament
            destViewController.settingSelected = selectedCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("Selected section: \(indexPath.section)")
        if indexPath.section == 3 {
            print("Selected Add Course")
            self.performSegue(withIdentifier: "addCourseSegue", sender: self)
        }
        else if indexPath.section == 4 {
            print("Selected Delete All Matches")
            verifyMatchDeletion()
            tableView.reloadData()
        }
        else {
            self.performSegue(withIdentifier: "listSegue", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath
    {
        if (indexPath.section == 2) || (indexPath.section == 3) || (indexPath.section == 4){
            return indexPath
        }
        return IndexPath()
    }
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if (indexPath.section == 2) || (indexPath.section == 3) {
            return true
        }
        else if indexPath.section == 4 {
            self.tableView(self.tableView, didSelectRowAt: indexPath)
        }
        return false
    }
    
    
    @IBAction func saveToCommishSettings(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CommishDetailViewController, let tournamentNew = sourceViewController.tournament {
            self.tournament = tournamentNew
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        User.sharedInstance.updateScorekeeperFromTournament(tournament)
        self.delegate?.changeViewCommishSettings("Scoreboard")
    }
    
    func verifyMatchDeletion() {
        let deleteMatchAlert = UIAlertController(title: "Verify", message: "Are you sure you want to delete all matches and round scores for this tournament?", preferredStyle: UIAlertController.Style.alert)
        
        deleteMatchAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            print("Wants to delete all matches")
            
            self.model.deleteAllMatches(tournamentName: self.tournament.getName())
            self.tournament.deleteMatches()
            self.user.updateRole(tournamentName: self.tournament.getName()) { }
        }))
        deleteMatchAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Doesn't want to delete matches.")
        }))
        
        present(deleteMatchAlert, animated: true, completion: nil)
    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableHeader()
        self.tableView.reloadData() // to reload selected cell
    }
    
}

private extension CommishSettingsViewController {
    
    func configureTableAppearance() {
        view.backgroundColor = CommishSettingsViewController.surfaceColor
        tableView.backgroundColor = CommishSettingsViewController.surfaceColor
        tableView.separatorStyle = .none
        tableView.rowHeight = 58
        tableView.estimatedRowHeight = 58
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
        appearance.backgroundColor = CommishSettingsViewController.bccBlue
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
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 104))
        headerView.backgroundColor = CommishSettingsViewController.surfaceColor
        
        let card = UIView(frame: CGRect(x: 16, y: 12, width: width - 32, height: 76))
        card.autoresizingMask = [.flexibleWidth]
        card.backgroundColor = UIColor.white
        card.layer.cornerRadius = 10
        card.layer.masksToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        headerView.addSubview(card)
        
        let iconView = UIImageView(frame: CGRect(x: 16, y: 16, width: 44, height: 44))
        iconView.backgroundColor = CommishSettingsViewController.bccBlue
        iconView.tintColor = UIColor.white
        iconView.layer.cornerRadius = 22
        iconView.contentMode = .center
        iconView.image = UIImage(systemName: "person.badge.key.fill")
        card.addSubview(iconView)
        
        let titleLabel = UILabel(frame: CGRect(x: 76, y: 16, width: card.bounds.width - 160, height: 22))
        titleLabel.autoresizingMask = [.flexibleWidth]
        titleLabel.text = tournament?.getName() ?? "Commissioner Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = CommishSettingsViewController.textColor
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel(frame: CGRect(x: 76, y: 40, width: card.bounds.width - 160, height: 20))
        subtitleLabel.autoresizingMask = [.flexibleWidth]
        subtitleLabel.text = "Commissioner"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = CommishSettingsViewController.secondaryTextColor
        card.addSubview(subtitleLabel)
        
        let readyLabel = UILabel(frame: CGRect(x: card.bounds.width - 82, y: 24, width: 66, height: 28))
        readyLabel.autoresizingMask = [.flexibleLeftMargin]
        readyLabel.text = "Ready"
        readyLabel.textAlignment = .center
        readyLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        readyLabel.textColor = CommishSettingsViewController.bccBlue
        readyLabel.backgroundColor = CommishSettingsViewController.bccBlue.withAlphaComponent(0.10)
        readyLabel.layer.cornerRadius = 14
        readyLabel.layer.masksToBounds = true
        card.addSubview(readyLabel)
        
        tableView.tableHeaderView = headerView
    }
    
    func sectionTitle(_ section: Int) -> String {
        switch section {
        case 0:
            return "Tournament"
        case 1:
            return "Drink Cart"
        case 2:
            return "Management"
        case 3:
            return "Courses"
        case 4:
            return "Danger Zone"
        default:
            return ""
        }
    }
    
    func styleSettingsCell(_ cell: UITableViewCell, label: UILabel, iconName: String, tint: UIColor, labelWidth: CGFloat = 210) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.white
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.masksToBounds = true
        cell.selectionStyle = .none
        
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = CommishSettingsViewController.textColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.frame = CGRect(x: 56, y: 0, width: labelWidth, height: 58)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let iconView = iconImageView(in: cell.contentView)
        iconView.tintColor = tint
        iconView.backgroundColor = tint.withAlphaComponent(0.12)
        iconView.image = UIImage(systemName: iconName)
    }
    
    func styleDestructiveCell(_ cell: UITableViewCell, label: UILabel) {
        cell.backgroundColor = CommishSettingsViewController.surfaceColor
        let backgroundView = UIView()
        backgroundView.backgroundColor = CommishSettingsViewController.surfaceColor
        cell.backgroundView = backgroundView
        cell.selectedBackgroundView = UIView()
        cell.contentView.backgroundColor = UIColor.clear
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.masksToBounds = false
        cell.selectionStyle = .default
        
        let buttonTag = CommishSettingsViewController.iconTag + 1
        let buttonBackground: UIView
        if let existing = cell.contentView.viewWithTag(buttonTag) {
            buttonBackground = existing
        } else {
            buttonBackground = UIView()
            buttonBackground.tag = buttonTag
            buttonBackground.isUserInteractionEnabled = false
            cell.contentView.insertSubview(buttonBackground, at: 0)
        }
        
        buttonBackground.frame = CGRect(x: 24, y: 3, width: tableView.bounds.width - 48, height: 50)
        buttonBackground.autoresizingMask = [.flexibleWidth]
        buttonBackground.backgroundColor = CommishSettingsViewController.bccRed
        buttonBackground.layer.cornerRadius = 8
        buttonBackground.layer.masksToBounds = true
        
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.white
        label.textAlignment = .left
        label.frame = CGRect(x: 68, y: 0, width: 230, height: 56)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let iconView = iconImageView(in: cell.contentView)
        iconView.frame = CGRect(x: 38, y: 13, width: 30, height: 30)
        iconView.tintColor = UIColor.white
        iconView.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        iconView.image = UIImage(systemName: "trash.fill")
    }
    
    func iconImageView(in contentView: UIView) -> UIImageView {
        if let existing = contentView.viewWithTag(CommishSettingsViewController.iconTag) as? UIImageView {
            return existing
        }
        
        let iconView = UIImageView(frame: CGRect(x: 18, y: 14, width: 30, height: 30))
        iconView.tag = CommishSettingsViewController.iconTag
        iconView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin]
        iconView.layer.cornerRadius = 8
        iconView.contentMode = .center
        contentView.addSubview(iconView)
        return iconView
    }
    
    func styleStatusLabel(_ label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = CommishSettingsViewController.bccBlue
        label.backgroundColor = CommishSettingsViewController.bccBlue.withAlphaComponent(0.10)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.frame = CGRect(x: tableView.bounds.width - 104, y: 17, width: 54, height: 24)
        label.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
    
    func styleTextField(_ textField: UITextField, width: CGFloat) {
        let x = tableView.bounds.width - width - 24
        textField.frame = CGRect(x: x, y: 12, width: width, height: 34)
        textField.autoresizingMask = [.flexibleLeftMargin]
        textField.borderStyle = .none
        textField.backgroundColor = CommishSettingsViewController.secondarySurfaceColor
        textField.textColor = CommishSettingsViewController.textColor
        textField.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .medium)
        textField.textAlignment = .center
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 0.871, green: 0.890, blue: 0.922, alpha: 1.0).cgColor
        textField.clearButtonMode = .whileEditing
    }
    
    func styleSegmentedControl(_ segmentedControl: UISegmentedControl, tint: UIColor) {
        segmentedControl.tintColor = tint
        segmentedControl.frame = CGRect(x: tableView.bounds.width - 184, y: 14, width: 160, height: 30)
        segmentedControl.autoresizingMask = [.flexibleLeftMargin]
        segmentedControl.layer.cornerRadius = 8
        
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = tint
        }
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            NSAttributedString.Key.foregroundColor: CommishSettingsViewController.secondaryTextColor
        ], for: .normal)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .selected)
    }
    
    func styleSwitch(_ switchControl: UISwitch) {
        switchControl.frame.origin.x = tableView.bounds.width - switchControl.bounds.width - 28
        switchControl.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
    }
}

private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let labelText = text else { return }
        let attributedString = NSMutableAttributedString(string: labelText.uppercased())
        attributedString.addAttribute(NSAttributedString.Key.kern,
                                      value: spacing,
                                      range: NSRange(location: 0, length: attributedString.length))
        attributedText = attributedString
    }
}

extension CommishSettingsViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        //Logic to change views?
        
        delegate?.collapseTopPanelCommishSettings()
        delegate?.changeViewCommishSettings(menu)
        
    }
}
