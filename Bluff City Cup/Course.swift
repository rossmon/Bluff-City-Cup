 //
 //  Course.swift
 //  Bluff City Cup
 //
 //  Created by Ross Montague on 2/24/16.
 //  Copyright © 2016 Jumpstop Creations. All rights reserved.
 //
 
 import Foundation
 import CoreLocation
 
 class Course {
    
    var name: String
    var holes: [Hole]
    var slope: Int
    var tees: String
    var par: Double
    var rating: Double
    
    
    init(){
        name = String()
        holes = [Hole]()
        slope = Int()
        tees = String()
        par = Double()
        rating = Double()
    }
    init(name: String, holes: [Hole], slope: Int, tees: String, par: Double, rating: Double) {
        self.name = name
        self.holes = holes
        self.slope = slope
        self.tees = tees
        self.par = par
        self.rating = rating
    }
    
    func getName() -> String {
        return name
    }
    
    func getHoles() -> [Hole] {
        return holes
    }
    
    func getTees() -> String {
        return tees
    }
    
    func getSlope() -> Int {
        return slope
    }
    
    func getPar() -> Double {
        return par
    }
    
    func getRating() -> Double {
        return rating
    }
    
    func getHole(_ holeNum: Int) -> Hole {
        if holes.count == 0 {
            return Hole()
        }
        else {
            return holes[holeNum - 1]
        }
    }
 }
