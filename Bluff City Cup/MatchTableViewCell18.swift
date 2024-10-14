//
//  MatchTableViewCell18.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 7/4/22.
//  Copyright © 2022 Jumpstop Creations. All rights reserved.
//

import UIKit

class MatchTableViewCell18: UITableViewCell {

    var holeLabelArray = [UILabel]()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.allCellView.layer.cornerRadius = 10.0
        
        self.shadowView.layer.backgroundColor = UIColor.clear.cgColor
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowOffset = .zero
        self.shadowView.layer.shadowRadius = 10
        self.allCellView.layer.masksToBounds = true

        
        holeLabelArray = [self.hole1,self.hole2,self.hole3,self.hole4,self.hole5,self.hole6,self.hole7,self.hole8,self.hole9,self.hole10,self.hole11,self.hole12,self.hole13,self.hole14,self.hole15,self.hole16,self.hole17,self.hole18]
        
        for i in 0...(holeLabelArray.count-1) {
            holeLabelArray[i].layer.cornerRadius = 0.5 * (holeLabelArray[i].bounds.size.width )
            holeLabelArray[i].layer.masksToBounds = true
        }
        
        self.matchBanner.addBottomBorderWithColor(color: UIColor.lightGray, width: 1.0)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    func cleanupForReuse() {
        self.blueTeamTriangle.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        self.redTeamTriangle.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        
        for i in 0...holeLabelArray.count - 1 {
            holeLabelArray[i].layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        }

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
    
  
    	
}
