//
//  MenuTableViewCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/24/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    private let externalLinkIcon = UIImageView()
    private var externalIconConfigured = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
        self.menuTitle.font = UIFont(name:"Arial", size: self.menuTitle.font.pointSize)
        self.menuTitle.isAccessibilityElement = false
        configureExternalLinkIconIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var menuTitle: UILabel!
    
    func configure(title: String, isCurrent: Bool, isExternal: Bool = false) {
        configureExternalLinkIconIfNeeded()
        
        menuTitle.text = title
        menuTitle.textColor = UIColor.white
        menuTitle.font = UIFont(name: "Arial", size: 22)
        menuTitle.adjustsFontSizeToFitWidth = true
        menuTitle.minimumScaleFactor = 0.75
        contentView.backgroundColor = isCurrent ? UIColorFromRGB(0x1B3F8E) : UIColor.clear
        externalLinkIcon.isHidden = !isExternal
        externalLinkIcon.tintColor = UIColor.white.withAlphaComponent(0.86)
        isAccessibilityElement = true
        accessibilityLabel = isExternal ? "\(title), opens website" : title
        accessibilityTraits = UIAccessibilityTraits.button
        
        if isCurrent {
            accessibilityTraits.insert(UIAccessibilityTraits.selected)
        }
    }
    
    private func configureExternalLinkIconIfNeeded() {
        guard !externalIconConfigured else { return }
        externalIconConfigured = true
        
        externalLinkIcon.translatesAutoresizingMaskIntoConstraints = false
        externalLinkIcon.image = UIImage(systemName: "arrow.up.right")
        externalLinkIcon.contentMode = .scaleAspectFit
        externalLinkIcon.isHidden = true
        contentView.addSubview(externalLinkIcon)
        
        NSLayoutConstraint.activate([
            externalLinkIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            externalLinkIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            externalLinkIcon.widthAnchor.constraint(equalToConstant: 16),
            externalLinkIcon.heightAnchor.constraint(equalToConstant: 16),
            menuTitle.trailingAnchor.constraint(lessThanOrEqualTo: externalLinkIcon.leadingAnchor, constant: -12)
        ])
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
