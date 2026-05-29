//
//  TopPanelViewController.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/13/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

@objc
protocol TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?)
}

class TopPanelViewController: UITableViewController {
    static let historicalRecordsMenuTitle = "Historical Records"
    private static let historicalRecordsURLString = "https://glizzyattheturn.app/bluffcitycup/"
    
    var user: User!
    var menuItems: [String]!
    var currentMenuItem: String?
    
    var delegate: TopPanelViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColorFromRGB(0x0F296B)
        self.menuTableView.backgroundColor = UIColorFromRGB(0x0F296B)
        self.menuTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.menuTableView.tableFooterView = UIView()
        self.menuTableView.contentInset = UIEdgeInsets.init(top: 24, left: 0, bottom: 16, right: 0)
        self.tableView.rowHeight = 58
        self.tableView.sectionHeaderHeight = 72
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    @IBOutlet weak var menuTableView: UITableView!
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MenuTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MenuTableViewCell
        
        let title = menuItems[(indexPath as NSIndexPath).row]
        cell.configure(title: title,
                       isCurrent: title == currentMenuItem,
                       isExternal: title == TopPanelViewController.historicalRecordsMenuTitle)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColorFromRGB(0x0F296B)
        
        let titleLabel = UILabel(frame: CGRect(x: 28, y: 16, width: 220, height: 44))
        titleLabel.text = "Menu"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Arial", size: 28)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.85
        headerView.addSubview(titleLabel)
        
        return headerView
    }

    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        let currentCell = tableView.cellForRow(at: indexPath!) as! MenuTableViewCell

        if currentCell.menuTitle.text == TopPanelViewController.historicalRecordsMenuTitle,
           let url = URL(string: TopPanelViewController.historicalRecordsURLString) {
            UIApplication.shared.open(url)
        }
        
        delegate?.settingSelected(currentCell.menuTitle.text!, scorecardMatch: nil)
    }
}
