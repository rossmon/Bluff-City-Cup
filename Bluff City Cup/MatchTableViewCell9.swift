//
//  MatchTableViewCell9.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 7/5/22.
//  Copyright © 2022 Jumpstop Creations. All rights reserved.
//

import UIKit
import Charts
import SwiftUI

protocol MatchTableViewCell9Delegate: AnyObject {
    func didTapBannerView(in cell: MatchTableViewCell9)
}

class MatchTableViewCell9: UITableViewCell {

    weak var delegate: MatchTableViewCell9Delegate?

    
    var holeLabelArray = [UILabel]()
    var match: Match?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Add tap gesture recognizer to the specific view you want to recognize taps on
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBannerViewTap))
        matchBanner.addGestureRecognizer(tapGesture)
        matchBanner.isUserInteractionEnabled = true  // Enable interaction on the view
        
        self.allCellView.layer.cornerRadius = 10.0
        
        self.shadowView.layer.backgroundColor = UIColor.clear.cgColor
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowOffset = .zero
        self.shadowView.layer.shadowRadius = 10
        self.allCellView.layer.masksToBounds = true

        
        holeLabelArray = [self.hole1,self.hole2,self.hole3,self.hole4,self.hole5,self.hole6,self.hole7,self.hole8,self.hole9]
        
        for i in 0...(holeLabelArray.count-1) {
            holeLabelArray[i].layer.cornerRadius = 0.5 * (holeLabelArray[i].bounds.size.width )
            holeLabelArray[i].layer.masksToBounds = true
        }
        
        self.matchBanner.addBottomBorderWithColor(color: UIColor.lightGray, width: 1.0)

        self.bluePredictionLabel.text = ""
        self.redPredictionLabel.text = ""
        self.tiePredictionLabel.text = ""
        
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

    @IBOutlet weak var redPredictionLabel: UILabel!
    @IBOutlet weak var tiePredictionLabel: UILabel!
    @IBOutlet weak var bluePredictionLabel: UILabel!
    
    @IBOutlet weak var predictionView: UIView!
    @IBOutlet weak var carrotButton: UIButton!
    
    @IBOutlet weak var predictionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chartContainerView: UIView!
    
    var togglePredictionViewCallback: (() -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Remove any existing subviews in the chart container
        chartContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Reset dynamic properties or UI elements
        bluePredictionLabel.text = ""
        redPredictionLabel.text = ""
        tiePredictionLabel.text = ""
        
        // Reset any expandable views to initial collapsed state
        setPredictionViewVisibility(false)
        predictionViewHeightConstraint.constant = 0
    }
    
    struct MatchPredictionData: Identifiable {
        let id = UUID()
        let team: String // e.g., "Blue", "Red"
        let probabilities: [PredictionPerHole]
    }

    struct PredictionPerHole {
        let hole: Int
        let probability: Double
    }
    
    struct ProbabilityChartView: View {
        var data: [MatchPredictionData]
        var startingHole: Int
        
        
        var body: some View {
            
            let blueColor = Color(UIColor(red: CGFloat((0x0F296B & 0xFF0000) >> 16) / 255.0,
                                                  green: CGFloat((0x0F296B & 0x00FF00) >> 8) / 255.0,
                                                  blue: CGFloat(0x0F296B & 0x0000FF) / 255.0,
                                                  alpha: 1.0))
                    
            let redColor = Color(UIColor(red: CGFloat((0xB70A1C & 0xFF0000) >> 16) / 255.0,
                                                 green: CGFloat((0xB70A1C & 0x00FF00) >> 8) / 255.0,
                                                 blue: CGFloat(0xB70A1C & 0x0000FF) / 255.0,
                                                 alpha: 1.0))
            
            Chart {
                
                // Blue Team Line
                if let blueSeries = data.first(where: { $0.team == "Blue" }) {
                    ForEach(blueSeries.probabilities, id: \.hole) { element in
                        LineMark(
                            x: .value("Hole", element.hole),
                            y: .value("Win Probability", element.probability),
                            series: .value("Team","Blue")
                        )
                        .foregroundStyle(blueColor)
                        .interpolationMethod(.linear)
                        .symbol(Circle())
                        .offset(x: 8) // Adjust this value slightly to align
                    }
                }
                
                // Red Team Line
                if let redSeries = data.first(where: { $0.team == "Red" }) {
                    ForEach(redSeries.probabilities, id: \.hole) { element in
                        LineMark(
                            x: .value("Hole", element.hole),
                            y: .value("Win Probability", element.probability),
                            series: .value("Team","Red")
                        )
                        .foregroundStyle(redColor)
                        .interpolationMethod(.linear)
                        .symbol(Circle())
                        .offset(x: 8)
                    }
                }
                
                // Tie Line
                if let tieSeries = data.first(where: { $0.team == "Tie" }) {
                    ForEach(tieSeries.probabilities, id: \.hole) { element in
                        LineMark(
                            x: .value("Hole", element.hole),
                            y: .value("Win Probability", element.probability),
                            series: .value("Team","Tie")
                        )
                        .foregroundStyle(Color.gray)
                        .interpolationMethod(.linear)
                        .symbol(Circle())
                        .offset(x: 8)
                    }
                }
            }
            .chartLegend(.hidden)
            .chartXScale(domain: startingHole...(startingHole + 9)) // Adjust for 9 holes, range is startingHole to startingHole + 8
            .chartXAxis {
                AxisMarks(values: Array(startingHole...(startingHole + 9))) { value in
                    AxisValueLabel {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)") // Display hole numbers based on startingHole
                        }
                    }
                }
            }

            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                    if let intValue = value.as(Int.self) {
                        if intValue == 0 || intValue == 50 || intValue == 100 {
                            AxisValueLabel()
                        }
                        if intValue == 25 || intValue == 75 {
                            AxisGridLine(stroke: StrokeStyle(dash: [4,4], dashPhase: 0.5))
                           
                        } else {
                            AxisGridLine() // Regular grid line
                        }
                    }
                }
            }
            .chartYScale(domain: 0...100) // Set the Y-axis scale from 0 to 100
            .frame(height: 109)
            .padding()
            
        }
    }

    func configureChart(with data: [MatchPredictionData], startingHole: Int) {
        let chartView = ProbabilityChartRepresentable(data: data, startingHole: startingHole)
        let hostingController = UIHostingController(rootView: chartView)
        
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
    
    struct ProbabilityChartRepresentable: UIViewControllerRepresentable {
        var data: [MatchPredictionData]
        var startingHole: Int

        func makeUIViewController(context: Context) -> UIViewController {
            let hostingController = UIHostingController(rootView: ProbabilityChartView(data: data, startingHole: startingHole))
            return hostingController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
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
            DispatchQueue.main.async {
                self.updatePredictionVisuals()
            }
            layoutIfNeeded()
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
                
                if status!.matchFinished && ((status!.lastHoleCompleted - self.match!.getStartingHole() + 1) < self.match!.getMatchLength()){
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
                
                if let startingHole = self.match?.getStartingHole() {
                    self.configureChart(with: matchProbabilities,startingHole: startingHole)
                }
                else {
                    self.configureChart(with: matchProbabilities,startingHole: 1)
                }
                
                
                // This tells the table view to refresh the layout of the cell
                if let tableView = self.superview as? UITableView {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
        }
    }
    
    //  IMPLEMENT togglePredictionView HERE
    @IBAction func togglePredictionView(_ sender: Any) {
        togglePredictionViewCallback?()
        DispatchQueue.main.async {
            self.updatePredictionVisuals()
        }
        
    }
    
    
    
    

    func setHoleBackgroundColor(_ holeNumber: Int,color: UIColor) {
        var holeNumberAdj = holeNumber
        if holeNumber > 9 { holeNumberAdj = holeNumber - 9 }

        let hole = self.holeLabelArray[holeNumberAdj - 1]
        hole.backgroundColor = color
    }
    func setHoleTextColor(_ holeNumber: Int,color: UIColor) {
        var holeNumberAdj = holeNumber
        if holeNumber > 9 { holeNumberAdj = holeNumberAdj - 9 }
        
        let hole = self.holeLabelArray[holeNumberAdj - 1]
        hole.textColor = color
    }
    
    func holeNotNeeded(_ holeNumber: Int) {
        var holeNumberAdj = holeNumber
        if holeNumber > 9 { holeNumberAdj = holeNumber - 9 }
        
        let hole = self.holeLabelArray[holeNumberAdj - 1]
        
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

