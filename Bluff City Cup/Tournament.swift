//
//  Tournament.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/29/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import CloudKit

class Tournament {
    
    fileprivate var matches: [Match]
    fileprivate var name: String
    fileprivate var numOfRounds: Int
    fileprivate var currentRound: Int
    fileprivate var matchLength: Int
    fileprivate var drinkCartAvailable: Bool
    fileprivate var drinkCartNumber: String?
    fileprivate var players: [Player]
    fileprivate var courses: [Course]
    fileprivate var roundCourses: [(round: Int, course: String)]
    fileprivate var maxhandicap: Int
    fileprivate var commishPassword: String
    fileprivate var owner: String
    //fileprivate var tournamentCKRecord: CKRecord?
    
    init() {
        self.matches = [Match]()
        self.name = String()
        self.numOfRounds = Int()
        self.currentRound = Int()
        self.matchLength = Int()
        self.drinkCartAvailable = false
        self.players = [Player]()
        self.courses = [Course]()
        self.roundCourses = [(round: Int, course: String)]()
        self.maxhandicap = Int()
        self.commishPassword = String()
        self.owner = String()
    }
    
    init(matches: [Match], name: String, numOfRounds: Int, currentRound: Int, matchLength: Int, drinkCartAvailable: Bool, playersInit: [Player], roundCourses: [(round: Int, course: String)], maxhandicap: Int, commishPassword: String) {
        self.matches = matches
        self.name = name
        self.numOfRounds = numOfRounds
        self.currentRound = currentRound
        self.matchLength = matchLength
        self.drinkCartAvailable = drinkCartAvailable
        self.players = playersInit
        self.courses = [Course]()
        self.roundCourses = roundCourses
        self.maxhandicap = maxhandicap
        self.commishPassword = commishPassword
        self.owner = String()
    }
    
    init(name: String, password: String, owner: String) {
        self.matches = [Match]()
        self.name = name
        self.numOfRounds = 4
        self.currentRound = 1
        self.matchLength = 9
        self.drinkCartAvailable = false
        self.drinkCartNumber = "9999999999"
        self.players = [Player]()
        self.courses = [Course]()
        self.roundCourses = [(round: Int, course: String)]()
        self.maxhandicap = 30
        self.commishPassword = password
        self.owner = owner
    }
    
    func getCommissionerPassword() -> String {
        return commishPassword
    }
    
    func setCommissionerPassword(_ newPassword: String) {
        self.commishPassword = newPassword
    }
    
    func getNumberOfMatches() -> Int {
        return matches.count
    }
    
    func setMatchLength(_ length: Int) {
        self.matchLength = length
    }
    func setNumberOfRounds(_ rounds: Int) {
        self.numOfRounds = rounds
    }
    func getCourseForRound(round: Int) -> String? {
        for eachRound in roundCourses {
            if eachRound.round == round {
                return eachRound.course
            }
        }
        return nil
    }
    
    func getCourseNames() -> [String] {
        var names = [String]()
        for course in courses {
            names.append(course.getName())
        }
        return names
    }
    
    func getTeesForCourse(_ courseName: String) -> [String] {
        var tees = [String]()
        
        for course in self.courses {
            if course.getName() == courseName {
                tees.append(course.getTees())
            }
        }
        
        return tees
    }
    func setDrinkCart(_ on: Bool) {
        self.drinkCartAvailable = on
    }
    func setDrinkCartNumber(_ number: String) {
        self.drinkCartNumber = number
    }
    
    func getDrinkCartNumber() -> String? {
        return drinkCartNumber
    }
    func getMaxHandicap() -> Int {
        return maxhandicap
    }
    func getOwner() -> String {
        return owner
    }
    
    func setMaxHandicap(_ handicap: Int) {
        self.maxhandicap = handicap
    }
    
    func setPlayers(_ setPlayers:[Player]) {
        players = setPlayers
    }
    func addPlayer(_ playerToAdd: Player) {
        var add = true
        for p in players {
            if playerToAdd == p {
                add = false
            }
        }
        
        if add { players.append(playerToAdd)}
    }
    func getPlayers() -> [Player] {
        return players
    }
    
    func getPlayerWithName(_ name: String) -> Player? {
        
        for player in players {
            if player.getName() == name {
                return player
            }
        }
        return nil
    }
    
    func getBluePlayerNames() -> [String] {
        
        var bluePlayerNames = [String]()
        var tournamentPlayers = players
        
        tournamentPlayers.sort(by: { $0.getHandicap() < $1.getHandicap() })
        
        for player in tournamentPlayers {
            if player.getTeam() == "Blue" {
                bluePlayerNames.append(player.getName())
            }
        }
        
        return bluePlayerNames
    }
    
    func getRedPlayerNames() -> [String] {
        
        var redPlayerNames = [String]()
        var tournamentPlayers = players
        
        tournamentPlayers.sort(by: { $0.getHandicap() < $1.getHandicap() })
        
        for player in tournamentPlayers {
            if player.getTeam() == "Red" {
                redPlayerNames.append(player.getName())
            }
        }
        
        return redPlayerNames
    }
    
    func getMatches() -> [Match] {
        return matches
    }
    func deleteMatches() {
        
        matches = [Match]()
        
        for player in players {
            player.deleteHoleResults()
        }
    }
    
    func deletePlayer(_ player: Player) -> Bool {
        
        if matches.count != 0 {
            for match in matches {
                if match.blueTeamPlayerOne() == player || match.redTeamPlayerOne() == player {
                    return false
                }
                else {
                    if match.getFormat() == "Doubles" {
                        if match.blueTeamPlayerTwo()! == player || match.redTeamPlayerTwo()! == player {
                            return false
                        }
                    }
                    
                }
            }
            for i in 0...(players.count-1) {
                if players[i] == player {
                    players.remove(at: i)
                    return true
                }
            }
        }
        else {
            for i in 0...(players.count-1) {
                if players[i] == player {
                    players.remove(at: i)
                    return true
                }
            }
            return false
        }
        return false
    }
    
    func deleteMatch(_ match: Match) -> Bool {
        
        if (self.getMatchLength() == 9 && (match.getCurrentHole() != 1 && match.getCurrentHole() != 10)) || (self.getMatchLength() == 18 && match.getCurrentHole() > 1){
            return false
        }
        
        for i in 0...(matches.count-1) {
            if matches[i] == match {
                matches.remove(at: i)
                return true
            }
        }
        return false
    }
    
    func getName() -> String {
        return name
    }
    
    func getNumberOfRounds() -> Int {
        return numOfRounds
    }
    
    func getCurrentRound() -> Int {
        return currentRound
    }
    
    func getMatchLength() -> Int {
        return matchLength
    }
    func appendPlayer(player: Player) {
        players.append(player)
    }
    func appendMatch(match: Match) {
        matches.append(match)
    }
    
    func matchesStarted() -> Bool {
        for eachMatch in matches {
            if eachMatch.getCurrentHole() > 1 {
                return true
            }
        }
        return false
    }
    
    func playerAlreadyInMatchInRound(playerName: String, round: Int) -> Bool {
        let matches = self.getRoundMatches(round)
        
        for match in matches {
            if match.getFormat() == "Singles" {
                if match.blueTeamPlayerOne().getName() == playerName || match.redTeamPlayerOne().getName() == playerName {
                    return true
                }
            }
            else if match.getFormat() == "Four Man Scramble" {
                if match.blueTeamPlayerOne().getName() == playerName || match.redTeamPlayerOne().getName() == playerName || match.blueTeamPlayerTwo()?.getName() == playerName || match.redTeamPlayerTwo()?.getName() == playerName ||
                    match.blueTeamPlayerThree()?.getName() == playerName || match.redTeamPlayerThree()?.getName() == playerName || match.blueTeamPlayerFour()?.getName() == playerName || match.redTeamPlayerFour()?.getName() == playerName{
                    return true
                }
            }
            else {
                if match.blueTeamPlayerOne().getName() == playerName || match.redTeamPlayerOne().getName() == playerName || match.blueTeamPlayerTwo()?.getName() == playerName || match.redTeamPlayerTwo()?.getName() == playerName {
                    return true
                }
            }
        }
        
        return false
    }
    
    func getCurrentMatch(_ player: Player) -> Match? {
        
        var playerMatches = self.getPlayerMatches(player)
        
        playerMatches.sort(by: { $0.getRound() < $1.getRound() })
        
        for eachMatch in playerMatches {
            if !eachMatch.isCompleted() {
                return eachMatch
            }
        }
        
        return nil
    }
    
    func getPlayerMatches(_ player: Player) -> [Match] {
        var playerMatches = [Match]()
        
        for eachMatch in self.matches {
            if eachMatch.getFormat() == "Singles" {
                if eachMatch.blueTeamPlayerOne().getName() == player.getName() || eachMatch.redTeamPlayerOne().getName() == player.getName() {
                    playerMatches.append(eachMatch)
                }
            }
            else if eachMatch.getFormat() == "Four Man Scramble" {
                if eachMatch.blueTeamPlayerOne().getName() == player.getName() || eachMatch.redTeamPlayerOne().getName() == player.getName() || eachMatch.blueTeamPlayerTwo()!.getName() == player.getName() || eachMatch.redTeamPlayerTwo()!.getName() == player.getName() ||
                    eachMatch.blueTeamPlayerThree()!.getName() == player.getName() || eachMatch.redTeamPlayerThree()!.getName() == player.getName() || eachMatch.blueTeamPlayerFour()!.getName() == player.getName() || eachMatch.redTeamPlayerFour()!.getName() == player.getName() {
                    playerMatches.append(eachMatch)
                }
            }
            else {
                if eachMatch.blueTeamPlayerOne().getName() == player.getName() || eachMatch.redTeamPlayerOne().getName() == player.getName() || eachMatch.blueTeamPlayerTwo()!.getName() == player.getName() || eachMatch.redTeamPlayerTwo()!.getName() == player.getName() {
                    playerMatches.append(eachMatch)
                }
            }
        }
        
        return playerMatches
    }
    
    func getPlayerLastRound(_ player: Player) -> Int {
        var maxRound = 100
        for m in getMatchesSorted() {
            if (m.blueTeamPlayerOne() == player || m.redTeamPlayerOne() == player) {
                if m.getRound() < maxRound  && !m.isCompleted() {
                    maxRound = m.getRound()
                }
            }
        }
        
        return maxRound
    }
    
    func getSinglesGroupMatches(_ player: Player, round: Int) -> [Match] {
        var group = Int()
        for m in getMatchesSorted() {
            if (m.blueTeamPlayerOne() == player || m.redTeamPlayerOne() == player) && (m.getRound() == round) {
                group = m.getGroup()
            }
        }
        
        var groupMatches = [Match]()
        
        for m in getMatchesSorted() {
            if (m.getGroup() == group) && (m.getRound() == round) {
                groupMatches.append(m)
            }
        }
        
        
        
        return groupMatches
    }
    
    
    func getCourseRounds() -> [(round: Int,course: String)] {
        return self.roundCourses
    }
    func getRoundMatches(_ round: Int) -> [Match] {
        var roundMatches = [Match]()
        
        for m in matches {
            if m.getRound() == round {
                roundMatches.append(m)
            }
        }
        
        roundMatches.sort(by: { $0.getGroup() < $1.getGroup() })
        
        return roundMatches
    }
    
    func getMatchesSorted() -> [Match] {
        
        var sortedMatches = self.matches
        
        sortedMatches.sort(by:{
            if $0.getRound() != $1.getRound() {
                return $0.getRound() < $1.getRound()
            }
            else {
                //last names are the same, break ties by first name
                return $0.getMatchNumber() < $1.getMatchNumber()
            }
        })
        
        return sortedMatches
    }
    
    func getMatchesSortedForTable() -> [Match] {
        var sortedMatches = self.matches
        
        sortedMatches.sort(by:{
            if $0.getRound() != $1.getRound() {
                return $0.getRound() < $1.getRound()
            }
            else {
                return $0.getMatchNumber() < $1.getMatchNumber()
            }
        })
        
        var matchesNotStarted = [Match]()
        var matchesFinished = [Match]()
        var matchesUnderway = [Match]()
        for match in sortedMatches {
            if match.getStartingHole() == match.getCurrentHole() {
                matchesNotStarted.append(match)
            }
            else if match.isCompleted() {
                matchesFinished.append(match)
            }
            else {
                matchesUnderway.append(match)
            }
        }
        
        var tableMatches = [Match]()
        for match in matchesUnderway {
            tableMatches.append(match)
        }
        for match in matchesNotStarted {
            tableMatches.append(match)
        }
        for match in matchesFinished {
            tableMatches.append(match)
        }
        
        return tableMatches
    }
    
    func sortPlayersByTeamAndHandicap() -> [Player] {
        var sortedPlayers = self.players
        
        sortedPlayers.sort(by:{
            if $0.getTeam() != $1.getTeam() {
                return $0.getTeam() < $1.getTeam()
            }
            else {
                //last names are the same, break ties by first name
                return $0.getHandicap() < $1.getHandicap()
            }
        })
        
        return sortedPlayers
    }
    
    
    func liveScores() -> (Double,Double) {
        
        var blueScore: Double = 0
        var redScore: Double = 0
        
        for m in getMatches() //getRoundMatches(currentRound)
        {
            if m.winningTeam() == "Blue" {
                blueScore += 1
            }
            else if m.winningTeam() == "Red" {
                redScore += 1
            }
            else {
                blueScore = blueScore + 0.5
                redScore = redScore + 0.5
            }
        }
        
        let (blueCompletedScores,redCompletedScores) = self.getCompletedScores()
        
        return (blueScore-blueCompletedScores,redScore-redCompletedScores)
    }
    
    func getCompletedScores() -> (blueScore: Double, redScore: Double) {
        var blueScore = 0.0
        var redScore = 0.0
        
        for match in matches {
            
            if match.isCompleted() {
                if match.winningTeam() == "Blue" {
                    blueScore = blueScore + 1
                }
                else if match.winningTeam() == "Red" {
                    redScore = redScore + 1
                }
                else if match.winningTeam() == "AS" {
                    blueScore = blueScore + 0.5
                    redScore = redScore + 0.5
                }
            }
        }
        
        return (blueScore,redScore)
    }
    
    
    
    func isDrinkCartAvailable() -> Bool {
        return drinkCartAvailable
    }
    
    func getCourseWithName(name: String) -> Course {
        
        for course in self.courses {
            if course.getName() == name {
                return course
            }
        }
        
        return Course()
        
    }
    
    func appendCourse(course: Course) {
        self.courses.append(course)
    }
    
    func holeWinner(_ matchIn: Match, hole: Int) -> String {
        
        let course = getCourseWithName(name: matchIn.getCourseName())
        
        let lowestHandicap = matchIn.getLowestHandicap()
        
        let holeHandicap = course.getHole(hole).getHandicap()
        let courseSlope = matchIn.getCourseSlope()
        let coursePar = matchIn.getCoursePar()
        let courseRating = matchIn.getCourseRating()
        
        var blueScore = Int()
        var redScore = Int()
        
        let blueP1ActualScore = matchIn.blueTeamPlayerOne().getHoleScore(hole, round: matchIn.getRound())
        
        let redP1ActualScore = matchIn.redTeamPlayerOne().getHoleScore(hole, round: matchIn.getRound())
        
        
        if matchIn.getFormat() == "Alternate Shot" {
            var blue_team_handicap = Int()
            if matchIn.blueTeamPlayerTwo() != nil {
                blue_team_handicap = getTeamHandicap(format: matchIn.getFormat(), player1Handicap: matchIn.blueTeamPlayerOne().handicap, player2Handicap: matchIn.blueTeamPlayerTwo()!.getHandicap(), courseSlope: courseSlope,rating: courseRating, par: coursePar)
                //Int(round(Double(matchIn.blueTeamPlayerOne().handicap) * 0.6 + Double(matchIn.blueTeamPlayerTwo()!.getHandicap()) * 0.4))
            }
            else {
                blue_team_handicap = matchIn.blueTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar)
            }
            
            var red_team_handicap = Int()
            if matchIn.redTeamPlayerTwo() != nil {
                red_team_handicap = getTeamHandicap(format: matchIn.getFormat(), player1Handicap: matchIn.redTeamPlayerOne().handicap, player2Handicap: matchIn.redTeamPlayerTwo()!.getHandicap(), courseSlope: courseSlope,rating: courseRating, par: coursePar)
            }
            else {
                red_team_handicap = matchIn.redTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar)
            }
            
            if blue_team_handicap < red_team_handicap {
                red_team_handicap = red_team_handicap - blue_team_handicap
                blue_team_handicap = 0
            }
            else {
                blue_team_handicap = blue_team_handicap - red_team_handicap
                red_team_handicap = 0
            }
            
            blueScore = self.handicapScore(blueP1ActualScore, playerHandicap: blue_team_handicap, holeHandicap: holeHandicap)
            redScore = self.handicapScore(redP1ActualScore, playerHandicap: red_team_handicap, holeHandicap: holeHandicap)
        }
        else if matchIn.getFormat() == "Best Ball" {
            
            let blue_P1_handicap = matchIn.blueTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
            var blue_P2_handicap = Int()
            let red_P1_handicap = matchIn.redTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
            var red_P2_handicap = Int()
            
            let blueScoreP1 = handicapScore(blueP1ActualScore, playerHandicap: blue_P1_handicap, holeHandicap: holeHandicap)
            var blueScoreP2 = 0
            let redScoreP1 = handicapScore(redP1ActualScore, playerHandicap: red_P1_handicap, holeHandicap: holeHandicap)
            var redScoreP2 = 0
            
            
            if matchIn.blueTeamPlayerTwo() != nil {
                blue_P2_handicap = matchIn.blueTeamPlayerTwo()!.singlesHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
                let blueP2ActualScore = matchIn.blueTeamPlayerTwo()!.getHoleScore(hole, round: matchIn.getRound())
                blueScoreP2 = handicapScore(blueP2ActualScore, playerHandicap: blue_P2_handicap, holeHandicap: holeHandicap)
            }
            
            if matchIn.redTeamPlayerTwo() != nil {
                red_P2_handicap = matchIn.redTeamPlayerTwo()!.singlesHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
                let redP2ActualScore = matchIn.redTeamPlayerTwo()!.getHoleScore(hole, round: matchIn.getRound())
                redScoreP2 = handicapScore(redP2ActualScore, playerHandicap: red_P2_handicap, holeHandicap: holeHandicap)
            }
            
            
            if blueScoreP1 == 0 && blueScoreP2 == 0 {
                blueScore = 0
            }
            else if blueScoreP1 == 0 {
                blueScore = blueScoreP2
            }
            else if blueScoreP2 == 0 {
                blueScore = blueScoreP1
            }
            else {
                if blueScoreP1 > blueScoreP2 {
                    blueScore = blueScoreP2
                }
                else {
                    blueScore = blueScoreP1
                }
            }
            
            if redScoreP1 == 0 && redScoreP2 == 0 {
                redScore = 0
            }
            else if redScoreP1 == 0 {
                redScore = redScoreP2
            }
            else if redScoreP2  == 0 {
                redScore = redScoreP1
            }
            else {
                if redScoreP1 > redScoreP2 {
                    redScore = redScoreP2
                }
                else {
                    redScore = redScoreP1
                }
            }
            
        }
        else if matchIn.getFormat() == "Shamble" {
            
            let blue_P1_handicap = matchIn.blueTeamPlayerOne().shambleHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
            var blue_P2_handicap = Int()
            let red_P1_handicap = matchIn.redTeamPlayerOne().shambleHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
            var red_P2_handicap = Int()
            
            let blueScoreP1 = handicapScore(blueP1ActualScore, playerHandicap: blue_P1_handicap, holeHandicap: holeHandicap)
            var blueScoreP2 = 0
            let redScoreP1 = handicapScore(redP1ActualScore, playerHandicap: red_P1_handicap, holeHandicap: holeHandicap)
            var redScoreP2 = 0
            
            
            if matchIn.blueTeamPlayerTwo() != nil {
                blue_P2_handicap = matchIn.blueTeamPlayerTwo()!.shambleHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
                let blueP2ActualScore = matchIn.blueTeamPlayerTwo()!.getHoleScore(hole, round: matchIn.getRound())
                blueScoreP2 = handicapScore(blueP2ActualScore, playerHandicap: blue_P2_handicap, holeHandicap: holeHandicap)
            }
            
            if matchIn.redTeamPlayerTwo() != nil {
                red_P2_handicap = matchIn.redTeamPlayerTwo()!.shambleHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
                let redP2ActualScore = matchIn.redTeamPlayerTwo()!.getHoleScore(hole, round: matchIn.getRound())
                redScoreP2 = handicapScore(redP2ActualScore, playerHandicap: red_P2_handicap, holeHandicap: holeHandicap)
            }
            
            
            if blueScoreP1 == 0 && blueScoreP2 == 0 {
                blueScore = 0
            }
            else if blueScoreP1 == 0 {
                blueScore = blueScoreP2
            }
            else if blueScoreP2 == 0 {
                blueScore = blueScoreP1
            }
            else {
                if blueScoreP1 > blueScoreP2 {
                    blueScore = blueScoreP2
                }
                else {
                    blueScore = blueScoreP1
                }
            }
            
            if redScoreP1 == 0 && redScoreP2 == 0 {
                redScore = 0
            }
            else if redScoreP1 == 0 {
                redScore = redScoreP2
            }
            else if redScoreP2  == 0 {
                redScore = redScoreP1
            }
            else {
                if redScoreP1 > redScoreP2 {
                    redScore = redScoreP2
                }
                else {
                    redScore = redScoreP1
                }
            }
            
        }
        else if matchIn.getFormat() == "Two Man Scramble" {
            var blue_team_handicap = getTeamHandicap(format: matchIn.getFormat(), player1Handicap: matchIn.blueTeamPlayerOne().handicap, player2Handicap: matchIn.blueTeamPlayerTwo()!.getHandicap(), courseSlope: courseSlope,rating: courseRating, par: coursePar)
            var red_team_handicap = getTeamHandicap(format: matchIn.getFormat(), player1Handicap: matchIn.redTeamPlayerOne().handicap, player2Handicap: matchIn.redTeamPlayerTwo()!.getHandicap(), courseSlope: courseSlope,rating: courseRating, par: coursePar)
            
            if blue_team_handicap < red_team_handicap {
                red_team_handicap = red_team_handicap - blue_team_handicap
                blue_team_handicap = 0
            }
            else {
                blue_team_handicap = blue_team_handicap - red_team_handicap
                red_team_handicap = 0
            }
            
            blueScore = handicapScore(blueP1ActualScore, playerHandicap: blue_team_handicap, holeHandicap: holeHandicap)
            redScore = handicapScore(redP1ActualScore, playerHandicap: red_team_handicap, holeHandicap: holeHandicap)
        }
        else if matchIn.getFormat() == "Singles" {
            var bP1Handicap = matchIn.blueTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar)
            var rP1Handicap = matchIn.redTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar)
            
            if bP1Handicap < rP1Handicap {
                rP1Handicap = rP1Handicap - bP1Handicap
                bP1Handicap = 0
            }
            else {
                bP1Handicap = bP1Handicap - rP1Handicap
                rP1Handicap = 0
            }
            
            blueScore = handicapScore(blueP1ActualScore, playerHandicap: bP1Handicap, holeHandicap: holeHandicap)
            redScore = handicapScore(redP1ActualScore, playerHandicap: rP1Handicap, holeHandicap: holeHandicap)
        }
        else if matchIn.getFormat() == "Four Man Scramble" {
            var blue_team_handicap = getTeamHandicap4ManScramble(format: matchIn.getFormat(), player1Handicap: matchIn.blueTeamPlayerOne().handicap, player2Handicap: matchIn.blueTeamPlayerTwo()!.getHandicap(), player3Handicap: matchIn.blueTeamPlayerThree()!.getHandicap(), player4Handicap: matchIn.blueTeamPlayerFour()!.getHandicap(), courseSlope: courseSlope)
            var red_team_handicap = getTeamHandicap4ManScramble(format: matchIn.getFormat(), player1Handicap: matchIn.redTeamPlayerOne().handicap, player2Handicap: matchIn.redTeamPlayerTwo()!.getHandicap(), player3Handicap: matchIn.redTeamPlayerThree()!.getHandicap(), player4Handicap: matchIn.redTeamPlayerFour()!.getHandicap(), courseSlope: courseSlope)
            
            if blue_team_handicap < red_team_handicap {
                red_team_handicap = red_team_handicap - blue_team_handicap
                blue_team_handicap = 0
            }
            else {
                blue_team_handicap = blue_team_handicap - red_team_handicap
                red_team_handicap = 0
            }
            
            blueScore = handicapScore(blueP1ActualScore, playerHandicap: blue_team_handicap, holeHandicap: holeHandicap)
            redScore = handicapScore(redP1ActualScore, playerHandicap: red_team_handicap, holeHandicap: holeHandicap)
        }
        
        if blueP1ActualScore == 0 && redP1ActualScore == 0 {
            return "AS"
        }
        else if blueScore < redScore {
            return "Blue"
        }
        else if blueScore > redScore {
            return "Red"
        }
        else { return "AS" }
        
    }
    
    func updateUserMatchHoleScores() {
        if User.sharedInstance.isScorekeeper() {
            let userPlayer = getPlayerWithName(User.sharedInstance.getName())
            
            let userMatches = getPlayerMatches(userPlayer!)
            
            for eachMatch in userMatches {
                if eachMatch.getCurrentHole() == 1 || (eachMatch.getCurrentHole() == 10 && self.matchLength == 9) { }
                else {
                    if self.matchLength == 9 && (eachMatch.getCurrentHole() >= 10) {
                        if eachMatch.getCurrentHole() != 10 {
                            for i in 10...(eachMatch.getCurrentHole()-1) {
                                
                                if holeWinner(eachMatch, hole: i) == "Blue" {
                                    eachMatch.setHoleWinner(hole: i, winner: "Blue")
                                }
                                else if holeWinner(eachMatch, hole: i) == "Red" {
                                    eachMatch.setHoleWinner(hole: i, winner: "Red")
                                }
                                else {
                                    eachMatch.setHoleWinner(hole: i, winner: "Halved")
                                }
                            }
                        }
                        else { eachMatch.setHoleWinner(hole: 10, winner: "Halved") }
                    }
                    else {
                        for i in 1...(eachMatch.getCurrentHole()-1) {
                            
                            if holeWinner(eachMatch, hole: i) == "Blue" {
                                eachMatch.setHoleWinner(hole: i, winner: "Blue")
                            }
                            else if holeWinner(eachMatch, hole: i) == "Red" {
                                eachMatch.setHoleWinner(hole: i, winner: "Red")
                            }
                            else {
                                eachMatch.setHoleWinner(hole: i, winner: "Halved")
                            }
                        }
                    }
                }
            }
        }
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
    
    func checkScorekeeper(_ name: String) -> Bool {
        
        for eachMatch in matches {
            if !eachMatch.isCompleted() {
                if eachMatch.getScorekeeperName() == name {
                    return true
                }
            }
        }
        return false
    }
    
    func setMatches(_ newMatches: [Match]) {
        self.matches = newMatches
    }
    
    func getTeamHandicap4ManScramble(format: String, player1Handicap: Double, player2Handicap: Double, player3Handicap: Double, player4Handicap: Double, courseSlope: Int) -> Int {
        let slopeFactor = Double(courseSlope) / 113.0
        
        let maxhandicap = Double(self.maxhandicap)
        let P1Handicap = min(Darwin.round(Double(player1Handicap) * slopeFactor),maxhandicap)
        let P2Handicap = min(Darwin.round(Double(player2Handicap) * slopeFactor),maxhandicap)
        let P3Handicap = min(Darwin.round(Double(player3Handicap) * slopeFactor),maxhandicap)
        let P4Handicap = min(Darwin.round(Double(player4Handicap) * slopeFactor),maxhandicap)
        
        return Int(Darwin.round(P1Handicap * 0.20 + P2Handicap * 0.15 + P3Handicap * 0.10 + P4Handicap * 0.05))
    }
    
    func getTeamHandicap(format: String, player1Handicap: Double, player2Handicap: Double, courseSlope: Int, rating: Double, par: Double) -> Int {
        let slopeFactor = Double(courseSlope) / 113.0
        
        /*
        if format == "Alternate Shot" {
            //return Int(round((Double(player1Handicap) * 0.6 + Double(player2Handicap) * 0.4) * Double(courseSlope / 113)))
            return min(Int(Darwin.round((Double(player1Handicap) * 0.6 + Double(player2Handicap) * 0.4) * slopeFactor)),self.maxhandicap)
        }
        else if format == "Two Man Scramble" {
            //return Int(round((Double(player1Handicap) * 0.35 + Double(player2Handicap) * 0.15) * Double(courseSlope / 113)))
            return min(Int(Darwin.round((Double(player1Handicap) * 0.35 + Double(player2Handicap) * 0.15) * slopeFactor)),self.maxhandicap)
        }
        else {
            return 0
        }
 */
        //min(Int(Darwin.round((Double(self.handicap) * slopeFactor) + (rating - par))),maxhandicap)
        let maxhandicap = Double(self.maxhandicap)
        //let P1Handicap = min(Darwin.round(Double(player1Handicap) * slopeFactor),maxhandicap)
        //let P2Handicap = min(Darwin.round(Double(player2Handicap) * slopeFactor),maxhandicap)
        let P1FullHandicap = Int(Darwin.round((Double(player1Handicap) * slopeFactor) + (rating - par)))
        let P2FullHandicap = Int(Darwin.round((Double(player2Handicap) * slopeFactor) + (rating - par)))

        
        let P1Handicap = min(P1FullHandicap,Int(maxhandicap))
        let P2Handicap = min(P2FullHandicap,Int(maxhandicap))

        if format == "Alternate Shot" {
            return Int(Darwin.round(Double(P1Handicap) * 0.5 + Double(P2Handicap) * 0.5))
        }
        else if format == "Two Man Scramble" {
            return Int(Darwin.round(Double(P1Handicap) * 0.35 + Double(P2Handicap) * 0.15))
        }
        else if format == "Four Man Scramble" {
            return 0
        }
        else {
            return 0
        }
    }
    
}
