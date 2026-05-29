//
//  IndividualMatchTableViewCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/16/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import UIKit

private final class VerticallyCenteredLabel: UILabel {
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        rect.origin.y = bounds.origin.y + max(0, (bounds.height - rect.height) / 2)
        rect.origin.x = bounds.origin.x
        rect.size.width = bounds.width
        return rect
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines))
    }
}

class IndividualMatchTableViewCell: UITableViewCell {
    
    private let primaryAvatar = UIImageView()
    private let secondaryAvatar = UIImageView()
    private let primaryInitials = UILabel()
    private let secondaryInitials = UILabel()
    private var avatarConstraintsConfigured = false
    private var singlePlayerNameConstraint: NSLayoutConstraint?
    private var teamPlayerNameConstraint: NSLayoutConstraint?
    private var playerNameTrailingConstraint: NSLayoutConstraint?
    private var scoreLayoutConfigured = false
    private var primaryAvatarKey: String?
    private var secondaryAvatarKey: String?
    private let scoreColumnWidth: CGFloat = 70
    private let scoreColumnTrailingInset: CGFloat = 14

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
        
        replacePlayerNameLabelIfNeeded()
        self.playerName.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.playerName.numberOfLines = 2
        self.playerName.lineBreakMode = .byTruncatingTail
        self.playerName.adjustsFontSizeToFitWidth = false
        self.playerName.textAlignment = .left
        self.playerName.clipsToBounds = true
        self.playerName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.playerScore.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
        self.scoreLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.playerScore.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.playerName.textColor = UIColorFromRGB(0x172033)
        self.playerScore.textColor = UIColorFromRGB(0x172033)
        self.scoreLabel.textColor = UIColorFromRGB(0x5A6272)
        
        self.cellView.layer.cornerRadius = 10.0
        self.cellView.layer.borderWidth = 1.25
        self.cellView.layer.masksToBounds = true
        self.shadowView.backgroundColor = .clear
        self.shadowView.clipsToBounds = false
        self.shadowView.layer.backgroundColor = UIColor.clear.cgColor
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.12
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowView.layer.shadowRadius = 7
        
        setupAvatarViews()
        setupScoreValueLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        primaryAvatar.image = nil
        secondaryAvatar.image = nil
        primaryInitials.text = nil
        secondaryInitials.text = nil
        primaryInitials.isHidden = false
        secondaryInitials.isHidden = false
        secondaryAvatar.isHidden = true
        secondaryInitials.isHidden = true
        primaryAvatarKey = nil
        secondaryAvatarKey = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let shadowRect = shadowView.bounds.insetBy(dx: 2, dy: 2)
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowRect, cornerRadius: cellView.layer.cornerRadius).cgPath
        applyPrimaryAvatarMask()
        alignPlayerNameColumn()
        alignScoreColumn()
    }

    /// Clips the primary avatar so it doesn't peek through behind the secondary.
    /// Uses an even-odd mask: primary circle minus the secondary circle area.
    private func applyPrimaryAvatarMask() {
        guard !secondaryAvatar.isHidden else {
            primaryAvatar.layer.mask = nil
            return
        }

        let maskLayer = CAShapeLayer()

        // Full circle for the primary avatar
        let fullPath = UIBezierPath(ovalIn: primaryAvatar.bounds)

        // Secondary avatar's frame converted to primary avatar's coordinate space
        let secondaryInPrimary = primaryAvatar.convert(secondaryAvatar.bounds, from: secondaryAvatar)
        let cutoutPath = UIBezierPath(ovalIn: secondaryInPrimary)

        fullPath.append(cutoutPath)
        fullPath.usesEvenOddFillRule = true

        maskLayer.path = fullPath.cgPath
        maskLayer.fillRule = .evenOdd
        primaryAvatar.layer.mask = maskLayer
    }
    
    func applyTeamColor(_ color: UIColor) {
        cellView.backgroundColor = UIColorFromRGB(0xFBFCFF)
        cellView.layer.borderColor = color.withAlphaComponent(0.58).cgColor
        shadowView.layer.shadowColor = color.cgColor
        shadowView.layer.shadowOpacity = 0.16
        playerScore.textColor = color
        scoreLabel.textColor = color.withAlphaComponent(0.85)
        [primaryAvatar, secondaryAvatar].forEach { imageView in
            imageView.backgroundColor = color.withAlphaComponent(0.12)
            imageView.layer.borderColor = color.withAlphaComponent(0.72).cgColor
        }
        [primaryInitials, secondaryInitials].forEach { label in
            label.textColor = color
        }
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.clear
    }
    
    func configureAvatars(players: [Player]) {
        guard let firstPlayer = players.first else { return }
        
        primaryInitials.isHidden = false
        primaryInitials.text = initials(for: firstPlayer.getName())
        primaryAvatarKey = avatarCacheKey(for: firstPlayer.getName())
        loadAvatar(for: firstPlayer, into: primaryAvatar, initialsLabel: primaryInitials, expectedKey: primaryAvatarKey)
        
        if players.count > 1 {
            let secondPlayer = players[1]
            secondaryInitials.isHidden = false
            secondaryInitials.text = initials(for: secondPlayer.getName())
            secondaryAvatar.isHidden = false
            secondaryInitials.isHidden = false
            secondaryAvatarKey = avatarCacheKey(for: secondPlayer.getName())
            loadAvatar(for: secondPlayer, into: secondaryAvatar, initialsLabel: secondaryInitials, expectedKey: secondaryAvatarKey)
            singlePlayerNameConstraint?.isActive = false
            teamPlayerNameConstraint?.isActive = true
        }
        else {
            secondaryAvatar.isHidden = true
            secondaryInitials.isHidden = true
            secondaryAvatarKey = nil
            teamPlayerNameConstraint?.isActive = false
            singlePlayerNameConstraint?.isActive = true
        }
    }
    
    private func setupAvatarViews() {
        guard !avatarConstraintsConfigured else { return }
        avatarConstraintsConfigured = true
        
        [primaryAvatar, secondaryAvatar].forEach { imageView in
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = UIColorFromRGB(0xEEF1F5)
            imageView.layer.cornerRadius = 20
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColorFromRGB(0xD7DCE5).cgColor
            imageView.layer.masksToBounds = true
            cellView.addSubview(imageView)
        }
        
        [primaryInitials, secondaryInitials].forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            label.textColor = UIColorFromRGB(0x172033)
            label.textAlignment = .center
            label.backgroundColor = .clear
            cellView.addSubview(label)
        }
        
        deactivateConstraints(in: cellView, touching: playerName)
        
        NSLayoutConstraint.activate([
            primaryAvatar.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 12),
            primaryAvatar.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            primaryAvatar.widthAnchor.constraint(equalToConstant: 40),
            primaryAvatar.heightAnchor.constraint(equalTo: primaryAvatar.widthAnchor),
            
            secondaryAvatar.leadingAnchor.constraint(equalTo: primaryAvatar.leadingAnchor, constant: 32),
            secondaryAvatar.centerYAnchor.constraint(equalTo: primaryAvatar.centerYAnchor),
            secondaryAvatar.widthAnchor.constraint(equalTo: primaryAvatar.widthAnchor),
            secondaryAvatar.heightAnchor.constraint(equalTo: primaryAvatar.heightAnchor),
            
            primaryInitials.centerXAnchor.constraint(equalTo: primaryAvatar.centerXAnchor),
            primaryInitials.centerYAnchor.constraint(equalTo: primaryAvatar.centerYAnchor),
            primaryInitials.widthAnchor.constraint(equalTo: primaryAvatar.widthAnchor),
            
            secondaryInitials.centerXAnchor.constraint(equalTo: secondaryAvatar.centerXAnchor),
            secondaryInitials.centerYAnchor.constraint(equalTo: secondaryAvatar.centerYAnchor),
            secondaryInitials.widthAnchor.constraint(equalTo: secondaryAvatar.widthAnchor)
        ])
        
        cellView.bringSubviewToFront(primaryAvatar)
        cellView.bringSubviewToFront(primaryInitials)
        cellView.bringSubviewToFront(secondaryAvatar)
        cellView.bringSubviewToFront(secondaryInitials)
        cellView.bringSubviewToFront(playerName)
        cellView.bringSubviewToFront(playerScore)
        cellView.bringSubviewToFront(scoreLabel)
        secondaryAvatar.isHidden = true
        secondaryInitials.isHidden = true
    }
    
    private func replacePlayerNameLabelIfNeeded() {
        guard !(playerName is VerticallyCenteredLabel),
              let superview = playerName.superview else { return }
        
        let centeredLabel = VerticallyCenteredLabel(frame: playerName.frame)
        centeredLabel.translatesAutoresizingMaskIntoConstraints = true
        centeredLabel.text = playerName.text
        centeredLabel.textColor = playerName.textColor
        centeredLabel.font = playerName.font
        centeredLabel.textAlignment = playerName.textAlignment
        centeredLabel.numberOfLines = playerName.numberOfLines
        centeredLabel.lineBreakMode = playerName.lineBreakMode
        centeredLabel.backgroundColor = playerName.backgroundColor
        centeredLabel.isOpaque = playerName.isOpaque
        centeredLabel.contentMode = playerName.contentMode
        centeredLabel.setContentHuggingPriority(playerName.contentHuggingPriority(for: .horizontal), for: .horizontal)
        centeredLabel.setContentHuggingPriority(playerName.contentHuggingPriority(for: .vertical), for: .vertical)
        centeredLabel.setContentCompressionResistancePriority(playerName.contentCompressionResistancePriority(for: .horizontal), for: .horizontal)
        centeredLabel.setContentCompressionResistancePriority(playerName.contentCompressionResistancePriority(for: .vertical), for: .vertical)
        
        playerName.removeFromSuperview()
        superview.addSubview(centeredLabel)
        playerName = centeredLabel
    }
    
    private func setupScoreValueLayout() {
        guard !scoreLayoutConfigured else { return }
        scoreLayoutConfigured = true
        
        playerName.translatesAutoresizingMaskIntoConstraints = true
        playerScore.translatesAutoresizingMaskIntoConstraints = true
        scoreLabel.translatesAutoresizingMaskIntoConstraints = true
        playerScore.textAlignment = .center
        scoreLabel.textAlignment = .center
        playerScore.clipsToBounds = true
        scoreLabel.clipsToBounds = true
        
        deactivateConstraints(in: cellView, touching: playerScore)
        deactivateConstraints(in: cellView, touching: scoreLabel)
    }

    private func alignScoreColumn() {
        guard cellView.bounds.width > 0 else { return }

        let labelHeight = ceil(scoreLabel.intrinsicContentSize.height)
        let numberHeight = ceil(playerScore.font.lineHeight)
        let totalHeight = numberHeight + labelHeight
        let columnX = cellView.bounds.width - scoreColumnTrailingInset - scoreColumnWidth
        let numberY = floor(cellView.bounds.midY - totalHeight / 2)
        let labelY = numberY + numberHeight

        playerScore.frame = CGRect(x: columnX,
                                   y: numberY,
                                   width: scoreColumnWidth,
                                   height: numberHeight)
        scoreLabel.frame = CGRect(x: columnX,
                                  y: labelY,
                                  width: scoreColumnWidth,
                                  height: labelHeight)
    }
    
    private func alignPlayerNameColumn() {
        guard cellView.bounds.width > 0 else { return }
        
        let nameLeading: CGFloat
        if secondaryAvatar.isHidden {
            nameLeading = primaryAvatar.frame.maxX + 12
        } else {
            nameLeading = secondaryAvatar.frame.maxX + 10
        }
        
        let scoreColumnX = cellView.bounds.width - scoreColumnTrailingInset - scoreColumnWidth
        let nameTrailingGap: CGFloat = 18
        let availableWidth = max(44, scoreColumnX - nameTrailingGap - nameLeading)
        let maxNameHeight = max(42, cellView.bounds.height - 12)
        let textBoundingRect = (playerName.text ?? "").boundingRect(
            with: CGSize(width: availableWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: playerName.font as Any],
            context: nil
        )
        let nameHeight = min(maxNameHeight, max(ceil(playerName.font.lineHeight), ceil(textBoundingRect.height)))
        let verticalOffset: CGFloat = (playerName.text ?? "").contains("\n") ? 0 : 2
        let nameY = floor(cellView.bounds.midY - nameHeight / 2) + verticalOffset
        
        playerName.frame = CGRect(x: nameLeading,
                                  y: nameY,
                                  width: availableWidth,
                                  height: nameHeight)
    }
    
    private func deactivateConstraints(in view: UIView, touching targetView: UIView) {
        for constraint in view.constraints {
            if constraint.firstItem === targetView || constraint.secondItem === targetView {
                constraint.isActive = false
            }
        }
        
        for constraint in targetView.constraints {
            constraint.isActive = false
        }
    }
    
    private func loadAvatar(for player: Player, into imageView: UIImageView, initialsLabel: UILabel, expectedKey: String?) {
        let cacheKey = avatarCacheKey(for: player.getName())
        
        if let cachedImage = UserDefaults.standard.object(forKey: cacheKey) as? NSData {
            imageView.image = UIImage(data: cachedImage as Data)
            initialsLabel.isHidden = imageView.image != nil
            return
        }
        
        guard let url = URL(string: "https://glizzyattheturn.app/bcc/" + cacheKey + ".png") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            if let imageData = image.pngData() {
                UserDefaults.standard.set(imageData, forKey: cacheKey)
            }
            DispatchQueue.main.async {
                let currentKey = imageView === self.primaryAvatar ? self.primaryAvatarKey : self.secondaryAvatarKey
                if expectedKey == cacheKey && currentKey == cacheKey {
                    imageView.image = image
                    initialsLabel.isHidden = true
                }
            }
        }.resume()
    }
    
    private func avatarCacheKey(for name: String) -> String {
        return name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
    
    private func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var playerName: UILabel!
    @IBOutlet weak var playerScore: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
}
