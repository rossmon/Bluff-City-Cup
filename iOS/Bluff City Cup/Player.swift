//
//  Player.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/17/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import CloudKit

class Player {
    
    var name: String
    var handicap: Double
    var team: String
    var holeResults: [(round: Int, holeNumber: Int, score: Int)]?
    
    init(){
        name = String()
        handicap = Double()
        team = String()
        self.holeResults = [(round: Int, holeNumber: Int, score: Int)]()
        
    }
    
    init(name: String, handicap: Double, team: String) {
        self.name = name
        self.handicap = handicap
        self.team = team
        self.holeResults = [(round: Int, holeNumber: Int, score: Int)]()
        
    }
    
    
    func getTeam() -> String {
        return team
    }
    func setTeam(_ team: String) {
        self.team = team
    }
    
    func getHandicap() -> Double {
        return handicap
    }
    
    func getHandicapWithSlope(_ slope: Int, rating: Double, par: Double) -> Int {
        let slopeFactor = Double(slope) / 113.0
        let maxhandicap = Model.sharedInstance.tournament.getMaxHandicap()
        return min(Int(Darwin.round((Double(self.handicap) * slopeFactor) + (rating - par))),maxhandicap)
        //return (Int(Double(self.handicap) * Double(slope/113)))
    }
    
    func setHandicap(_ handicap: Double) {
        self.handicap = handicap
    }
    
    func getName() -> String {
        return name
    }
    func getLastName() -> String {
        let fullNameArr = name.split{$0 == " "}.map(String.init)
        return fullNameArr[1]
    }
    
    
    func getHoleScore(_ hole: Int, round: Int) -> Int {
        for eachHole in holeResults! {
            if eachHole.holeNumber == hole && eachHole.round == round {
                return eachHole.score
            }
        }
        return 0
    }
    
    func setHoleScore(_ hole: Int, score: Int, round: Int) {
        
        if holeResults!.count > 0 {
            for i in 0...(holeResults!.count-1) {
                if holeResults![i].holeNumber == hole && holeResults![i].round == round {
                    holeResults?.remove(at: i)
                    break
                }
            }
        }
        
        holeResults?.append((round: round, holeNumber: hole, score: score))
    }
    
    func getHoleResults(round: Int) -> [(round: Int, holeNumber: Int, score: Int)]?
    {
        var results = [(round: Int, holeNumber: Int, score: Int)]()
        for result in holeResults! {
            if result.round == round {
                results.append(result)
            }
        }
        return results
    }
    
    func clearHoleResults() {
        self.holeResults?.removeAll()
        
        for i in 1...18 {
            self.holeResults?.append((round: 1, holeNumber: i, score: 0))
        }
        
    }
    
    func setHoleResults(round: Int, holeNumber: Int, score: Int) {
        
        if holeResults!.count > 0 {
            for i in 0...(holeResults!.count-1) {
                if holeResults![i].holeNumber == holeNumber && holeResults![i].round == round {
                    holeResults?.remove(at: i)
                    break
                }
            }
        }
        
        holeResults?.append((round: round, holeNumber: holeNumber, score: score))
    }
    
    func deleteHoleResults() {
        
        self.holeResults = [(round: Int, holeNumber: Int, score: Int)]()
    }
    
    func singlesHandicap(_ courseSlope: Int, rating: Double, par: Double) -> Int {
        let slopeFactor = Double(courseSlope) / 113.0
        let maxhandicap = Model.sharedInstance.tournament.getMaxHandicap()
        return min(Int(Darwin.round((Double(self.handicap) * slopeFactor) + (rating - par))),maxhandicap)
        //return Int(round(Double(self.handicap) * Double(courseSlope / 113)))
    }
    
    func shambleHandicap(_ courseSlope: Int, rating: Double, par: Double) -> Int {
        let slopeFactor = Double(courseSlope) / 113.0
        let maxhandicap = Model.sharedInstance.tournament.getMaxHandicap()
        
        
      //  print(self.name)
       // print(self.handicap)
       // print(0.8 * (Darwin.round((Double(self.handicap) * slopeFactor) + (rating - par))))
        //print(Int(0.8 * (Darwin.round((Double(self.handicap) * slopeFactor) + (rating - par)))))
        return min(Int(Darwin.round(0.8 * ((Double(self.handicap) * slopeFactor) + (rating - par)))),maxhandicap)
        
    }
    
}

func ==(left: Player, right: Player) -> Bool {
    
    if left.getName() == right.getName() && left.getHandicap() == right.getHandicap() &&
        left.getTeam() == right.getTeam() {
        return true
    }
    
    return false
}
