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
    
    var user: User!
    var menuItems: [String]!
    
    var delegate: TopPanelViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.menuTableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        //self.menuTableView.separatorColor = UIColor.clear
        self.menuTableView.tableFooterView = UIView()
        
        self.menuTableView.backgroundColor = UIColorFromRGB(0xAAAAAA)
        self.menuTableView.contentInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 0, right: 0)
        
        self.tableView.sectionHeaderHeight = 50
        
        
        
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
        
        cell.menuTitle.text = menuItems?[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Menu"
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont(name:"Arial", size: 28)
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

        delegate?.settingSelected(currentCell.menuTitle.text!, scorecardMatch: nil)
    }
}
