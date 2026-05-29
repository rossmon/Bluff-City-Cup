//
//  Hole.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/24/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Hole {
    
    var number: Int
    var length: Int
    var par: Int
    var handicap: Int
    var centerOfGreen: CLLocation
    var courseName: String
    var tees: String
    
    init(){
        number = Int()
        length = Int()
        par = Int()
        handicap = Int()
        centerOfGreen = CLLocation(latitude: 0, longitude: 0)
        courseName = String()
        tees = String()
    }
    init(number: Int, length: Int, par: Int, handicap: Int, centerOfGreen: CLLocation, courseName: String, tees: String) {
        self.number = number
        self.length = length
        self.par = par
        self.handicap = handicap
        self.centerOfGreen = centerOfGreen
        self.courseName = courseName
        self.tees = tees
    }
    
    func getNumber() -> Int {
        return number
    }
    
    func getHandicap() -> Int {
        return handicap
    }
    
    func getLength() -> Int {
        return length
    }
    
    func getPar() -> Int {
        return par
    }
    
    func getCenterOfGreen() -> CLLocation {
        return centerOfGreen
    }
    
    func getCourseName() -> String {
        return courseName
    }
}
