//
//  User.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/18/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation

class User {
    
    static let sharedInstance = User()
    var name: String
    var player: Player?
    var role: String
    var scorekeeper: Bool
    var inMatch: Bool
    var model: Model = Model.sharedInstance
    
    init(){
        name = String()
        player = Player()
        role = "Spectator"
        scorekeeper = false
        inMatch = false
    }
    init(name: String, player: Player?, role: String, isInMatch: Bool) {
        self.name = name
        self.player = player
        self.role = role
        if role == "Scorekeeper" {
            scorekeeper = true
        }
        else {
            scorekeeper = false
        }
        self.inMatch = isInMatch
    }
    
    init(name: String, role: String) {
        self.name = name
        self.role = role
        if role == "Scorekeeper" {
            scorekeeper = true
            inMatch = true
        }
        else {
            scorekeeper = false
            inMatch = false
        }
    }
    
    func getPlayer() -> Player? {
        
        if let playerObject = player {
            return playerObject
        }
        else {
            return nil
        }
    }
    
    func getName() -> String {
        return name
    }
    
    func getRole() -> String {
        return role
    }
    
    func isScorekeeper() -> Bool {
        return scorekeeper
    }
    
    func isInMatch() -> Bool {
        return inMatch
    }
    
    func setUserName(_ userName: String) {
        self.name = userName
    }
    
    func setUser(name: String, role: String, scorekeeper: Bool, isInMatch: Bool) {
        self.name = name
        self.role = role
        self.scorekeeper = scorekeeper
        self.inMatch = isInMatch

    }
    
    func setUser(name: String, player: Player, role: String, scorekeeper: Bool, isInMatch: Bool) {
        self.name = name
        self.role = role
        self.player = player
        self.scorekeeper = scorekeeper
        self.inMatch = isInMatch
    }
    
    func updateRole(tournamentName: String, _ completion: @escaping () -> Void) {
        
        self.model.checkScorekeeper(userName: self.name, tournamentName: tournamentName) { isScorekeeper, isInMatch in
            
            self.inMatch = isInMatch
            self.scorekeeper = isScorekeeper
            if self.role == "Commissioner" { }
            else if isScorekeeper { self.role = "Scorekeeper" }
            else if isInMatch && (self.role == "Spectator") { self.role = "Player" }
            else if !isInMatch && self.role == "Player" { self.role = "Spectator" }
            else if self.role == "Scorekeeper" && self.scorekeeper == false && isInMatch {
                self.role = "Player"
            }
            else if self.role == "Scorekeeper" && self.scorekeeper == false && !isInMatch
            {
                self.role = "Spectator"
            }
            
            completion()
        }
    }
    
    func updateScorekeeperFromTournament(_ tournament: Tournament) {
        self.scorekeeper = tournament.checkScorekeeper(self.name)
    }
    
}
