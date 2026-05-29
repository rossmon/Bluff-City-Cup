//
//  MatchTableViewCell18.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 7/4/22.
//  Copyright © 2022 Jumpstop Creations. All rights reserved.
//

import UIKit
import Charts
import SwiftUI

protocol MatchTableViewCellDelegate: AnyObject {
    func didTapBannerView(in cell: MatchTableViewCell18)
}

class ScoreboardMatchAvatarView: UIView {
    private let imageView = UIImageView()
    private let initialsLabel = UILabel()
    private var currentKey: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        layer.masksToBounds = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1.5
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        initialsLabel.textAlignment = .center
        addSubview(initialsLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            initialsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            initialsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
    
    func configure(player: Player?, color: UIColor, borderColor: UIColor? = nil) {
        guard let player = player else {
            isHidden = true
            return
        }
        
        isHidden = false
        let accentColor = borderColor ?? color
        let cacheKey = player.getName().lowercased().replacingOccurrences(of: " ", with: "_")
        currentKey = cacheKey
        
        imageView.image = nil
        imageView.backgroundColor = color.withAlphaComponent(0.13)
        imageView.layer.borderColor = accentColor.cgColor
        initialsLabel.text = initials(for: player.getName())
        initialsLabel.textColor = accentColor
        initialsLabel.isHidden = false
        
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
                guard self.currentKey == cacheKey else { return }
                self.imageView.image = image
                self.initialsLabel.isHidden = true
            }
        }.resume()
    }
    
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}

class MatchTableViewCell18: UITableViewCell {

    
    
    weak var delegate: MatchTableViewCellDelegate?
    
    
    var holeLabelArray = [UILabel]()
    var match: Match?
    private let bluePredictionDot = UIView()
    private let tiePredictionDot = UIView()
    private let redPredictionDot = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Add tap gesture recognizer to the specific view you want to recognize taps on
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBannerViewTap))
        matchBanner.addGestureRecognizer(tapGesture)
        matchBanner.isUserInteractionEnabled = true  // Enable interaction on the view
        

        
        self.allCellView.layer.cornerRadius = 10.0
        
        self.shadowView.backgroundColor = .clear
        self.shadowView.layer.backgroundColor = UIColor.clear.cgColor
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.10
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowView.layer.shadowRadius = 7
        self.allCellView.layer.masksToBounds = true
        

        
        holeLabelArray = [self.hole1,self.hole2,self.hole3,self.hole4,self.hole5,self.hole6,self.hole7,self.hole8,self.hole9,self.hole10,self.hole11,self.hole12,self.hole13,self.hole14,self.hole15,self.hole16,self.hole17,self.hole18]
        
        for i in 0...(holeLabelArray.count-1) {
            holeLabelArray[i].layer.cornerRadius = 0.5 * (holeLabelArray[i].bounds.size.width )
            holeLabelArray[i].layer.masksToBounds = true
        }
        
        self.matchBanner.addBottomBorderWithColor(color: UIColorFromRGB(0xE5E9F0), width: 1.0)
        
        
        self.bluePredictionLabel.text = ""
        self.redPredictionLabel.text = ""
        self.tiePredictionLabel.text = ""
        configurePredictionLegendRows()
        
        super.awakeFromNib()
        self.predictionView.isHidden = true
        self.predictionViewHeightConstraint.constant = 0
        self.layoutIfNeeded() // Force layout pass
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Handler method for tap gesture
    @objc func handleBannerViewTap() {
        // Perform your action, like toggling the prediction view
        delegate?.didTapBannerView(in: self)
            
    }
    
    func configureScoreboardAvatars(match: Match) {
        // Avatars removed — names use their original storyboard positions
    }

    //Views
    @IBOutlet weak var allCellView: UIView!
    @IBOutlet weak var blueTeamNames: UIView!
    @IBOutlet weak var redTeamNames: UIView!
    @IBOutlet weak var blueTeamTriangle: UIView!
    @IBOutlet weak var redTeamTriangle: UIView!
    @IBOutlet weak var matchBanner: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    //Score Labels
    @IBOutlet weak var tiedLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var roundMatchLabel: UILabel!
    @IBOutlet weak var finalLabel: UILabel!
    
    //Name Labels
    @IBOutlet weak var blueSingleFirstName: UILabel!
    @IBOutlet weak var blueSingleLastName: UILabel!
    @IBOutlet weak var redSingleFirstName: UILabel!
    @IBOutlet weak var redSingleLastName: UILabel!
    
    @IBOutlet weak var blueDoubleFirstName1: UILabel!
    @IBOutlet weak var blueDoubleLastName1: UILabel!
    @IBOutlet weak var blueDoubleFirstName2: UILabel!
    @IBOutlet weak var blueDoubleLastName2: UILabel!
    @IBOutlet weak var redDoubleFirstName1: UILabel!
    @IBOutlet weak var redDoubleLastName1: UILabel!
    @IBOutlet weak var redDoubleFirstName2: UILabel!
    @IBOutlet weak var redDoubleLastName2: UILabel!

    //Holes
    @IBOutlet weak var hole1: UILabel!
    @IBOutlet weak var hole2: UILabel!
    @IBOutlet weak var hole3: UILabel!
    @IBOutlet weak var hole4: UILabel!
    @IBOutlet weak var hole5: UILabel!
    @IBOutlet weak var hole6: UILabel!
    @IBOutlet weak var hole7: UILabel!
    @IBOutlet weak var hole8: UILabel!
    @IBOutlet weak var hole9: UILabel!
    @IBOutlet weak var hole10: UILabel!
    @IBOutlet weak var hole11: UILabel!
    @IBOutlet weak var hole12: UILabel!
    @IBOutlet weak var hole13: UILabel!
    @IBOutlet weak var hole14: UILabel!
    @IBOutlet weak var hole15: UILabel!
    @IBOutlet weak var hole16: UILabel!
    @IBOutlet weak var hole17: UILabel!
    @IBOutlet weak var hole18: UILabel!
    @IBOutlet weak var redPredictionLabel: UILabel!
    @IBOutlet weak var tiePredictionLabel: UILabel!
    @IBOutlet weak var bluePredictionLabel: UILabel!
    
    @IBOutlet weak var predictionView: UIView!
    @IBOutlet weak var carrotButton: UIButton!
    
    @IBOutlet weak var predictionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chartContainerView: UIView!
    
    var togglePredictionViewCallback: (() -> Void)?
    
    /*
    struct ProbabilityData: Identifiable {
        let id = UUID()
        let holeNumber: Int
        let blueWinProbability: Double
        let redWinProbability: Double
        let tieProbability: Double
    }*/
    // Called before the cell is reused
        override func prepareForReuse() {
            super.prepareForReuse()
            
            // Remove any existing subviews in the chart container
            chartContainerView.subviews.forEach { $0.removeFromSuperview() }
            
        // Reset dynamic properties or UI elements
        bluePredictionLabel.text = ""
        redPredictionLabel.text = ""
        tiePredictionLabel.text = ""
        configurePredictionLegendRows()
        
        // Reset any expandable views to initial collapsed state
        setPredictionViewVisibility(false)
        predictionViewHeightConstraint.constant = 0
        }
    
    // MatchPredictionData, PredictionPerHole, ProbabilityChartView, ProbabilityChartRepresentable
    // are defined in WinProbabilityChart.swift
    
    func configureChart(with data: [MatchPredictionData]) {
        let chartView = ProbabilityChartRepresentable(data: data)
        let hostingController = UIHostingController(rootView: chartView)
        
        // Add the hosting controller as a child
        if let parentViewController = parentViewController {
            parentViewController.addChild(hostingController)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            // Remove previous chart views if any exist (for added safety)
            chartContainerView.subviews.forEach { $0.removeFromSuperview() }
            
            chartContainerView.addSubview(hostingController.view)
            
            
            
            // Add the new chart view to the container
            if let parentViewController = self.parentViewController {
                        parentViewController.addChild(hostingController)
                        chartContainerView.addSubview(hostingController.view)
                        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                        
                        // Apply layout constraints
                        NSLayoutConstraint.activate([
                            hostingController.view.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
                            hostingController.view.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
                            hostingController.view.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
                            hostingController.view.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor)
                        ])
                        
                        // Notify the parent that the hosting controller has been added
                        hostingController.didMove(toParent: parentViewController)
                    }
        }
    }
    
    
    func cleanupForReuse() {
        self.blueTeamTriangle.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        self.redTeamTriangle.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        
        for i in 0...holeLabelArray.count - 1 {
            holeLabelArray[i].layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        }

    }
    
    
    func setPredictionViewVisibility(_ isExpanded: Bool) {
        
        predictionView.isHidden = !isExpanded
        predictionViewHeightConstraint.constant = isExpanded ? 247 : 0
        carrotButton.transform = isExpanded ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
        configurePredictionLegendRows()
        DispatchQueue.main.async {
            self.updatePredictionVisuals()
        }
        layoutIfNeeded()
        
            /*predictionView.isHidden = !isExpanded
            predictionViewHeightConstraint.constant = isExpanded ? 247 : 0
            carrotButton.transform = isExpanded ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
            updatePredictionVisuals()
            layoutIfNeeded()
            
            // Force a layout update on the table view to adjust row height
            if let tableView = self.superview as? UITableView {
                //UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                //}
            }
*/
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configurePredictionLegendRows()
    }
    
    private func configurePredictionLegendRows() {
        let blueColor = UIColorFromRGB(0x0F296B)
        let tieColor = UIColorFromRGB(0x5A6272)
        let redColor = UIColorFromRGB(0xB70A1C)
        
        let rows: [(String, UILabel, UIView, UIColor, CGFloat)] = [
            ("BLUE", bluePredictionLabel, bluePredictionDot, blueColor, 151),
            ("TIE", tiePredictionLabel, tiePredictionDot, tieColor, 177),
            ("RED", redPredictionLabel, redPredictionDot, redColor, 203)
        ]
        
        rows.forEach { teamCode, percentageLabel, dotView, color, y in
            if dotView.superview == nil {
                predictionView.addSubview(dotView)
            }
            dotView.backgroundColor = color
            dotView.layer.cornerRadius = 4
            dotView.frame = CGRect(x: 24, y: y + 5, width: 8, height: 8)
            
            if let teamLabel = predictionView.findLabel(withText: teamCode) {
                teamLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
                teamLabel.textColor = color
                teamLabel.textAlignment = .left
                teamLabel.frame = CGRect(x: 38, y: y, width: 70, height: 18)
            }
            
            percentageLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
            percentageLabel.textColor = color
            percentageLabel.textAlignment = .right
            percentageLabel.frame = CGRect(x: predictionView.bounds.width - 104, y: y, width: 84, height: 18)
        }
    }
    
    func updatePredictionVisuals() {
        if !self.predictionView.isHidden {
            if self.match != nil {
                
                var matchProbabilities = [MatchPredictionData]()
                var blueHoleProbabilities = [PredictionPerHole]()
                var redHoleProbabilities = [PredictionPerHole]()
                var tieHoleProbabilities = [PredictionPerHole]()
                
                let status = self.match?.getMatchCompletionDetails()
                let probabilities = Model.sharedInstance.tournament.getMatchWinProbabilities(forFormat: self.match!.getFormat(), matchLength: self.match!.getMatchLength(), startingHole: self.match!.getStartingHole(),scoreDiffs: status!.scoreDiffs)
                
                for each in probabilities {
                    if let currentHole = self.match?.getCurrentHole(), each.hole == currentHole || (each.hole == status?.lastHoleCompleted && status?.matchFinished == true) {
                        
                        if each.hole == status?.lastHoleCompleted && status?.matchFinished == true {
                            if status?.matchWinner == "Blue" {
                                self.bluePredictionLabel.text = "100.0%"
                                self.redPredictionLabel.text = "0.0%"
                                self.tiePredictionLabel.text = "0.0%"
                                self.layoutIfNeeded()
                            }
                            else if status?.matchWinner == "Red" {
                                self.bluePredictionLabel.text = "0.0%"
                                self.redPredictionLabel.text = "100.0%"
                                self.tiePredictionLabel.text = "0.0%"
                                self.layoutIfNeeded()
                            }
                            else {
                                self.bluePredictionLabel.text = "0.0%"
                                self.redPredictionLabel.text = "0.0%"
                                self.tiePredictionLabel.text = "100.0%"
                                self.layoutIfNeeded()
                            }
                        }
                        else {
                            self.bluePredictionLabel.text = "\(round(10*100*each.blueWinProbability)/10.0)%"
                            self.redPredictionLabel.text = "\(round(10*100*each.redWinProbability)/10.0)%"
                            self.tiePredictionLabel.text = "\(round(10*100*each.tieProbability)/10.0)%"
                            self.layoutIfNeeded()
                        }
                    }
                    
                    blueHoleProbabilities.append(PredictionPerHole(hole: each.hole,probability: round(10*100*each.blueWinProbability)/10.0))
                    redHoleProbabilities.append(PredictionPerHole(hole: each.hole,probability: round(10*100*each.redWinProbability)/10.0))
                    tieHoleProbabilities.append(PredictionPerHole(hole: each.hole,probability: round(10*100*each.tieProbability)/10.0))
                    
                }
                
                if status!.matchFinished && status!.lastHoleCompleted < self.match!.getMatchLength() {
                    if status?.matchWinner == "Blue" {
                        blueHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 100.0))
                        redHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 0.0))
                        tieHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 0.0))
                        
                    }
                    else if status?.matchWinner == "Red" {
                        redHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 100.0))
                        blueHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 0.0))
                        tieHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 0.0))
                    }
                    else {
                        tieHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 100.0))
                        blueHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 0.0))
                        redHoleProbabilities.append(PredictionPerHole(hole: status!.lastHoleCompleted + 1,probability: 0.0))
                    }
                }
                
                matchProbabilities.append(MatchPredictionData(team: "Blue", probabilities: blueHoleProbabilities))
                matchProbabilities.append(MatchPredictionData(team: "Red", probabilities: redHoleProbabilities))
                matchProbabilities.append(MatchPredictionData(team: "Tie", probabilities: tieHoleProbabilities))
                
                self.configureChart(with: matchProbabilities)
                
                // This tells the table view to refresh the layout of the cell
                if let tableView = self.superview as? UITableView {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
        }
    }

    @IBAction func togglePredictionView(_ sender: Any) {
        togglePredictionViewCallback?()
        DispatchQueue.main.async {
            self.updatePredictionVisuals()
        }
        
        
        /*
         // Determine if expanding or collapsing
             let isExpanding = predictionViewHeightConstraint.constant == 0
             
             // Adjust predictionView height and button rotation based on state
             predictionView.isHidden = !isExpanding
             predictionView.alpha = isExpanding ? 0 : 1 // Fade in when expanding

             UIView.animate(withDuration: 0.3, animations: {
                 // Adjust the height constraint based on state
                 self.predictionViewHeightConstraint.constant = isExpanding ? 247 : 0
                 self.carrotButton.transform = isExpanding ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
                 self.layoutIfNeeded()
             }, completion: { _ in
                 // Notify the table view to re-evaluate the layout
                 if let tableView = self.superview as? UITableView {
                     tableView.beginUpdates()
                     tableView.endUpdates()
                     
                     // Optionally, reload the specific cell to ensure it refreshes
                     if let indexPath = tableView.indexPath(for: self) {
                         tableView.reloadRows(at: [indexPath], with: .none)
                     }
                 }
             })*/
         
        
        /*
                Model.sharedInstance.fetchMatchProbabilitiesJSON(tournamentName: Model.sharedInstance.tournament.getName(), round: match?.getRound() ?? 0, match: match?.getMatchNumber() ?? 0) { probabilityRecords, error in
                    
                    DispatchQueue.main.async {
                        if let records = probabilityRecords {
                            self.match?.setMatchProbabilities(records)
                            
                        } else if let error = error {
                            print("Error fetching match probabilities: \(error)")
                        }
                        //print(self.match!.getMatchProbabilities())
                        
                        
                        //Setup prediction labels
                        let matchStatus = self.match!.getMatchProbabilitiesCompleted()
                        
                        var matchProbabilities = [MatchPredictionData]()
                        var blueHoleProbabilities = [PredictionPerHole]()
                        var redHoleProbabilities = [PredictionPerHole]()
                        var tieHoleProbabilities = [PredictionPerHole]()
                        
                        let status = self.match?.getMatchCompletionDetails()
                        
                        for each in matchStatus {
                            if let currentHole = self.match?.getCurrentHole(), each.hole == currentHole || (each.hole == status?.lastHoleCompleted && status?.matchFinished == true) {
                                
                                self.bluePredictionLabel.text = "\(round(10*100*each.blueWinProbability)/10.0)%"
                                self.redPredictionLabel.text = "\(round(10*100*each.redWinProbability)/10.0)%"
                                self.tiePredictionLabel.text = "\(round(10*100*each.tieProbability)/10.0)%"
                                self.layoutIfNeeded()
                                
                            }
                            
                            blueHoleProbabilities.append(PredictionPerHole(hole: each.hole,probability: round(10*100*each.blueWinProbability)/10.0))
                            redHoleProbabilities.append(PredictionPerHole(hole: each.hole,probability: round(10*100*each.redWinProbability)/10.0))
                            tieHoleProbabilities.append(PredictionPerHole(hole: each.hole,probability: round(10*100*each.tieProbability)/10.0))
                            
                            
                            

                            
                            //matchProbabilities.append(ProbabilityData(holeNumber: each.hole, blueWinProbability: round(10*100*each.blueWinProbability)/10.0, redWinProbability: round(10*100*each.redWinProbability)/10.0, tieProbability: round(10*100*each.tieProbability)/10.0))
                        }
                        
                        matchProbabilities.append(MatchPredictionData(team: "Blue", probabilities: blueHoleProbabilities))
                        matchProbabilities.append(MatchPredictionData(team: "Red", probabilities: redHoleProbabilities))
                        matchProbabilities.append(MatchPredictionData(team: "Tie", probabilities: tieHoleProbabilities))
                        
                       
                        self.configureChart(with: matchProbabilities)
                        
                    }
                }*/
        
        
    }
    func setHoleBackgroundColor(_ holeNumber: Int,color: UIColor) {
        let hole = self.holeLabelArray[holeNumber - 1]
        hole.backgroundColor = color
    }
    func setHoleTextColor(_ holeNumber: Int,color: UIColor) {
        let hole = self.holeLabelArray[holeNumber - 1]
        hole.textColor = color
    }
    
    func holeNotNeeded(_ holeNumber: Int) {
        let hole = self.holeLabelArray[holeNumber - 1]
        
        hole.textColor = UIColor.black
        hole.backgroundColor = UIColorFromRGB(0xDCDCDC)
       
        let linePath = UIBezierPath()
        linePath.move(to:CGPoint(x:0, y:hole.bounds.height))
        linePath.addLine(to:CGPoint(x:hole.bounds.width, y:0))

            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.lineWidth = 2
            lineLayer.strokeColor = UIColor.black.cgColor
            hole.layer.addSublayer(lineLayer)
        
    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func setBlueTriangle(color: UIColor){
        let width = self.blueTeamTriangle.frame.size.width
        let height = self.blueTeamTriangle.frame.size.height//you can use triangleView.frame.size.height
            let path = CGMutablePath()

            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x:width, y: height/2))
            path.addLine(to: CGPoint(x:0, y:height))
            path.addLine(to: CGPoint(x:0, y:0))

            let shape = CAShapeLayer()
            shape.path = path
            shape.fillColor = color.cgColor

            self.blueTeamTriangle.layer.addSublayer(shape)
        }
    
    func setRedTriangle(color: UIColor){
        
            let width = self.redTeamTriangle.frame.size.width
            let height = self.redTeamTriangle.frame.size.height//you can use triangleView.frame.size.height
            let path = CGMutablePath()

            path.move(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x:0, y: height/2))
            path.addLine(to: CGPoint(x:width, y:height))
            path.addLine(to: CGPoint(x:width, y:0))

            let shape = CAShapeLayer()
            shape.path = path
            shape.fillColor = color.cgColor

            self.redTeamTriangle.layer.addSublayer(shape)
        }
}

extension UIView {
  func addTopBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
      border.backgroundColor = color.cgColor
      border.frame = CGRect(x:0, y:0, width:self.frame.size.width, height:width)
    self.layer.addSublayer(border)
  }

  func addRightBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
      border.backgroundColor = color.cgColor
      border.frame = CGRect(x:self.frame.size.width - width, y:0, width:width, height:self.frame.size.height)
    self.layer.addSublayer(border)
  }

  func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
      border.backgroundColor = color.cgColor
      border.frame = CGRect(x:0, y:self.frame.size.height - width, width:self.frame.size.width, height:width)
    self.layer.addSublayer(border)
  }

  func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
    let border = CALayer()
      border.backgroundColor = color.cgColor
      border.frame = CGRect(x:0, y:0, width:width, height:self.frame.size.height)
    self.layer.addSublayer(border)
  }
  var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            responder = next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func findLabel(withText text: String) -> UILabel? {
        for subview in subviews {
            if let label = subview as? UILabel, label.text == text {
                return label
            }
            if let label = subview.findLabel(withText: text) {
                return label
            }
        }
        return nil
    }
    
  
    	
}
