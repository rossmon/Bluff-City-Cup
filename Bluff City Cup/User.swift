//
//  User.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/18/16.
//  Copyright 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import AuthenticationServices

class User {
    
    static let sharedInstance = User()
    var name: String
    var player: Player?
    var role: String
    var scorekeeper: Bool
    var inMatch: Bool
    var model: Model = Model.sharedInstance
    
    var identifier: String
    var email: String?
    var firstName: String?
    var lastName: String?
    
    init(){
        self.identifier = String()
        name = String()
        player = Player()
        role = "Spectator"
        scorekeeper = false
        inMatch = false
        self.email = nil
        self.firstName = nil
        self.lastName = nil
    }
    init(name: String, player: Player?, role: String, isInMatch: Bool) {
        self.identifier = String()
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
        self.email = nil
        self.firstName = nil
        self.lastName = nil
    }
    
    init(name: String, role: String) {
        self.identifier = String()
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
        self.email = nil
        self.firstName = nil
        self.lastName = nil
    }
    
    init(identifier: String, email: String?, firstName: String?, lastName: String?) {
        self.identifier = identifier
        self.name = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
        self.player = Player()
        self.role = "Spectator"
        self.scorekeeper = false
        self.inMatch = false
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
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
    
    func setUser(name: String, firstName: String, lastName: String, identifier: String, role: String, scorekeeper: Bool, isInMatch: Bool) {
        self.name = name
        self.role = role
        self.scorekeeper = scorekeeper
        self.inMatch = isInMatch
        self.firstName = firstName
        self.lastName = lastName
        self.identifier = identifier

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
    
    func updateWithAppleSignIn(credentials: ASAuthorizationAppleIDCredential) {
        self.identifier = credentials.user
        self.email = credentials.email
        self.firstName = credentials.fullName?.givenName
        self.lastName = credentials.fullName?.familyName
        if let firstName = self.firstName, let lastName = self.lastName {
            self.name = "\(firstName) \(lastName)"
        }
    }
}
