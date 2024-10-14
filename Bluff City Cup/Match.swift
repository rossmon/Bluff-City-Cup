//
//  Match.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/17/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import CloudKit

class Match : NSObject {
    
    fileprivate var format: String
    fileprivate var players: [Player]
    fileprivate var scorekeeper: String
    fileprivate var score: Int
    fileprivate var scoreString: String?
    fileprivate var teamUp: String
    fileprivate var currentHole: Int
    fileprivate var startingHole: Int
    fileprivate var course: String
    fileprivate var tees: String
    fileprivate var round: Int
    fileprivate var group: Int
    fileprivate var matchNumber: Int
    fileprivate var holeWinners: [(hole: Int, winner: String)]
    fileprivate var matchFinished: Bool
    //fileprivate var ckMatch: CKRecord?
    
    override init() {
        format = String()
        players = [Player]()
        scorekeeper = String()
        score = Int()
        scoreString = String()
        teamUp = String()
        currentHole = Int()
        startingHole = Int()
        course = String()
        tees = String()
        round = Int()
        group = Int()
        matchNumber = Int()
        holeWinners = [(Int,String)]()
        matchFinished = false

    }
    
    init(format: String, players: [Player], scorekeeper: String, score: Int, scoreString: String?, teamWinning: String, hole: Int, course: String, tees: String, round: Int, group: Int, startingHole: Int, matchNumber: Int, matchFinished: Bool) {
        self.format = format
        self.players = players
        self.score = score
        if scoreString != nil {
            self.scoreString = scoreString
        }
        else { self.scoreString = "AS" }
        self.teamUp = teamWinning
        self.currentHole = hole
        self.course = course
        self.tees = tees
        self.round = round
        self.group = group
        self.startingHole = startingHole
        self.matchNumber = matchNumber
        
        self.holeWinners = [(Int,String)]()
        for i in 1...18 {
            self.holeWinners.append((i,"Halved"))
        }
        self.matchFinished = matchFinished
        self.scorekeeper = scorekeeper
    }
    
    init(format: String, players: [Player], score: Int, teamWinning: String, hole: Int, course: String, tees: String, round: Int, group: Int, startingHole: Int, matchNumber: Int) {
        self.format = format
        self.players = players
        self.score = score
        self.scoreString = "AS"
        self.teamUp = teamWinning
        self.currentHole = hole
        self.course = course
        self.tees = tees
        self.round = round
        self.group = group
        self.startingHole = startingHole
        self.matchNumber = matchNumber
        
        self.holeWinners = [(Int,String)]()
        for i in 1...18 {
            self.holeWinners.append((i,"Halved"))
        }
        matchFinished = false
        self.scorekeeper = ""
        
    }
    
    init(format: String, players: [Player], scorekeeper: String, score: Int, teamWinning: String, hole: Int, course: String, tees: String, round: Int, group: Int, startingHole: Int, matchNumber: Int) {
        self.format = format
        self.players = players
        self.score = score
        self.scoreString = "AS"
        self.teamUp = teamWinning
        self.currentHole = hole
        self.course = course
        self.tees = tees
        self.round = round
        self.group = group
        self.startingHole = startingHole
        self.matchNumber = matchNumber
        
        self.holeWinners = [(Int,String)]()
        for i in 1...18 {
            self.holeWinners.append((i,"Halved"))
        }
        matchFinished = false
        self.scorekeeper = scorekeeper
        
    }
    
    func refreshHoleWinners() {
        
        self.holeWinners = [(Int,String)]()
        for i in 1...18 {
            var winner = Model.sharedInstance.tournament.holeWinner(self, hole: i)
            if winner == "AS" { winner = "Halved" }
            self.holeWinners.append((i,winner))
        }

        
    }
    
    func blueTeamPlayerOne() -> Player {
        var bluePlayers = [Player]()
        
        for index in 1...players.count {
            if players[index-1].getTeam() == "Blue" {
                bluePlayers.append(players[index-1])
            }
        }
        
        bluePlayers.sort(by: {$0.getHandicap() < $1.getHandicap()})
        
        return bluePlayers[0]
    }
    
    func blueTeamPlayerTwo() -> Player? {
        
        if players.count == 4 {
            var bluePlayers = [Player]()
            
            for index in 1...players.count {
                if players[index-1].getTeam() == "Blue" {
                    bluePlayers.append(players[index-1])
                }
            }
            
            bluePlayers.sort(by: {$0.getHandicap() < $1.getHandicap()})
            
            return bluePlayers[1]
        }
        else {
            return nil
        }
    }
    
    func blueTeamPlayerThree() -> Player? {
        
        if players.count >= 4 {
            var bluePlayers = [Player]()
            
            for index in 1...players.count {
                if players[index-1].getTeam() == "Blue" {
                    bluePlayers.append(players[index-1])
                }
            }
            
            bluePlayers.sort(by: {$0.getHandicap() < $1.getHandicap()})
            
            if bluePlayers.count >= 3 { return bluePlayers[2] }
            else {return nil}
        }
        else {
            return nil
        }
    }
    
    func blueTeamPlayerFour() -> Player? {
        
        if players.count >= 4 {
            var bluePlayers = [Player]()
            
            for index in 1...players.count {
                if players[index-1].getTeam() == "Blue" {
                    bluePlayers.append(players[index-1])
                }
            }
            
            bluePlayers.sort(by: {$0.getHandicap() < $1.getHandicap()})
            
            if bluePlayers.count >= 3 { return bluePlayers[3] }
            else {return nil}
        }
        else {
            return nil
        }
    }
    
    func redTeamPlayerOne() -> Player {
        var redPlayers = [Player]()
        
        for index in 1...players.count {
            if players[index-1].getTeam() == "Red" {
                redPlayers.append(players[index-1])
            }
        }
        
        redPlayers.sort(by: {$0.getHandicap() < $1.getHandicap()})
        
        return redPlayers[0]
    }
    
    func redTeamPlayerTwo() -> Player? {
        if players.count == 4 {
            var redPlayers = [Player]()
            
            for index in 1...players.count {
                if players[index-1].getTeam() == "Red" {
                    redPlayers.append(players[index-1])
                }
            }
            
            redPlayers.sort(by: {$0.getHandicap() < $1.getHandicap()})
            
            return redPlayers[1]
        }
        else {
            return nil
        }
    }
    
    func redTeamPlayerThree() -> Player? {
        
        if players.count >= 4 {
            var redPlayers = [Player]()
            
            for index in 1...players.count {
                if players[index-1].getTeam() == "Red" {
                    redPlayers.append(players[index-1])
                }
            }
            
            redPlayers.sort(by: {$0.getHandicap() < $1.getHandicap()})
            
            if redPlayers.count >= 3 { return redPlayers[2] }
            else {return nil}
        }
        else {
            return nil
        }
    }
    
    func redTeamPlayerFour() -> Player? {
        
        if players.count >= 4 {
            var redPlayers = [Player]()
            
            for index in 1...players.count {
                if players[index-1].getTeam() == "Red" {
                    redPlayers.append(players[index-1])
                }
            }
            
            redPlayers.sort(by: {$0.getHandicap() < $1.getHandicap()})
            
            if redPlayers.count >= 3 { return redPlayers[3] }
            else {return nil}
        }
        else {
            return nil
        }
    }
    
    /*
    func onHole() -> Hole {
        //return course.getHoles()[currentHole-1]
        return currentHole
    }*/
    
    func clearPlayerHoleResults () {
        blueTeamPlayerOne().clearHoleResults()
        redTeamPlayerOne().clearHoleResults()
        
        if let bp2 = blueTeamPlayerTwo() {
            bp2.clearHoleResults()
        }
        
        if let rp2 = redTeamPlayerTwo() {
            rp2.clearHoleResults()
        }
        
        if let bp3 = blueTeamPlayerThree() {
            bp3.clearHoleResults()
        }
        
        if let rp3 = redTeamPlayerThree() {
            rp3.clearHoleResults()
        }
        
        if let bp4 = blueTeamPlayerFour() {
            bp4.clearHoleResults()
        }
        
        if let rp4 = redTeamPlayerFour() {
            rp4.clearHoleResults()
        }
    }
    
    func getCurrentHole() -> Int {
        return currentHole
    }
    func getCourseName() -> String {
        return course
    }
    
    func getCourseSlope() -> Int {
        return Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getSlope()
    }
    func getCourseRating() -> Double {
        return Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getRating()
    }
    func getCoursePar() -> Double {
        return Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getPar()
    }

    func getTees() -> String {
        return tees
    }
    func setStartingHole(_ holeNumber: Int) {
        self.startingHole = holeNumber
    }
    func getStartingHole() -> Int {
        return startingHole
    }
    
    func getRound() -> Int {
        return round
    }
    
    func getMatchNumber() -> Int {
        return matchNumber
    }
    
    func splitHole() {
        currentHole += 1
    }
    
    func getPlayers() -> [Player] {
        return self.players
    }
    
    func getScorekeeperName() -> String {
        return self.scorekeeper
    }
    
    func getLowestHandicap() -> Int {
        var lowHandicap = 10000
        
        if self.format == "Shamble" {
            for eachPlayer in self.players {
                if eachPlayer.shambleHandicap(getCourseSlope(),rating: getCourseRating(), par: getCoursePar()) < lowHandicap {
                    lowHandicap = eachPlayer.shambleHandicap(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())
                }
            }
        }
        else {
            for eachPlayer in self.players {
                if eachPlayer.getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar()) < lowHandicap {
                    lowHandicap = eachPlayer.getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())
                }
            }
        }
        
        
        return lowHandicap
    }
    
    func setPlayers(_ matchPlayers: [Player]) {
        self.players = matchPlayers
    }

    func setFormat(_ matchFormat: String) {
        self.format = matchFormat
    }
    func setRound(_ matchRound: Int) {
        self.round = matchRound
    }
    func setMatchNumber(_ matchNumber: Int) {
        self.matchNumber = matchNumber
    }
    func setGroupNumber(_ groupNumber: Int) {
        self.group = groupNumber
    }
    func finishMatch() {
        clearPlayerHoleResults()
        
        self.matchFinished = true
    }
    
    func setScorekeeperName(_ name: String) {
        self.scorekeeper = name
    }
    
    
    func blueTeamWinsHole(matchLength: Int) {
        
        //NEED TO VERIFY MATCH ISNT OVER - ADD MATCH OVER VARIABLE
        if teamUp == "Blue" {
            score += 1
        }
        else if teamUp == "AS" {
            score += 1
            teamUp = "Blue"
        }
        else {
            score -= 1
            if score == 0 {
                teamUp = "AS"
            }
        }
        currentHole += 1
    }
    
    func redTeamWinsHole(matchLength: Int) {
        
        //NEED TO VERIFY MATCH ISNT OVER - ADD MATCH OVER VARIABLE
        if teamUp == "Red" {
            score += 1
        }
        else if teamUp == "AS" {
            score += 1
            teamUp = "Red"
        }
        else {
            score -= 1
            if score == 0 {
                teamUp = "AS"
            }
        }
        currentHole += 1
    }

    
    func singles() -> Bool {return players.count == 2}
    
    func doubles() -> Bool {return players.count == 4}
    
    func winningTeam() -> String {
        
        return teamUp
    }
    
    func handicapScore(_ actualScore: Int, playerHandicap: Int, holeHandicap: Int) -> Int {
        var handicapScore = Int()
        
        if playerHandicap >= 36 {
            if (playerHandicap - 36) >= holeHandicap {
                handicapScore = actualScore - 3
            }
            else {
                handicapScore = actualScore - 2
            }
        }
        else if playerHandicap >= 18 {
            if (playerHandicap - 18) >= holeHandicap {
                handicapScore = actualScore - 2
            }
            else {
                handicapScore = actualScore - 1
            }
        }
        else {
            if playerHandicap >= holeHandicap {
                handicapScore = actualScore - 1
            }
            else {
                handicapScore = actualScore
            }
        }
        
        return handicapScore
    }
    
    func getMatchScoreSeparated(matchLength: Int) -> (scoreString: String, secondaryString: String, finished: Bool, score: Int, teamUp: String) {
        
        var blueScore:Double = 0
        var endingHole = 0
        var teamUP = "AS"
        
        //INSERT LOGIC FOR SINGLES MATCHES - USE HOLE RESULTS INSTEAD OF HOLEWINNER
        if self.format == "Singles" {
            
            var bP1Handicap = blueTeamPlayerOne().getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())
            var rP1Handicap = redTeamPlayerOne().getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())
            
            if ((bP1Handicap - rP1Handicap) < 0) {
                rP1Handicap = rP1Handicap - bP1Handicap
                bP1Handicap = 0
            }
            else {
                bP1Handicap = bP1Handicap - rP1Handicap
                rP1Handicap = 0
            }
            
            if currentHole == 1 || (currentHole == 10 && matchLength == 9 && startingHole == 10) {
                return ("AS", "",false, 0, "AS")
            }
            else if (currentHole == 10 && matchLength == 9 && startingHole == 1) || (currentHole == 19) {
                for hole in (startingHole)...(currentHole - 1) {
                    var blueP1HandicapScore = self.handicapScore(blueTeamPlayerOne().getHoleScore(hole, round: self.round), playerHandicap: bP1Handicap, holeHandicap: Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getHole(hole).getHandicap())
                    
                    var redP1HandicapScore = self.handicapScore(redTeamPlayerOne().getHoleScore(hole, round: self.round), playerHandicap: rP1Handicap, holeHandicap: Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getHole(hole).getHandicap())
                    
                    if blueP1HandicapScore < 0 { blueP1HandicapScore = 0 }
                    if redP1HandicapScore < 0 { redP1HandicapScore = 0 }
                    
                    if hole != 19 {
                        if (startingHole == 1 && abs(blueScore) > Double(matchLength - hole + 1)) {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            if hole < (matchLength+1) {
                                return ("\(Int(abs(blueScore)))","& \((matchLength - hole + 1))", true, Int(abs(blueScore)), teamUP)
                            }
                        }
                        else if (startingHole == 10 && abs(blueScore) > Double(18 - hole + 1)) {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            if hole < (18+1) {
                                return ("\(Int(abs(blueScore)))","& \((18 - hole + 1))", true, Int(abs(blueScore)), teamUP)
                            }
                        }
                        else if (blueP1HandicapScore < redP1HandicapScore) {
                            blueScore += 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        else if (blueP1HandicapScore > redP1HandicapScore) {
                            blueScore -= 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        
                    }
                    
                    endingHole = hole
                    
                }
                
                if blueScore == 0 {return ("Halved", "",true, 0, teamUP) }
                else {
                    return ("\(Int(abs(blueScore)))","UP", true, Int(abs(blueScore)), teamUP)
                }
            }
            else { 
                var done = false
                //EDIT THIS TO REFLECT CORRECT MATCH SCORE - 11/29/16
                for hole in (startingHole)...(currentHole) {
                    if hole != 19 {
                        var blueP1HandicapScore = self.handicapScore(blueTeamPlayerOne().getHoleScore(hole, round: self.round), playerHandicap: bP1Handicap, holeHandicap: Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getHole(hole).getHandicap())
                        
                        var redP1HandicapScore = self.handicapScore(redTeamPlayerOne().getHoleScore(hole, round: self.round), playerHandicap: rP1Handicap, holeHandicap: Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getHole(hole).getHandicap())
                        
                        if blueP1HandicapScore < 0 { blueP1HandicapScore = 0 }
                        if redP1HandicapScore < 0 { redP1HandicapScore = 0 }
                        
                        if (startingHole == 1 && abs(blueScore) > Double(matchLength - hole + 1)) || (startingHole == 10 && abs(blueScore) > Double(18 - hole + 1)) {
                            done = true
                        }
                        else {
                            done = false
                        }
                        
                        if done {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            var finishEarly = false
                            if (startingHole == 1 && hole < (matchLength+1)) || (startingHole == 10 && hole < 19) {
                                finishEarly = true
                            }
                            if finishEarly {
                                if startingHole == 1 {
                                    if (hole == 10 && matchLength == 9) || hole == 19 {
                                        return ("\(Int(abs(blueScore)))","& \((matchLength - hole + 1))", true, Int(abs(blueScore)), teamUP)
                                    }
                                    else {
                                        return ("\(Int(abs(blueScore)))","& \((matchLength - hole + 1))", false, Int(abs(blueScore)), teamUP)
                                    }
                                }
                                else {
                                    if hole == 19 {
                                        return ("\(Int(abs(blueScore)))","& \((18 - hole + 1))", true, Int(abs(blueScore)), teamUP)
                                    }
                                    else {
                                        return ("\(Int(abs(blueScore)))","& \((18 - hole + 1))", false, Int(abs(blueScore)), teamUP)
                                    }
                                }
                            }
                        }
                        else if (blueP1HandicapScore < redP1HandicapScore) {
                            blueScore += 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        else if (blueP1HandicapScore > redP1HandicapScore) {
                            blueScore -= 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        
                    }
                    
                    endingHole = hole
                }
                
                //endingHole++
                
                if (endingHole == 10 && matchLength == 9) || endingHole == 19 {
                    //MATCH IS OVER
                    if blueScore == 0 {return ("Halved","", true, 0, teamUP) }
                    else {
                        
                        return ("\(Int(abs(blueScore)))","UP", true, Int(abs(blueScore)), teamUP)
                    }
                }
                else {
                    if blueScore == 0 {
                        return ("AS", "",false, 0, teamUP)
                    }
                    else {
                        return ("\(Int(abs(blueScore)))","UP", false, Int(abs(blueScore)), teamUP)
                    }
                }
            }
        }
        else {
            //FINISH PROGRAM FOR GETTING MATCH FINAL
            //DOUBLES MATCHES SCORES
            
            if currentHole == 1 || (currentHole == 10 && matchLength == 9 && startingHole == 10) {
                return ("AS", "",false, 0, "AS")
            }
            else if (currentHole == 10 && matchLength == 9 && startingHole == 1) || (currentHole == 19) {
                for hole in (startingHole)...(currentHole) {
                    if hole != 19 {
                        if (startingHole == 1 && abs(blueScore) > Double(matchLength - hole + 1)) {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            if hole < (matchLength+1) {
                                return ("\(Int(abs(blueScore)))","& \((matchLength - hole + 1))", true, Int(abs(blueScore)), teamUP)
                            }
                        }
                        else if (startingHole == 10 && abs(blueScore) > Double(18 - hole + 1)) {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            if hole < (18+1) {
                                return ("\(Int(abs(blueScore)))","& \((18 - hole + 1))", true, Int(abs(blueScore)), teamUP)
                            }
                        }
                        else if holeWinner(hole) == "Blue" {
                            blueScore += 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        else if holeWinner(hole) == "Red" {
                            blueScore -= 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        
                    }
                    
                    endingHole = hole
                    
                }
                
                if blueScore == 0 {return ("Halved","", true, 0, teamUP) }
                else {
                    return ("\(Int(abs(blueScore)))","UP", true, Int(abs(blueScore)), teamUP)
                }
            }
            else {
                var done = false
                //EDIT THIS TO REFLECT CORRECT MATCH SCORE - 11/29/16
                for hole in (startingHole)...(currentHole) {
                    if hole != 19 {
                        if (startingHole == 1 && abs(blueScore) > Double(matchLength - hole + 1)) || (startingHole == 10 && abs(blueScore) > Double(18 - hole + 1)) {
                            done = true
                        }
                        else {
                            done = false
                        }
                        
                        if done {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            var finishEarly = false
                            if (startingHole == 1 && hole < (matchLength+1)) || (startingHole == 10 && hole < 19) {
                                finishEarly = true
                            }
                            if finishEarly {
                                if startingHole == 1 {
                                    if (hole == 10 && matchLength == 9) || hole == 19 {
                                        return ("\(Int(abs(blueScore)))","& \((matchLength - hole + 1))", true, Int(abs(blueScore)), teamUP)
                                    }
                                    else {
                                        return ("\(Int(abs(blueScore)))","& \((matchLength - hole + 1))", false, Int(abs(blueScore)), teamUP)
                                    }
                                }
                                else {
                                    if hole == 19 {
                                        return ("\(Int(abs(blueScore)))","& \((18 - hole + 1))", true, Int(abs(blueScore)), teamUP)
                                    }
                                    else {
                                        return ("\(Int(abs(blueScore)))","& \((18 - hole + 1))", false, Int(abs(blueScore)), teamUP)
                                    }
                                }
                            }
                        }
                        else if holeWinner(hole) == "Blue" {
                            blueScore += 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        else if holeWinner(hole) == "Red" {
                            blueScore -= 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        
                    }
                    
                    endingHole = hole
                }
                
                //endingHole++
                
                if (endingHole == 10 && matchLength == 9) || endingHole == 19 {
                    //MATCH IS OVER
                    if blueScore == 0 {return ("Halved", "",true, 0, teamUP) }
                    else {
                        
                        return ("\(Int(abs(blueScore)))","UP", true, Int(abs(blueScore)), teamUP)
                    }
                }
                else {
                    if blueScore == 0 {
                        return ("AS","", false, 0, teamUP)
                    }
                    else {
                        return ("\(Int(abs(blueScore)))","UP", false, Int(abs(blueScore)), teamUP)
                    }
                }
            }
        }
        
    }
    
    func getMatchScore(matchLength: Int) -> (scoreString: String, finished: Bool, score: Int, teamUp: String) {
        
        var blueScore:Double = 0
        var endingHole = 0
        var teamUP = "AS"
        
        //INSERT LOGIC FOR SINGLES MATCHES - USE HOLE RESULTS INSTEAD OF HOLEWINNER
        if self.format == "Singles" {
            
            var bP1Handicap = blueTeamPlayerOne().getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())
            var rP1Handicap = redTeamPlayerOne().getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())
            
            if ((bP1Handicap - rP1Handicap) < 0) {
                rP1Handicap = rP1Handicap - bP1Handicap
                bP1Handicap = 0
            }
            else {
                bP1Handicap = bP1Handicap - rP1Handicap
                rP1Handicap = 0
            }
            
            if currentHole == 1 || (currentHole == 10 && matchLength == 9 && startingHole == 10) {
                return ("AS", false, 0, "AS")
            }
            else if (currentHole == 10 && matchLength == 9 && startingHole == 1) || (currentHole == 19) {
                for hole in (startingHole)...(currentHole - 1) {
                    var blueP1HandicapScore = self.handicapScore(blueTeamPlayerOne().getHoleScore(hole, round: self.round), playerHandicap: bP1Handicap, holeHandicap: Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getHole(hole).getHandicap())
                    
                    var redP1HandicapScore = self.handicapScore(redTeamPlayerOne().getHoleScore(hole, round: self.round), playerHandicap: rP1Handicap, holeHandicap: Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getHole(hole).getHandicap())
                    
                    if blueP1HandicapScore < 0 { blueP1HandicapScore = 0 }
                    if redP1HandicapScore < 0 { redP1HandicapScore = 0 }
                    
                    if hole != 19 {
                        if (startingHole == 1 && abs(blueScore) > Double(matchLength - hole + 1)) {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            if hole < (matchLength+1) {
                                return ("\(Int(abs(blueScore))) & \((matchLength - hole + 1))", true, Int(abs(blueScore)), teamUP)
                            }
                        }
                        else if (startingHole == 10 && abs(blueScore) > Double(18 - hole + 1)) {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            if hole < (18+1) {
                                return ("\(Int(abs(blueScore))) & \((18 - hole + 1))", true, Int(abs(blueScore)), teamUP)
                            }
                        }
                        else if (blueP1HandicapScore < redP1HandicapScore) {
                            blueScore += 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        else if (blueP1HandicapScore > redP1HandicapScore) {
                            blueScore -= 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        
                    }
                    
                    endingHole = hole
                    
                }
                
                if blueScore == 0 {return ("Halved", true, 0, teamUP) }
                else {
                    return ("\(Int(abs(blueScore))) UP", true, Int(abs(blueScore)), teamUP)
                }
            }
            else {
                var done = false
                //EDIT THIS TO REFLECT CORRECT MATCH SCORE - 11/29/16
                for hole in (startingHole)...(currentHole) {
                    if hole != 19 {
                        var blueP1HandicapScore = self.handicapScore(blueTeamPlayerOne().getHoleScore(hole, round: self.round), playerHandicap: bP1Handicap, holeHandicap: Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getHole(hole).getHandicap())
                        
                        var redP1HandicapScore = self.handicapScore(redTeamPlayerOne().getHoleScore(hole, round: self.round), playerHandicap: rP1Handicap, holeHandicap: Model.sharedInstance.getTournament().getCourseWithName(name: self.course).getHole(hole).getHandicap())
                        
                        if blueP1HandicapScore < 0 { blueP1HandicapScore = 0 }
                        if redP1HandicapScore < 0 { redP1HandicapScore = 0 }
                        
                        if (startingHole == 1 && abs(blueScore) > Double(matchLength - hole + 1)) || (startingHole == 10 && abs(blueScore) > Double(18 - hole + 1)) {
                            done = true
                        }
                        else {
                            done = false
                        }
                        
                        if done {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            var finishEarly = false
                            if (startingHole == 1 && hole < (matchLength+1)) || (startingHole == 10 && hole < 19) {
                                finishEarly = true
                            }
                            if finishEarly {
                                if startingHole == 1 {
                                    if (hole == 10 && matchLength == 9) || hole == 19 {
                                        return ("\(Int(abs(blueScore))) & \((matchLength - hole + 1))", true, Int(abs(blueScore)), teamUP)
                                    }
                                    else {
                                        return ("\(Int(abs(blueScore))) & \((matchLength - hole + 1))", false, Int(abs(blueScore)), teamUP)
                                    }
                                }
                                else {
                                    if hole == 19 {
                                        return ("\(Int(abs(blueScore))) & \((18 - hole + 1))", true, Int(abs(blueScore)), teamUP)
                                    }
                                    else {
                                        return ("\(Int(abs(blueScore))) & \((18 - hole + 1))", false, Int(abs(blueScore)), teamUP)
                                    }
                                }
                            }
                        }
                        else if (blueP1HandicapScore < redP1HandicapScore) {
                            blueScore += 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        else if (blueP1HandicapScore > redP1HandicapScore) {
                            blueScore -= 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        
                    }
                    
                    endingHole = hole
                }
                
                //endingHole++
                
                if (endingHole == 10 && matchLength == 9) || endingHole == 19 {
                    //MATCH IS OVER
                    if blueScore == 0 {return ("Halved", true, 0, teamUP) }
                    else {
                        
                        return ("\(Int(abs(blueScore))) UP", true, Int(abs(blueScore)), teamUP)
                    }
                }
                else {
                    if blueScore == 0 {
                        return ("AS", false, 0, teamUP)
                    }
                    else {
                        return ("\(Int(abs(blueScore))) UP", false, Int(abs(blueScore)), teamUP)
                    }
                }
            }
        }
        else {
            //FINISH PROGRAM FOR GETTING MATCH FINAL
            //DOUBLES MATCHES SCORES
            
            if currentHole == 1 || (currentHole == 10 && matchLength == 9 && startingHole == 10) {
                return ("AS", false, 0, "AS")
            }
            else if (currentHole == 10 && matchLength == 9 && startingHole == 1) || (currentHole == 19) {
                for hole in (startingHole)...(currentHole) {
                    if hole != 19 {
                        if (startingHole == 1 && abs(blueScore) > Double(matchLength - hole + 1)) {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            if hole < (matchLength+1) {
                                return ("\(Int(abs(blueScore))) & \((matchLength - hole + 1))", true, Int(abs(blueScore)), teamUP)
                            }
                        }
                        else if (startingHole == 10 && abs(blueScore) > Double(18 - hole + 1)) {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            if hole < (18+1) {
                                return ("\(Int(abs(blueScore))) & \((18 - hole + 1))", true, Int(abs(blueScore)), teamUP)
                            }
                        }
                        else if holeWinner(hole) == "Blue" {
                            blueScore += 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        else if holeWinner(hole) == "Red" {
                            blueScore -= 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        
                    }
                    
                    endingHole = hole
                    
                }
                
                if blueScore == 0 {return ("Halved", true, 0, teamUP) }
                else {
                    return ("\(Int(abs(blueScore))) UP", true, Int(abs(blueScore)), teamUP)
                }
            }
            else {
                var done = false
                //EDIT THIS TO REFLECT CORRECT MATCH SCORE - 11/29/16
                for hole in (startingHole)...(currentHole) {
                    if hole != 19 {
                        if (startingHole == 1 && abs(blueScore) > Double(matchLength - hole + 1)) || (startingHole == 10 && abs(blueScore) > Double(18 - hole + 1)) {
                            done = true
                        }
                        else {
                            done = false
                        }
                        
                        if done {
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                            
                            var finishEarly = false
                            if (startingHole == 1 && hole < (matchLength+1)) || (startingHole == 10 && hole < 19) {
                                finishEarly = true
                            }
                            if finishEarly {
                                if startingHole == 1 {
                                    if (hole == 10 && matchLength == 9) || hole == 19 {
                                        return ("\(Int(abs(blueScore))) & \((matchLength - hole + 1))", true, Int(abs(blueScore)), teamUP)
                                    }
                                    else {
                                        return ("\(Int(abs(blueScore))) & \((matchLength - hole + 1))", false, Int(abs(blueScore)), teamUP)
                                    }
                                }
                                else {
                                    if hole == 19 {
                                        return ("\(Int(abs(blueScore))) & \((18 - hole + 1))", true, Int(abs(blueScore)), teamUP)
                                    }
                                    else {
                                        return ("\(Int(abs(blueScore))) & \((18 - hole + 1))", false, Int(abs(blueScore)), teamUP)
                                    }
                                }
                            }
                        }
                        else if holeWinner(hole) == "Blue" {
                            blueScore += 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        else if holeWinner(hole) == "Red" {
                            blueScore -= 1
                            if blueScore > 0 {
                                teamUP = "Blue"
                            }
                            else if blueScore < 0 {
                                teamUP = "Red"
                            }
                            else { teamUP = "AS" }
                        }
                        
                    }
                    
                    endingHole = hole
                }
                
                //endingHole++
                
                if (endingHole == 10 && matchLength == 9) || endingHole == 19 {
                    //MATCH IS OVER
                    if blueScore == 0 {return ("Halved", true, 0, teamUP) }
                    else {
                        
                        return ("\(Int(abs(blueScore))) UP", true, Int(abs(blueScore)), teamUP)
                    }
                }
                else {
                    if blueScore == 0 {
                        return ("AS", false, 0, teamUP)
                    }
                    else {
                        return ("\(Int(abs(blueScore))) UP", false, Int(abs(blueScore)), teamUP)
                    }
                }
            }
        }
        
    }
    
    func updateCurrentScore(matchLength: Int) {
        let matchStatus = getMatchScore(matchLength: matchLength)
        
        self.scoreString = matchStatus.scoreString
        self.matchFinished = matchStatus.finished
        self.teamUp = matchStatus.teamUp
        self.score = matchStatus.score
    }

    func isCompleted() -> Bool {
        return matchFinished
    }
    
    func currentScore() -> Int {
        return score
    }
    
    func currentScoreString() -> String {
        return scoreString!
    }
    
    func getFormat() -> String {
        return format
    }
    
    func getGroup() -> Int {
        return group
    }
    
    func getCourse() -> String {
        return course
    }
    
    
    func holeWinner(_ hole: Int) -> String {
        
        for holeWinner in self.holeWinners {
            if holeWinner.hole == hole {
                return holeWinner.winner
            }
        }
        
        return "Halved"
    }
    
    func setHoleWinner(hole: Int, winner: String) {
        
        for i in 0...17 {
            if self.holeWinners[i].hole == hole {
                self.holeWinners[i].winner = winner
            }
        }
    }
    
    func getEndingHole() -> Int {
        let matchLength = Model.sharedInstance.tournament.getMatchLength()
        var bluePointDiff = 0
        var endingHole = 0
        if startingHole == 1 && matchLength == 9 { endingHole = 9 }
        else { endingHole = 18 }
        
        for i in 1...min(endingHole,max(currentHole-1,1)) {
            if self.holeWinner(i) == "Blue" { bluePointDiff+=1 }
            else if self.holeWinner(i) == "Red" { bluePointDiff-=1 }
            
            if abs(bluePointDiff) > (endingHole - i) { return i }
        }
        return 0
    }
    
    
    func updateMatch(matchLength: Int, _ completion: @escaping () -> Void) {
        
        let model: Model = Model.sharedInstance
        model.updateMatch(self) { completion() }
        
    }
    
    func updateHoleResults(holeNumber: Int, round: Int) {
        
        for eachPlayer in self.players {
            for eachHole in eachPlayer.getHoleResults(round: round)! {
                if eachHole.holeNumber == holeNumber {
                    
                    Model.sharedInstance.updateHoleScoreRecord(player: eachPlayer, round: round, course: self.getCourse(), hole: holeNumber, score: eachHole.score) {}
                    
                    break
                }
            }
        }
    }
    
    

    
    func getSinglesHandicaps() -> (blueTeamHandicap: Int, redTeamHandicap: Int) {
        
        //let maxhandicap = Model.sharedInstance.tournament.getMaxHandicap()
        //let slopeFactor = Double(getCourseSlope()) / 113.0
        let courseSlope = getCourseSlope()
        let courseRating = getCourseRating()
        let coursePar = getCoursePar()

        
        let blueHandicap = blueTeamPlayerOne().getHandicapWithSlope(courseSlope, rating: courseRating, par: coursePar)
        let redHandicap = redTeamPlayerOne().getHandicapWithSlope(courseSlope, rating: courseRating, par: coursePar)
        
        return (blueHandicap,redHandicap )

    }
    
    func getShambleHandicaps() -> (blueTeamHandicap: Int, redTeamHandicap: Int) {
        
        //let maxhandicap = Model.sharedInstance.tournament.getMaxHandicap()
        //let slopeFactor = Double(getCourseSlope()) / 113.0
        let courseSlope = getCourseSlope()
        let courseRating = getCourseRating()
        let coursePar = getCoursePar()

        
        let blueHandicap = blueTeamPlayerOne().shambleHandicap(courseSlope, rating: courseRating, par: coursePar)
        let redHandicap = redTeamPlayerOne().shambleHandicap(courseSlope, rating: courseRating, par: coursePar)
        
        return (blueHandicap,redHandicap )

    }
    
    func getTeamHandicap() -> (blueTeamHandicap: Int, redTeamHandicap: Int) {
        
        var redTeamHandicap = 0
        var blueTeamHandicap = 0
        let maxhandicap = Double(Model.sharedInstance.tournament.getMaxHandicap())
        
        let bP1Handicap = min(Double(blueTeamPlayerOne().getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())),maxhandicap)
        let bP2Handicap = min(Double(blueTeamPlayerTwo()!.getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())),maxhandicap)
        let rP1Handicap = min(Double(redTeamPlayerOne().getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())),maxhandicap)
        let rP2Handicap = min(Double(redTeamPlayerTwo()!.getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())),maxhandicap)
        
        var bP3Handicap = 0.0
        var bP4Handicap = 0.0
        var rP3Handicap = 0.0
        var rP4Handicap = 0.0
        
        
        if format == "Alternate Shot" {
            blueTeamHandicap = Int(Darwin.round(bP1Handicap * 0.5 + bP2Handicap * 0.5))
            redTeamHandicap = Int(Darwin.round(rP1Handicap * 0.5 + rP2Handicap * 0.5))
        }
        else if format == "Two Man Scramble" {
            
            blueTeamHandicap = Int(Darwin.round(bP1Handicap * 0.35 + bP2Handicap * 0.15))
            redTeamHandicap = Int(Darwin.round(rP1Handicap * 0.35 + rP2Handicap * 0.15))
        }
        else if format == "Four Man Scramble" {
            if self.players.count == 8 {
                bP3Handicap = min(Double(blueTeamPlayerThree()!.getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())),maxhandicap)
                bP4Handicap = min(Double(blueTeamPlayerFour()!.getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())),maxhandicap)
                rP3Handicap = min(Double(redTeamPlayerThree()!.getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())),maxhandicap)
                rP4Handicap = min(Double(redTeamPlayerFour()!.getHandicapWithSlope(getCourseSlope(),rating: getCourseRating(), par: getCoursePar())),maxhandicap)
            }
            
            blueTeamHandicap = Int(Darwin.round(bP1Handicap * 0.20 + bP2Handicap * 0.15 + bP3Handicap * 0.10 + bP4Handicap * 0.05))
            redTeamHandicap = Int(Darwin.round(rP1Handicap * 0.20 + rP2Handicap * 0.15 + rP3Handicap * 0.10 + rP4Handicap * 0.05))
        }
        
        return (blueTeamHandicap: blueTeamHandicap, redTeamHandicap: redTeamHandicap)
    }

    
}

func ==(left: Match, right: Match) -> Bool {
    
    if left.group == right.group && left.round == right.round &&
        left.matchNumber == right.matchNumber {
        return true
    }
    
    return false
}
