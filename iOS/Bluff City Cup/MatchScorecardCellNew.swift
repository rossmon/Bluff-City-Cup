//
//  MatchScorecardCellNew.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 7/7/22.
//  Copyright © 2022 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit

class MatchScorecardCellNew: UITableViewCell {
    
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
    
    
    var holeLabelArray = [UILabel]()

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.nameLabel.font = UIFont(name:"Arial", size: self.nameLabel.font.pointSize)
        self.one.font = UIFont(name:"Arial", size: self.one.font.pointSize)
        self.two.font = UIFont(name:"Arial", size: self.two.font.pointSize)
        self.three.font = UIFont(name:"Arial", size: self.three.font.pointSize)
        self.four.font = UIFont(name:"Arial", size: self.four.font.pointSize)
        self.five.font = UIFont(name:"Arial", size: self.five.font.pointSize)
        self.six.font = UIFont(name:"Arial", size: self.six.font.pointSize)
        self.seven.font = UIFont(name:"Arial", size: self.seven.font.pointSize)
        self.eight.font = UIFont(name:"Arial", size: self.eight.font.pointSize)
        self.nine.font = UIFont(name:"Arial", size: self.nine.font.pointSize)
        self.inOut.font = UIFont(name:"Arial", size: self.inOut.font.pointSize)
        
        
        holeLabelArray = [self.one,self.two,self.three,self.four,self.five,self.six,self.seven,self.eight,self.nine]
        
        for i in 0...(holeLabelArray.count-1) {
            holeLabelArray[i].layer.cornerRadius = 0.5 * (holeLabelArray[i].bounds.size.width )
            holeLabelArray[i].layer.masksToBounds = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setHandicap(match: Match, tournament: Tournament, front9: Bool) {
        self.nameLabel.text = "HDCP"
        
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
    }
    
    func setHoleNumber(front9: Bool) {
        self.nameLabel.text = "HOLE"
        
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
        self.inOut.textColor = UIColor.white
    }
    
    func setParNumber(match: Match, tournament: Tournament, front9: Bool) {
        self.nameLabel.text = "PAR"
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
        
    }
    
    
    func playerBestBallOrSinglesCell(player: Player, match: Match, tournament: Tournament, front9: Bool, scoreSelected: Bool, oppPlayer: Player?) {
        
        if scoreSelected {
            var holeOffset = 0
            if front9 { holeOffset = 0 }
            else { holeOffset = 9 }
            
            if match.getFormat() == "Shamble" {
                self.nameLabel.text = "\(player.getLastName()) (\(player.shambleHandicap(match.getCourseSlope(),rating:match.getCourseRating(),par:match.getCoursePar())))"
            }
            else {
                self.nameLabel.text = "\(player.getLastName()) (\(player.getHandicapWithSlope(match.getCourseSlope(),rating:match.getCourseRating(),par:match.getCoursePar())))"
            }
            
            if player.getHoleScore(1 + holeOffset, round: match.getRound()) == 0 {
                self.one.text = ""
            }
            else {
                self.one.text = String(player.getHoleScore(1 + holeOffset, round: match.getRound()))
            }
            
            if player.getHoleScore(2 + holeOffset, round: match.getRound()) == 0 {
                self.two.text = ""
            }
            else {
                self.two.text = String(player.getHoleScore(2 + holeOffset, round: match.getRound()))
            }
            
            if player.getHoleScore(3 + holeOffset, round: match.getRound()) == 0 {
                self.three.text = ""
            }
            else {
                self.three.text = String(player.getHoleScore(3 + holeOffset, round: match.getRound()))
            }
            
            if player.getHoleScore(4 + holeOffset, round: match.getRound()) == 0 {
                self.four.text = ""
            }
            else {
                self.four.text = String(player.getHoleScore(4 + holeOffset, round: match.getRound()))
            }
            
            if player.getHoleScore(5 + holeOffset, round: match.getRound()) == 0 {
                self.five.text = ""
            }
            else {
                self.five.text = String(player.getHoleScore(5 + holeOffset, round: match.getRound()))
            }
            
            if player.getHoleScore(6 + holeOffset, round: match.getRound()) == 0 {
                self.six.text = ""
            }
            else {
                self.six.text = String(player.getHoleScore(6 + holeOffset, round: match.getRound()))
            }
            
            if player.getHoleScore(7 + holeOffset, round: match.getRound()) == 0 {
                self.seven.text = ""
            }
            else {
                self.seven.text = String(player.getHoleScore(7 + holeOffset, round: match.getRound()))
            }
            
            if player.getHoleScore(8 + holeOffset, round: match.getRound()) == 0 {
                self.eight.text = ""
            }
            else {
                self.eight.text = String(player.getHoleScore(8 + holeOffset, round: match.getRound()))
            }
            
            if player.getHoleScore(9 + holeOffset, round: match.getRound()) == 0 {
                self.nine.text = ""
            }
            else {
                self.nine.text = String(player.getHoleScore(9 + holeOffset, round: match.getRound()))
            }
            
            var nineHoleScore = 0
            for i in 1...9 {
                nineHoleScore = nineHoleScore + player.getHoleScore(i + holeOffset, round: match.getRound())
            }
            inOut.text = String(nineHoleScore)
            
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
            
            var holes = [Int]()
            var holeResults = [(hole: Int,won: Bool)]()
            
            if front9 {
                holes = [1,2,3,4,5,6,7,8,9]
            }
            else {
                holes = [10,11,12,13,14,15,16,17,18]
            }
            
            for hole in holes {
                let teamWon = match.holeWinner(hole)
                if teamWon == player.getTeam() {
                    holeResults.append((hole,true))
                }
                else {
                    holeResults.append((hole,false))
                }
            }
            
            for hole in holeResults {
                if (hole.hole == 1 || hole.hole == 10) && hole.won {
                    if player.getTeam() == "Red" {self.one.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.one.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.one.textColor = UIColor.white
                }
                else if (hole.hole == 2 || hole.hole == 11) && hole.won {
                    if player.getTeam() == "Red" {self.two.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.two.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.two.textColor = UIColor.white
                }
                else if (hole.hole == 3 || hole.hole == 12) && hole.won {
                    if player.getTeam() == "Red" {self.three.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.three.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.three.textColor = UIColor.white
                }
                else if (hole.hole == 4 || hole.hole == 13) && hole.won {
                    if player.getTeam() == "Red" {self.four.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.four.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.four.textColor = UIColor.white
                }
                else if (hole.hole == 5 || hole.hole == 14) && hole.won {
                    if player.getTeam() == "Red" {self.five.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.five.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.five.textColor = UIColor.white
                }
                else if (hole.hole == 6 || hole.hole == 15) && hole.won {
                    if player.getTeam() == "Red" {self.six.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.six.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.six.textColor = UIColor.white
                }
                else if (hole.hole == 7 || hole.hole == 16) && hole.won {
                    if player.getTeam() == "Red" {self.seven.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.seven.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.seven.textColor = UIColor.white
                }
                else if (hole.hole == 8 || hole.hole == 17) && hole.won {
                    if player.getTeam() == "Red" {self.eight.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.eight.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.eight.textColor = UIColor.white
                }
                else if (hole.hole == 9 || hole.hole == 18) && hole.won {
                    if player.getTeam() == "Red" {self.nine.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.nine.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.nine.textColor = UIColor.white
                }
            }
        }
        //else, display strokes
        else if !scoreSelected && oppPlayer != nil{
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
                oppHandicap = oppPlayer!.getHandicapWithSlope(match.getCourseSlope(),rating: match.getCourseRating(), par: match.getCoursePar())
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
        /*
        if match.getFormat() == "Best Ball" {
            self.nameLabel.textColor = UIColor.white
            if player.getTeam() == "Blue" {
                self.nameLabel.backgroundColor = UIColorFromRGB(0x0F296B)
            }
            else {
                self.nameLabel.backgroundColor = UIColorFromRGB(0xB70A1C)
            }
        }*/
        
    }
    
    func doublesCell(team: String, match: Match, tournament: Tournament, front9: Bool, scoreSelected: Bool) {
        
        //shows scores if scores is selected
        if scoreSelected {
            let teamHandicaps = match.getTeamHandicap()
            
            var holeOffset = 0
            if front9 { holeOffset = 0 }
            else { holeOffset = 9 }
            
            var teamHandicap = 0
            if team == "Blue" {
                teamHandicap = teamHandicaps.blueTeamHandicap
            }
            else if team == "Red" {
                teamHandicap = teamHandicaps.redTeamHandicap
            }
            self.nameLabel.text = team + " (\(teamHandicap))"
            
            if team == "Blue" {
                let player = match.blueTeamPlayerOne()
                
                if player.getHoleScore(1 + holeOffset, round: match.getRound()) == 0 {
                    self.one.text = ""
                }
                else {
                    self.one.text = String(player.getHoleScore(1 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(2 + holeOffset, round: match.getRound()) == 0 {
                    self.two.text = ""
                }
                else {
                    self.two.text = String(player.getHoleScore(2 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(3 + holeOffset, round: match.getRound()) == 0 {
                    self.three.text = ""
                }
                else {
                    self.three.text = String(player.getHoleScore(3 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(4 + holeOffset, round: match.getRound()) == 0 {
                    self.four.text = ""
                }
                else {
                    self.four.text = String(player.getHoleScore(4 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(5 + holeOffset, round: match.getRound()) == 0 {
                    self.five.text = ""
                }
                else {
                    self.five.text = String(player.getHoleScore(5 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(6 + holeOffset, round: match.getRound()) == 0 {
                    self.six.text = ""
                }
                else {
                    self.six.text = String(player.getHoleScore(6 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(7 + holeOffset, round: match.getRound()) == 0 {
                    self.seven.text = ""
                }
                else {
                    self.seven.text = String(player.getHoleScore(7 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(8 + holeOffset, round: match.getRound()) == 0 {
                    self.eight.text = ""
                }
                else {
                    self.eight.text = String(player.getHoleScore(8 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(9 + holeOffset, round: match.getRound()) == 0 {
                    self.nine.text = ""
                }
                else {
                    self.nine.text = String(player.getHoleScore(9 + holeOffset, round: match.getRound()))
                }
                
                var nineHoleScore = 0
                for i in 1...9 {
                    nineHoleScore = nineHoleScore + player.getHoleScore(i + holeOffset, round: match.getRound())
                }
                inOut.text = String(nineHoleScore)
            }
            else if team == "Red" {
                let player = match.redTeamPlayerOne()
                
                if player.getHoleScore(1 + holeOffset, round: match.getRound()) == 0 {
                    self.one.text = ""
                }
                else {
                    self.one.text = String(player.getHoleScore(1 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(2 + holeOffset, round: match.getRound()) == 0 {
                    self.two.text = ""
                }
                else {
                    self.two.text = String(player.getHoleScore(2 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(3 + holeOffset, round: match.getRound()) == 0 {
                    self.three.text = ""
                }
                else {
                    self.three.text = String(player.getHoleScore(3 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(4 + holeOffset, round: match.getRound()) == 0 {
                    self.four.text = ""
                }
                else {
                    self.four.text = String(player.getHoleScore(4 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(5 + holeOffset, round: match.getRound()) == 0 {
                    self.five.text = ""
                }
                else {
                    self.five.text = String(player.getHoleScore(5 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(6 + holeOffset, round: match.getRound()) == 0 {
                    self.six.text = ""
                }
                else {
                    self.six.text = String(player.getHoleScore(6 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(7 + holeOffset, round: match.getRound()) == 0 {
                    self.seven.text = ""
                }
                else {
                    self.seven.text = String(player.getHoleScore(7 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(8 + holeOffset, round: match.getRound()) == 0 {
                    self.eight.text = ""
                }
                else {
                    self.eight.text = String(player.getHoleScore(8 + holeOffset, round: match.getRound()))
                }
                
                if player.getHoleScore(9 + holeOffset, round: match.getRound()) == 0 {
                    self.nine.text = ""
                }
                else {
                    self.nine.text = String(player.getHoleScore(9 + holeOffset, round: match.getRound()))
                }
                
                var nineHoleScore = 0
                for i in 1...9 {
                    nineHoleScore = nineHoleScore + player.getHoleScore(i + holeOffset, round: match.getRound())
                }
                inOut.text = String(nineHoleScore)
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
            
            var holes = [Int]()
            var holeResults = [(hole: Int,won: Bool)]()
            
            if front9 {
                holes = [1,2,3,4,5,6,7,8,9]
            }
            else {
                holes = [10,11,12,13,14,15,16,17,18]
            }
            
            for hole in holes {
                let teamWon = match.holeWinner(hole)
                if teamWon == team {
                    holeResults.append((hole,true))
                }
                else {
                    holeResults.append((hole,false))
                }
            }
            
            for hole in holeResults {
                if (hole.hole == 1 || hole.hole == 10) && hole.won {
                    if team == "Red" {
                        self.one.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.one.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.one.textColor = UIColor.white
                }
                else if (hole.hole == 2 || hole.hole == 11) && hole.won {
                    if team == "Red" {self.two.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.two.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.two.textColor = UIColor.white
                }
                else if (hole.hole == 3 || hole.hole == 12) && hole.won {
                    if team == "Red" {self.three.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.three.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.three.textColor = UIColor.white
                }
                else if (hole.hole == 4 || hole.hole == 13) && hole.won {
                    if team == "Red" {self.four.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.four.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.four.textColor = UIColor.white
                }
                else if (hole.hole == 5 || hole.hole == 14) && hole.won {
                    if team == "Red" {self.five.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.five.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.five.textColor = UIColor.white
                }
                else if (hole.hole == 6 || hole.hole == 15) && hole.won {
                    if team == "Red" {self.six.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.six.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.six.textColor = UIColor.white
                }
                else if (hole.hole == 7 || hole.hole == 16) && hole.won {
                    if team == "Red" {self.seven.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.seven.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.seven.textColor = UIColor.white
                }
                else if (hole.hole == 8 || hole.hole == 17) && hole.won {
                    if team == "Red" {self.eight.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.eight.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.eight.textColor = UIColor.white
                }
                else if (hole.hole == 9 || hole.hole == 18) && hole.won {
                    if team == "Red" {self.nine.backgroundColor = UIColorFromRGB(0xB70A1C)}
                    else {self.nine.backgroundColor = UIColorFromRGB(0x0F296B)}
                    self.nine.textColor = UIColor.white
                }
            }
        }
        //else show strokes
        else {
            self.inOut.text = ""
            
            let teamHandicaps = match.getTeamHandicap()
            
            var teamHandicap = 0
            var oppHandicap = 0
            if team == "Blue" {
                teamHandicap = teamHandicaps.blueTeamHandicap
                oppHandicap = teamHandicaps.redTeamHandicap
            }
            else if team == "Red" {
                teamHandicap = teamHandicaps.redTeamHandicap
                oppHandicap = teamHandicaps.blueTeamHandicap
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
        
        
    
        
    }
    
    func cleanupForReuse() {
        for i in 0...holeLabelArray.count - 1 {
            holeLabelArray[i].layer.sublayers?.forEach {$0.removeFromSuperlayer()}
        }
        
        self.layer.cornerRadius = 0
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOpacity = 0.0
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 0
        
        //self.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
    }
    
    func setHoleBackgroundColor(_ holeNumber: Int,color: UIColor) {
        if holeNumber < 10 {
            let hole = self.holeLabelArray[holeNumber - 1]
            hole.backgroundColor = color
        }
        else if holeNumber < 19 {
            let hole = self.holeLabelArray[holeNumber - 10]
            hole.backgroundColor = color
        }
    }
    func setHoleTextColor(_ holeNumber: Int,color: UIColor) {
        if holeNumber < 10 {
            let hole = self.holeLabelArray[holeNumber - 1]
            hole.textColor = color
        }
        else if holeNumber < 19 {
            let hole = self.holeLabelArray[holeNumber - 10]
            hole.textColor = color
        }
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
        self.nameLabel.font = self.nameLabel.font.without(.traitBold,.traitItalic)
        self.one.font = self.one.font.without(.traitBold,.traitItalic)
        self.two.font = self.two.font.without(.traitBold,.traitItalic)
        self.three.font = self.three.font.without(.traitBold,.traitItalic)
        self.four.font = self.four.font.without(.traitBold,.traitItalic)
        self.five.font = self.five.font.without(.traitBold,.traitItalic)
        self.six.font = self.six.font.without(.traitBold,.traitItalic)
        self.seven.font = self.seven.font.without(.traitBold,.traitItalic)
        self.eight.font = self.eight.font.without(.traitBold,.traitItalic)
        self.nine.font = self.nine.font.without(.traitBold,.traitItalic)
        self.inOut.font = self.inOut.font.without(.traitBold,.traitItalic)

    }
    
    func formatTopCell() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10

        // Top Left Corner: .layerMinXMinYCorner
        // Top Right Corner: .layerMaxXMinYCorner
        // Bottom Left Corner: .layerMinXMaxYCorner
        // Bottom Right Corner: .layerMaxXMaxYCorner
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func formatBottomCell() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10

        // Top Left Corner: .layerMinXMinYCorner
        // Top Right Corner: .layerMaxXMinYCorner
        // Bottom Left Corner: .layerMinXMaxYCorner
        // Bottom Right Corner: .layerMaxXMaxYCorner
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func formatHoleHeader() {
        self.backgroundColor = UIColorFromRGB(0x0F296B)
        self.nameLabel.backgroundColor = UIColorFromRGB(0x0F296B)
        self.one.backgroundColor = UIColorFromRGB(0x0F296B)
        self.two.backgroundColor = UIColorFromRGB(0x0F296B)
        self.three.backgroundColor = UIColorFromRGB(0x0F296B)
        self.four.backgroundColor = UIColorFromRGB(0x0F296B)
        self.five.backgroundColor = UIColorFromRGB(0x0F296B)
        self.six.backgroundColor = UIColorFromRGB(0x0F296B)
        self.seven.backgroundColor = UIColorFromRGB(0x0F296B)
        self.eight.backgroundColor = UIColorFromRGB(0x0F296B)
        self.nine.backgroundColor = UIColorFromRGB(0x0F296B)
        self.inOut.backgroundColor = UIColorFromRGB(0x0F296B)
        self.one.textColor = UIColor.white
        self.two.textColor = UIColor.white
        self.three.textColor = UIColor.white
        self.four.textColor = UIColor.white
        self.five.textColor = UIColor.white
        self.six.textColor = UIColor.white
        self.seven.textColor = UIColor.white
        self.eight.textColor = UIColor.white
        self.nine.textColor = UIColor.white
        self.inOut.textColor = UIColor.white
        self.nameLabel.textColor = UIColor.white
        self.nameLabel.font = self.nameLabel.font.boldItalic
        self.one.font = self.one.font.boldItalic
        self.two.font = self.two.font.boldItalic
        self.three.font = self.three.font.boldItalic
        self.four.font = self.four.font.boldItalic
        self.five.font = self.five.font.boldItalic
        self.six.font = self.six.font.boldItalic
        self.seven.font = self.seven.font.boldItalic
        self.eight.font = self.eight.font.boldItalic
        self.nine.font = self.nine.font.boldItalic
        self.inOut.font = self.inOut.font.boldItalic
        
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


extension UIFont {
    var bold: UIFont {
        return with(.traitBold)
    }

    var italic: UIFont {
        return with(.traitItalic)
    }

    var boldItalic: UIFont {
        return with([.traitBold, .traitItalic])
    }
    



    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(self.fontDescriptor.symbolicTraits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func without(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(self.fontDescriptor.symbolicTraits.subtracting(UIFontDescriptor.SymbolicTraits(traits))) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
