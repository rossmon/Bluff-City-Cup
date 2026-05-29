//
//  ScorecardCell.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 1/2/17.
//  Copyright © 2017 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

class ScorecardCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setSizes(_ front9: Bool) {
        self.nameLabel.frame = CGRect(x: self.nameLabel.frame.origin.x, y: self.nameLabel.frame.origin.y, width: self.frame.width * (129 / 667), height: self.nameLabel.frame.height)
        let width = self.one.frame.width
        let height = self.one.frame.height
        
        
        
        let start = self.nameLabel.frame.origin.x + self.nameLabel.frame.width
        let leftOver = self.frame.width - self.nameLabel.frame.width
        let offset = leftOver / 10
        
        self.one.frame = CGRect(x: start + offset * 0, y: self.one.frame.origin.y, width: width, height: height)
        self.two.frame = CGRect(x: start + offset * 1, y: self.two.frame.origin.y, width: width, height: height)
        self.three.frame = CGRect(x: start + offset * 2, y: self.three.frame.origin.y, width: width, height: height)
        self.four.frame = CGRect(x: start + offset * 3, y: self.four.frame.origin.y, width: width, height: height)
        self.five.frame = CGRect(x: start + offset * 4, y: self.five.frame.origin.y, width: width, height: height)
        self.six.frame = CGRect(x: start + offset * 5, y: self.six.frame.origin.y, width: width, height: height)
        self.seven.frame = CGRect(x: start + offset * 6, y: self.seven.frame.origin.y, width: width, height: height)
        self.eight.frame = CGRect(x: start + offset * 7, y: self.eight.frame.origin.y, width: width, height: height)
        self.nine.frame = CGRect(x: start + offset * 8, y: self.nine.frame.origin.y, width: width, height: height)
        self.inOut.frame = CGRect(x: start + offset * 9, y: self.nine.frame.origin.y, width: width, height: height)
        
        if self.frame.width < 290 {
            inOut.frame.origin.x = inOut.frame.origin.x - 3
        }
        print(self.nameLabel.frame.width)
    }
    
    func setHandicap(match: Match, tournament: Tournament, front9: Bool) {
        self.backgroundColor = UIColor.white
        self.nameLabel.text = "Handicap"
        
        let course = tournament.getCourseWithName(name: match.getCourseName())
        
        if front9 {
            self.one.text = String(course.getHole(1).getHandicap())
            self.two.text = String(course.getHole(2).getHandicap())
            self.three.text = String(course.getHole(3).getHandicap())
            self.four.text = String(course.getHole(4).getHandicap())
            self.five.text = String(course.getHole(5).getHandicap())
            self.six.text = String(course.getHole(6).getHandicap())
            self.seven.text = String(course.getHole(7).getHandicap())
            self.eight.text = String(course.getHole(8).getHandicap())
            self.nine.text = String(course.getHole(9).getHandicap())
        }
        else {
            self.one.text = String(course.getHole(10).getHandicap())
            self.two.text = String(course.getHole(11).getHandicap())
            self.three.text = String(course.getHole(12).getHandicap())
            self.four.text = String(course.getHole(13).getHandicap())
            self.five.text = String(course.getHole(14).getHandicap())
            self.six.text = String(course.getHole(15).getHandicap())
            self.seven.text = String(course.getHole(16).getHandicap())
            self.eight.text = String(course.getHole(17).getHandicap())
            self.nine.text = String(course.getHole(18).getHandicap())
        }
        self.inOut.text = ""
        
        
        self.nameLabel.textColor = UIColor.darkGray
        self.one.textColor = UIColor.darkGray
        self.two.textColor = UIColor.darkGray
        self.three.textColor = UIColor.darkGray
        self.four.textColor = UIColor.darkGray
        self.five.textColor = UIColor.darkGray
        self.six.textColor = UIColor.darkGray
        self.seven.textColor = UIColor.darkGray
        self.eight.textColor = UIColor.darkGray
        self.nine.textColor = UIColor.darkGray
        self.inOut.textColor = UIColor.darkGray
        
        self.one.backgroundColor = UIColor.white
        self.two.backgroundColor = UIColor.white
        self.three.backgroundColor = UIColor.white
        self.four.backgroundColor = UIColor.white
        self.five.backgroundColor = UIColor.white
        self.six.backgroundColor = UIColor.white
        self.seven.backgroundColor = UIColor.white
        self.eight.backgroundColor = UIColor.white
        self.nine.backgroundColor = UIColor.white
        self.inOut.backgroundColor = UIColor.white
        /*
        self.nameLabel.textColor = UIColor.black
        self.one.textColor = UIColor.black
        self.two.textColor = UIColor.black
        self.three.textColor = UIColor.black
        self.four.textColor = UIColor.black
        self.five.textColor = UIColor.black
        self.six.textColor = UIColor.black
        self.seven.textColor = UIColor.black
        self.eight.textColor = UIColor.black
        self.nine.textColor = UIColor.black
 */
    }
    
    func setYards(match: Match, tournament: Tournament, front9: Bool) {
        self.backgroundColor = UIColor.white
        self.nameLabel.text = "Yards"
        
        let course = tournament.getCourseWithName(name: match.getCourseName())
        
        if front9 {
            self.one.text = String(course.getHole(1).getLength())
            self.two.text = String(course.getHole(2).getLength())
            self.three.text = String(course.getHole(3).getLength())
            self.four.text = String(course.getHole(4).getLength())
            self.five.text = String(course.getHole(5).getLength())
            self.six.text = String(course.getHole(6).getLength())
            self.seven.text = String(course.getHole(7).getLength())
            self.eight.text = String(course.getHole(8).getLength())
            self.nine.text = String(course.getHole(9).getLength())
        }
        else {
            self.one.text = String(course.getHole(10).getLength())
            self.two.text = String(course.getHole(11).getLength())
            self.three.text = String(course.getHole(12).getLength())
            self.four.text = String(course.getHole(13).getLength())
            self.five.text = String(course.getHole(14).getLength())
            self.six.text = String(course.getHole(15).getLength())
            self.seven.text = String(course.getHole(16).getLength())
            self.eight.text = String(course.getHole(17).getLength())
            self.nine.text = String(course.getHole(18).getLength())
        }
        
        self.nameLabel.textColor = UIColor.darkGray
        self.one.textColor = UIColor.darkGray
        self.two.textColor = UIColor.darkGray
        self.three.textColor = UIColor.darkGray
        self.four.textColor = UIColor.darkGray
        self.five.textColor = UIColor.darkGray
        self.six.textColor = UIColor.darkGray
        self.seven.textColor = UIColor.darkGray
        self.eight.textColor = UIColor.darkGray
        self.nine.textColor = UIColor.darkGray
        self.inOut.textColor = UIColor.darkGray
        
        self.one.backgroundColor = UIColor.white
        self.two.backgroundColor = UIColor.white
        self.three.backgroundColor = UIColor.white
        self.four.backgroundColor = UIColor.white
        self.five.backgroundColor = UIColor.white
        self.six.backgroundColor = UIColor.white
        self.seven.backgroundColor = UIColor.white
        self.eight.backgroundColor = UIColor.white
        self.nine.backgroundColor = UIColor.white
        self.inOut.backgroundColor = UIColor.white
        /*
        self.nameLabel.textColor = UIColor.black
        self.one.textColor = UIColor.black
        self.two.textColor = UIColor.black
        self.three.textColor = UIColor.black
        self.four.textColor = UIColor.black
        self.five.textColor = UIColor.black
        self.six.textColor = UIColor.black
        self.seven.textColor = UIColor.black
        self.eight.textColor = UIColor.black
        self.nine.textColor = UIColor.black
 */
    }
    
    func setHoleNumber(front9: Bool) {
        self.backgroundColor = UIColor.white
        self.nameLabel.text = "Hole"
        
        if front9 {
            self.one.text = "1"
            self.two.text = "2"
            self.three.text = "3"
            self.four.text = "4"
            self.five.text = "5"
            self.six.text = "6"
            self.seven.text = "7"
            self.eight.text = "8"
            self.nine.text = "9"
        }
        else {
            self.one.text = "10"
            self.two.text = "11"
            self.three.text = "12"
            self.four.text = "13"
            self.five.text = "14"
            self.six.text = "15"
            self.seven.text = "16"
            self.eight.text = "17"
            self.nine.text = "18"
        }
        if front9 {self.inOut.text = "OUT"}
        else {self.inOut.text = "IN"}
        
        self.nameLabel.textColor = UIColor.darkGray
        self.one.textColor = UIColor.darkGray
        self.two.textColor = UIColor.darkGray
        self.three.textColor = UIColor.darkGray
        self.four.textColor = UIColor.darkGray
        self.five.textColor = UIColor.darkGray
        self.six.textColor = UIColor.darkGray
        self.seven.textColor = UIColor.darkGray
        self.eight.textColor = UIColor.darkGray
        self.nine.textColor = UIColor.darkGray
        self.inOut.textColor = UIColor.darkGray
        
        self.one.backgroundColor = UIColor.white
        self.two.backgroundColor = UIColor.white
        self.three.backgroundColor = UIColor.white
        self.four.backgroundColor = UIColor.white
        self.five.backgroundColor = UIColor.white
        self.six.backgroundColor = UIColor.white
        self.seven.backgroundColor = UIColor.white
        self.eight.backgroundColor = UIColor.white
        self.nine.backgroundColor = UIColor.white
        self.inOut.backgroundColor = UIColor.white
    }
    
    func setParNumber(match: Match, tournament: Tournament, front9: Bool) {
        self.nameLabel.text = "Par"
        let course = tournament.getCourseWithName(name: match.getCourseName())
        
        if front9 {
            self.one.text = String(course.getHole(1).getPar())
            self.two.text = String(course.getHole(2).getPar())
            self.three.text = String(course.getHole(3).getPar())
            self.four.text = String(course.getHole(4).getPar())
            self.five.text = String(course.getHole(5).getPar())
            self.six.text = String(course.getHole(6).getPar())
            self.seven.text = String(course.getHole(7).getPar())
            self.eight.text = String(course.getHole(8).getPar())
            self.nine.text = String(course.getHole(9).getPar())
            
            self.inOut.text = String(course.getHole(1).getPar()+course.getHole(2).getPar()+course.getHole(6).getPar()+course.getHole(3).getPar()+course.getHole(7).getPar()+course.getHole(4).getPar()+course.getHole(8).getPar()+course.getHole(5).getPar()+course.getHole(9).getPar())
        }
        else {
            self.one.text = String(course.getHole(10).getPar())
            self.two.text = String(course.getHole(11).getPar())
            self.three.text = String(course.getHole(12).getPar())
            self.four.text = String(course.getHole(13).getPar())
            self.five.text = String(course.getHole(14).getPar())
            self.six.text = String(course.getHole(15).getPar())
            self.seven.text = String(course.getHole(16).getPar())
            self.eight.text = String(course.getHole(17).getPar())
            self.nine.text = String(course.getHole(18).getPar())
            
            self.inOut.text = String(course.getHole(10).getPar()+course.getHole(12).getPar()+course.getHole(16).getPar()+course.getHole(13).getPar()+course.getHole(17).getPar()+course.getHole(14).getPar()+course.getHole(18).getPar()+course.getHole(15).getPar()+course.getHole(11).getPar())
        }
        
        self.nameLabel.textColor = UIColor.darkGray
        self.one.textColor = UIColor.darkGray
        self.two.textColor = UIColor.darkGray
        self.three.textColor = UIColor.darkGray
        self.four.textColor = UIColor.darkGray
        self.five.textColor = UIColor.darkGray
        self.six.textColor = UIColor.darkGray
        self.seven.textColor = UIColor.darkGray
        self.eight.textColor = UIColor.darkGray
        self.nine.textColor = UIColor.darkGray
        self.inOut.textColor = UIColor.darkGray
        
        self.one.backgroundColor = UIColor.white
        self.two.backgroundColor = UIColor.white
        self.three.backgroundColor = UIColor.white
        self.four.backgroundColor = UIColor.white
        self.five.backgroundColor = UIColor.white
        self.six.backgroundColor = UIColor.white
        self.seven.backgroundColor = UIColor.white
        self.eight.backgroundColor = UIColor.white
        self.nine.backgroundColor = UIColor.white
        self.inOut.backgroundColor = UIColor.white
        
    }
    
    func blueDoublesCell(match: Match, tournament: Tournament) {
            self.backgroundColor = UIColorFromRGB(0x0F296B)
            
            self.nameLabel.text = ""
            self.one.text = ""
            self.two.text = ""
            self.three.text = "-1"
            self.four.text = ""
            self.five.text = ""
            self.six.text = ""
            self.seven.text = "-1"
            self.eight.text = ""
            self.nine.text = ""
            
            self.nameLabel.textColor = UIColor.white
            self.one.textColor = UIColor.white
            self.two.textColor = UIColor.white
            self.three.textColor = UIColor.white
            self.four.textColor = UIColor.white
            self.five.textColor = UIColor.white
            self.six.textColor = UIColor.white
            self.seven.textColor = UIColor.white
            self.eight.textColor = UIColor.white
            self.nine.textColor = UIColor.white
                        
    }
        
    func playerBestBallOrSinglesCell(player: Player, oppPlayer: Player, match: Match, tournament: Tournament, front9: Bool) {
            self.inOut.text = ""
        
            var playerHandicap = 0
        
            if match.getFormat() == "Shamble" {
                playerHandicap = player.shambleHandicap(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())
            }
            else {
                playerHandicap = player.getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())
            }
        

            var oppHandicap = Int()
            if match.getFormat() == "Singles" {
                oppHandicap = oppPlayer.getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())
            }
            else {
                oppHandicap = playerHandicap
                if  match.getFormat() == "Shamble"
                {
                    for eachPlayer in match.getPlayers() {
                        if eachPlayer.shambleHandicap(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar()) < oppHandicap {
                            oppHandicap = eachPlayer.shambleHandicap(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())
                        }
                    }
                }
                else {
                    for eachPlayer in match.getPlayers() {
                        if eachPlayer.getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar()) < oppHandicap {
                            oppHandicap = eachPlayer.getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())
                        }
                    }
                }
            }
        
            let playerHandicapOriginal = playerHandicap
        
            _ = playerHandicap
            if ((playerHandicap - oppHandicap) < 0) {
                playerHandicap = 0
            }
            else {
                playerHandicap = playerHandicap - oppHandicap
            }
        
            let course = tournament.getCourseWithName(name: match.getCourseName())
            
            var holeOffset = 0
            if front9 { holeOffset = 0 }
            else { holeOffset = 9 }
            
            self.nameLabel.text = "\(player.getLastName()) (\(playerHandicapOriginal))"
            //self.nameLabel.text = player.getLastName()
            self.one.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(1 + holeOffset).getHandicap())
            self.two.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(2 + holeOffset).getHandicap())
            self.three.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(3 + holeOffset).getHandicap())
            self.four.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(4 + holeOffset).getHandicap())
            self.five.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(5 + holeOffset).getHandicap())
            self.six.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(6 + holeOffset).getHandicap())
            self.seven.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(7 + holeOffset).getHandicap())
            self.eight.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(8 + holeOffset).getHandicap())
            self.nine.text = handicapStrokes(playerHandicap: playerHandicap, holeHandicap: course.getHole(9 + holeOffset).getHandicap())
        
            self.nameLabel.textColor = UIColor.darkGray
            self.one.textColor = UIColor.darkGray
            self.two.textColor = UIColor.darkGray
            self.three.textColor = UIColor.darkGray
            self.four.textColor = UIColor.darkGray
            self.five.textColor = UIColor.darkGray
            self.six.textColor = UIColor.darkGray
            self.seven.textColor = UIColor.darkGray
            self.eight.textColor = UIColor.darkGray
            self.nine.textColor = UIColor.darkGray
    
    }
    
    func doublesCell(team: String, match: Match, tournament: Tournament, front9: Bool) {
        self.inOut.text = ""
        
        let teamHandicaps = match.getTeamHandicap()
        
        var teamHandicap = 0
        var oppHandicap = 0
        if team == "Blue" {
            teamHandicap = teamHandicaps.blueTeamHandicap
            oppHandicap = teamHandicaps.redTeamHandicap
            //teamHandicap = tournament.getTeamHandicap(format: match.getFormat(), player1Handicap: match.blueTeamPlayerOne().getHandicap(), player2Handicap: match.blueTeamPlayerTwo()!.getHandicap(), courseSlope: match.getCourseSlope())
            //oppHandicap = tournament.getTeamHandicap(format: match.getFormat(), player1Handicap: match.redTeamPlayerOne().getHandicap(), player2Handicap: match.redTeamPlayerTwo()!.getHandicap(), courseSlope: match.getCourseSlope())
        }
        else if team == "Red" {
            teamHandicap = teamHandicaps.redTeamHandicap
            oppHandicap = teamHandicaps.blueTeamHandicap
            //teamHandicap = tournament.getTeamHandicap(format: match.getFormat(), player1Handicap: match.redTeamPlayerOne().getHandicap(), player2Handicap: match.redTeamPlayerTwo()!.getHandicap(), courseSlope: match.getCourseSlope())
            //oppHandicap = tournament.getTeamHandicap(format: match.getFormat(), player1Handicap: match.blueTeamPlayerOne().getHandicap(), player2Handicap: match.blueTeamPlayerTwo()!.getHandicap(), courseSlope: match.getCourseSlope())
        }
        
        let teamHandicapOriginal = teamHandicap
        if ((teamHandicap - oppHandicap) < 0) {
            teamHandicap = 0
        }
        else {
            teamHandicap = teamHandicap - oppHandicap
        }
        
        let course = tournament.getCourseWithName(name: match.getCourseName())
        
        var holeOffset = 0
        if front9 { holeOffset = 0 }
        else { holeOffset = 9 }
        
        self.nameLabel.text = team + " (\(teamHandicapOriginal))"
        /*
        if team == "Blue" {
            let bluePlayer1Name = match.blueTeamPlayerOne().getName().split{$0 == " "}.map(String.init)
            let bluePlayer2Name = match.blueTeamPlayerTwo()!.getName().split{$0 == " "}.map(String.init)
            
            self.nameLabel.text = "\(bluePlayer1Name[1])/\(bluePlayer2Name[1]) (\(teamHandicapOriginal))"
        }
        else if team == "Red" {
            let redPlayer1Name = match.redTeamPlayerOne().getName().split{$0 == " "}.map(String.init)
            let redPlayer2Name = match.redTeamPlayerTwo()!.getName().split{$0 == " "}.map(String.init)
            
            self.nameLabel.text = "\(redPlayer1Name[1])/\(redPlayer2Name[1]) (\(teamHandicapOriginal))"
        }*/
        
        self.one.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(1 + holeOffset).getHandicap())
        self.two.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(2 + holeOffset).getHandicap())
        self.three.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(3 + holeOffset).getHandicap())
        self.four.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(4 + holeOffset).getHandicap())
        self.five.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(5 + holeOffset).getHandicap())
        self.six.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(6 + holeOffset).getHandicap())
        self.seven.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(7 + holeOffset).getHandicap())
        self.eight.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(8 + holeOffset).getHandicap())
        self.nine.text = handicapStrokes(playerHandicap: teamHandicap, holeHandicap: course.getHole(9 + holeOffset).getHandicap())
        
        
        self.nameLabel.textColor = UIColor.darkGray
        self.one.textColor = UIColor.darkGray
        self.two.textColor = UIColor.darkGray
        self.three.textColor = UIColor.darkGray
        self.four.textColor = UIColor.darkGray
        self.five.textColor = UIColor.darkGray
        self.six.textColor = UIColor.darkGray
        self.seven.textColor = UIColor.darkGray
        self.eight.textColor = UIColor.darkGray
        self.nine.textColor = UIColor.darkGray

    }
    
    
    func blankCellFormatting() {
        self.backgroundColor = UIColor.white
        self.nameLabel.text = ""
        self.one.text = ""
        self.two.text = ""
        self.three.text = ""
        self.four.text = ""
        self.five.text = ""
        self.six.text = ""
        self.seven.text = ""
        self.eight.text = ""
        self.nine.text = ""
        self.inOut.text = ""
        self.one.backgroundColor = UIColor.white
        self.two.backgroundColor = UIColor.white
        self.three.backgroundColor = UIColor.white
        self.four.backgroundColor = UIColor.white
        self.five.backgroundColor = UIColor.white
        self.six.backgroundColor = UIColor.white
        self.seven.backgroundColor = UIColor.white
        self.eight.backgroundColor = UIColor.white
        self.nine.backgroundColor = UIColor.white
        self.inOut.backgroundColor = UIColor.white
        self.nameLabel.backgroundColor = UIColor.white
    }
    
    func handicapStrokes(playerHandicap: Int, holeHandicap: Int) -> String {
        
        
        if playerHandicap >= 36 {
            if (playerHandicap - 36) >= holeHandicap {
                return "3"
            }
            else {
                return "2"
            }
        }
        else if playerHandicap >= 18 {
            if (playerHandicap - 18) >= holeHandicap {
                return "2"
            }
            else {
                return "1"
            }
        }
        else {
            if playerHandicap >= holeHandicap {
                return "1"
            }
            else {
                return ""
            }
        }
    }
    
    func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var one: UILabel!
    @IBOutlet weak var two: UILabel!
    @IBOutlet weak var three: UILabel!
    @IBOutlet weak var four: UILabel!
    @IBOutlet weak var five: UILabel!
    @IBOutlet weak var six: UILabel!
    @IBOutlet weak var seven: UILabel!
    @IBOutlet weak var eight: UILabel!
    @IBOutlet weak var nine: UILabel!
    @IBOutlet weak var inOut: UILabel!
}
