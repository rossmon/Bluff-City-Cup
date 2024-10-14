//
//  Model.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 11/22/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

// Specify the protocol to be used by view controllers to handle notifications.
protocol ModelDelegate {
    func errorUpdating(_ error: NSError)
    func modelUpdated()
}

class Model: NSObject, URLSessionDataDelegate {
    
    // MARK: - Properties
    static let sharedInstance = Model()
    var delegate: ModelDelegate?
    
    //var user: User = User.sharedInstance
    var matches: [Match] = [Match]()
    var players: [Player] = []
    var currentMatch: Match!
    var course: Course!
    var tournament: Tournament!
    var tournamentRecord: CKRecord!
    
    
    // Define databases.
    
    // Represents the default container specified in the iCloud section of the Capabilities tab for the project.
    //let container: CKContainer
    //let publicDB: CKDatabase
    //let privateDB: CKDatabase
    
    // MARK: - Initializers
    private override init() {
        /*
         container = CKContainer.default()
         publicDB = container.publicCloudDatabase
         privateDB = container.privateCloudDatabase*/
        
        course = Course()
        
    }
    
    func loadData(tournamentName: String, _ loadCompletion: @escaping (_ errorString: String) -> Void) {
        
        getURLData(tournamentName) {
            self.tournament.updateUserMatchHoleScores()
            
            loadCompletion("No Error")
        }
    }
    
    
    func refresh(_ completion: @escaping (_ errorString: String) -> Void) {
        //Code for other views to refresh data
        if (self.tournament) != nil {
            self.loadData(tournamentName: tournament.getName()) { errorString in
                completion(errorString)
            }
        }
        else {
            completion("No Tournament Value")
        }
    }
    
    func updateHoleScoreRecord(player: Player, round: Int, course: String, hole: Int, score: Int, _ completion: @escaping () -> Void) {
        
        let tournamentNameURL = self.tournament.getName().replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        let playerName = player.getName().replacingOccurrences(of: " ", with: "!spa")
        let courseName = course.replacingOccurrences(of: " ", with: "!spa")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Save player data
        let urlPath: String = "http://montyratings.com/bluffcitycup/update_scores.php?tournament=" + tournamentNameURL + "&player=" + playerName + "&round=\(round)&course=" + courseName + "&hole=\(hole)&actualscore=\(score)"
        
        let url = NSURL(string: urlPath)!
        
        let holeResultTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            print("Saving hole result")
            
            guard error == nil else {
                print("error calling hole result")
                completion()
                return
            }
            // make sure we got data
            if data != nil  {
                print("Success saving hole result")
            }
            else {
                print("Error: did not save hole result data")
                
            }
            completion()
            return
        })
        
        holeResultTask.resume()
    }
    
    func getTournament() -> Tournament {
        return self.tournament
    }
    func getPlayers() -> [Player] {
        return self.players
    }
    /*
     func getUser() -> User {
     return self.user
     }*/
    func getMatches() -> [Match] {
        return self.matches
    }
    func getCurrentMatch() -> Match {
        return self.currentMatch
    }
    func getCourse() -> Course {
        return self.course
    }
    
    func checkTournament(tournamentName: String, _ completion: @escaping (_ found: Bool, _ commissioner: String, _ commishPassword: String) -> Void) {
        
        
        /*
         let coursePredicate = NSPredicate(format: "Name = %@",tournamentName)
         let query = CKQuery(recordType: "Tournament", predicate: coursePredicate)
         
         publicDB.perform(query, inZoneWith: nil) { results, error in
         if error != nil {
         print(error.debugDescription)
         }
         
         if results?.count == 0 || results == nil {
         completion(true, "")
         }
         else {
         completion(true, results![0]["Commissioner"] as! String)
         }
         }*/
        
        
        //START PSQL
        
        let tournamentNameURL = tournamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathMatches: String = "http://montyratings.com/bluffcitycup/tournament.php?tournament=" + tournamentNameURL
        
        let urlMatches = NSURL(string: urlPathMatches)!
        
        let tournamentTask = session.dataTask(with: urlMatches as URL, completionHandler: { (data, response, error) in
            print("GETTING TOURNAMENT")
            
            guard error == nil else {
                print("error getting tournament")
                print(error!)
                completion(true,"","")
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive tournament data")
                completion(true,"","")
                return
            }
            
            //parse JSON
            
            
            var jsonResult: NSArray = NSArray()
            
            do{
                jsonResult = try JSONSerialization.jsonObject(with: data! as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                
                
            } catch let error as NSError {
                print(error)
                
            }
            
            var jsonElement: NSDictionary = NSDictionary()
            var total = 0
            if jsonResult.count > 0 { total = jsonResult.count - 1 }
            
            if jsonResult.count > 0 {
                for i in 0 ... (total)
                {
                    
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    //the following insures none of the JsonElement values are nil through optional binding
                    if let _ = jsonElement["tournament"] as? String,
                        let commissionerString = jsonElement["commissioner"] as? String
                    {
                        let commissioner = commissionerString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let commishpassword = (jsonElement["commishpassword"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        
                        completion(true, commissioner, commishpassword)
                    }
                    else {
                        completion(true,"", "")
                    }
                }
            }
            else
            {
                completion(false,"","")
            }
            
            
        })
        
        tournamentTask.resume()
        
    }
    
    func checkUser(userName: String, tournamentName: String, _ completion: @escaping (_ found: Bool, _ player: Player?, _ isInCurrentMatch: Bool) -> Void) {
        
        // START PSQL
        var foundPlayer = Player()
        
        let tournamentNameURL = tournamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        let playerName = userName.replacingOccurrences(of: " ", with: "!spa")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathMatches: String = "http://montyratings.com/bluffcitycup/players.php?tournament=" + tournamentNameURL + "&player=" + playerName
        
        let urlMatches = NSURL(string: urlPathMatches)!
        
        let playerTask = session.dataTask(with: urlMatches as URL, completionHandler: { (data, response, error) in
            print("GETTING PLAYER")
            
            guard error == nil else {
                print("error getting player")
                print(error!)
                completion(false,nil,false)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive player data")
                completion(false,nil,false)
                return
            }
            
            //parse JSON
            
            
            var jsonResult: NSArray = NSArray()
            
            do{
                jsonResult = try JSONSerialization.jsonObject(with: data! as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                
                
            } catch let error as NSError {
                print(error)
                
            }
            
            var jsonElement: NSDictionary = NSDictionary()
            var total = 0
            if jsonResult.count > 0 { total = jsonResult.count - 1 }
            
            if jsonResult.count > 0 {
                for i in 0 ... (total)
                {
                    
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    //the following insures none of the JsonElement values are nil through optional binding
                    if let _ = jsonElement["tournament"] as? String,
                        let nameString = jsonElement["name"] as? String
                    {
                        let name = nameString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let handicap = Double((jsonElement["handicap"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                        let teamString = jsonElement["team"] as! String
                        let team = teamString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        
                        foundPlayer = Player(name: name, handicap: handicap, team: team)
                        
                        self.checkPlayerInCurrentMatch(foundPlayer.getName(),tounamentName: tournamentName) { found in
                            completion(true,foundPlayer,found)
                        }
                    }
                }
            }
            else
            {
                completion(false,nil,false)
            }
            
            
        })
        
        playerTask.resume()
    }
    
    func checkPlayerInCurrentMatch(_ playerName: String, tounamentName: String, _ completion: @escaping (_ found: Bool) -> Void) {
        
        let tournamentNameURL = tounamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        let playerName = playerName.replacingOccurrences(of: " ", with: "!spa")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathMatches: String = "http://montyratings.com/bluffcitycup/player_in_match.php?tournament=" + tournamentNameURL + "&player=" + playerName
        
        let urlMatches = NSURL(string: urlPathMatches)!
        
        let checkCurrentTask = session.dataTask(with: urlMatches as URL, completionHandler: { (data, response, error) in
            print("CHECKING PLAYER IN MATCH")
            
            guard error == nil else {
                print("error getting player in match")
                print(error!)
                completion(false)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive player in match data")
                completion(false)
                return
            }
            
            //parse JSON
            
            
            var jsonResult: NSArray = NSArray()
            
            do{
                jsonResult = try JSONSerialization.jsonObject(with: data! as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                
                
            } catch let error as NSError {
                print(error)
                
            }
            
            if jsonResult.count > 0 { completion(true) }
            else { completion(false) }
            
            
        })
        
        checkCurrentTask.resume()
        
    }
    
    func checkCreatePassword(_ password: String, _ completion: @escaping (_ found: Bool) -> Void) {
        
        let passwordURL = password.replacingOccurrences(of: " ", with: "!spa")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathMatches: String = "http://montyratings.com/bluffcitycup/check_create_password.php?password=" + passwordURL
        print(urlPathMatches)
        
        let urlMatches = NSURL(string: urlPathMatches)!
        
        let checkCurrentTask = session.dataTask(with: urlMatches as URL, completionHandler: { (data, response, error) in
            print("CHECKING VALID PASSWORD")
            
            guard error == nil else {
                print("error getting password check")
                print(error!)
                completion(false)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive password validation")
                completion(false)
                return
            }
            
            //parse JSON
            
            
            var jsonResult: NSArray = NSArray()
            
            do{
                jsonResult = try JSONSerialization.jsonObject(with: data! as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                
                
            } catch let error as NSError {
                print(error)
                
            }
            
            if jsonResult.count > 0 { completion(true) }
            else { completion(false) }
            
            
        })
        
        checkCurrentTask.resume()
        
    }
    
    func checkScorekeeper(userName: String, tournamentName: String, _ completion: @escaping (_ isScorekeeper: Bool, _ isInCurrentMatch: Bool) -> Void) {
        
        // START PSQL
        
        let tournamentNameURL = tournamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        let scorekeeper = userName.replacingOccurrences(of: " ", with: "!spa")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathMatches: String = "http://montyratings.com/bluffcitycup/scorekeeper_matches.php?tournament=" + tournamentNameURL + "&scorekeeper=" + scorekeeper
        
        let urlMatches = NSURL(string: urlPathMatches)!
        
        let matchesTask = session.dataTask(with: urlMatches as URL, completionHandler: { (data, response, error) in
            print("GETTING MATCHES")
            
            guard error == nil else {
                print("error getting matches")
                print(error!)
                completion(false,false)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive match data")
                completion(false,false)
                return
            }
            
            //parse JSON
            
            var checkScorekeeper = false
            var userMatches = [(round: Int, matchFinished: Bool, scorekeeper: Bool)]()
            var finished = false
            
            
            var jsonResult: NSArray = NSArray()
            
            do{
                jsonResult = try JSONSerialization.jsonObject(with: data! as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                
                
            } catch let error as NSError {
                print(error)
                
            }
            
            var jsonElement: NSDictionary = NSDictionary()
            var total = 0
            if jsonResult.count > 0 { total = jsonResult.count - 1 }
            
            if jsonResult.count > 0 {
                for i in 0 ... (total)
                {
                    
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    //the following insures none of the JsonElement values are nil through optional binding
                    if let _ = jsonElement["tournament"] as? String,
                        let roundString = jsonElement["round"] as? String
                    {
                        
                        let completed = Int((jsonElement["completed"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                        
                        let trimmedRound = roundString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        
                        if completed == 1 { finished = true }
                        else { finished = false }
                        
                        let scorekeeper = (jsonElement["scorekeeper"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        
                        if scorekeeper == userName {
                            userMatches.append((round: Int(trimmedRound)!, matchFinished: finished, scorekeeper: true))
                        }
                        else {
                            userMatches.append((round: Int(trimmedRound)!, matchFinished: finished, scorekeeper: false))
                        }
                        
                        
                    }
                }
            }
            else
            {
                self.checkPlayerInCurrentMatch(userName, tounamentName: tournamentName) { found in
                    
                    completion(false,found)
                }
            }
            
            
            for eachMatch in userMatches {
                if !eachMatch.matchFinished && eachMatch.scorekeeper {
                    checkScorekeeper = true
                    break
                }
                else if !eachMatch.matchFinished && !eachMatch.scorekeeper {
                    checkScorekeeper = false
                    break
                }
            }
            
            self.checkPlayerInCurrentMatch(userName, tounamentName: tournamentName) { found in
                
                completion(checkScorekeeper,found)
            }
            
        })
        
        matchesTask.resume()
        
    }
    
    /*
     func getUserInfo(_ completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
     var userName = ""
     
     DispatchQueue.main.async {
     CKContainer.default().requestApplicationPermission(.userDiscoverability) { (status, error1) in
     CKContainer.default().fetchUserRecordID { (record, error2) in
     if #available(iOS 10.0, *) {
     if error2 != nil {
     print(error2.debugDescription)
     completion("User ID", error2)
     }
     else {
     if record != nil {
     
     CKContainer.default().discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userRecordID, error3) in
     if userRecordID != nil {
     userName = (userRecordID?.nameComponents?.givenName)! + " " + (userRecordID?.nameComponents?.familyName)!
     print("CK User Name: " + userName)
     User.sharedInstance.setUserName(userName)
     completion(nil, error3)
     }
     else {
     if error3 != nil {
     print(error3.debugDescription)
     print(error3!.localizedDescription)
     }
     completion("No User", error3)
     }
     })
     }
     else {
     completion("iCloud Login", error2)
     }
     }
     } else {
     // Fallback on earlier versions
     completion("Upgrade", error2)
     }
     }
     }
     }
     }
     */
    
    
    func getTournamentNames(_ completion: @escaping (_ tournaments: [(name: String, commish: String)]) -> Void){
        
        /*
         let query = CKQuery(recordType: "Tournament", predicate: NSPredicate(value: true))
         var tournamentNames = [(name: String, commish: String)]()
         
         publicDB.perform(query, inZoneWith: nil) { results, error in
         if error != nil  {
         print(error.debugDescription)
         }
         else {
         for result in results! {
         tournamentNames.append((result["Name"] as! String, result["Commissioner"] as! String))
         }
         }
         
         completion(tournamentNames)
         }*/
        
        // START PSQL
        
        var tournamentNames = [(name: String, commish: String)]()
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathMatches: String = "http://montyratings.com/bluffcitycup/tournament.php"
        
        let urlMatches = NSURL(string: urlPathMatches)!
        
        let tournamentTask = session.dataTask(with: urlMatches as URL, completionHandler: { (data, response, error) in
            print("GETTING TOURNAMENTS")
            
            guard error == nil else {
                print("error getting tournaments")
                print(error!)
                completion(tournamentNames)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive tournaments data")
                completion(tournamentNames)
                return
            }
            
            //parse JSON
            
            
            var jsonResult: NSArray = NSArray()
            
            do{
                jsonResult = try JSONSerialization.jsonObject(with: data! as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                
                
            } catch let error as NSError {
                print(error)
                
            }
            
            var jsonElement: NSDictionary = NSDictionary()
            var total = 0
            if jsonResult.count > 0 { total = jsonResult.count - 1 }
            
            if jsonResult.count > 0 {
                for i in 0 ... (total)
                {
                    
                    jsonElement = jsonResult[i] as! NSDictionary
                    
                    //the following insures none of the JsonElement values are nil through optional binding
                    if let tourneyString = jsonElement["tournament"] as? String,
                        let commishString = jsonElement["commissioner"] as? String
                    {
                        let tournament = tourneyString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let commissioner = commishString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        
                        tournamentNames.append((name: tournament, commish: commissioner))
                        tournamentNames.sort(by: { $0.name < $1.name })
                        // tournamentNames = tournamentNames.sorted(by: { $0.name < $0.name})

                    }
                }
            }
            
            completion(tournamentNames)
        })
        
        tournamentTask.resume()
        
    }
    
    func addPlayerRecord(player: Player, tournamentName: String, _ completion: @escaping () -> Void) {
        
        //ADD CODE TO ADD A SCORE RECORD TO THE DATABASE
        self.updatePlayer(player) {
            completion()
        }
        
    }
    
    func addMatchRecord(match: Match, tournamentName: String, _ completion: @escaping () -> Void) {
        
        //ADD CODE TO ADD A SCORE RECORD TO THE DATABASE
        self.updateMatch(match) {
            completion()
        }
        
    }
    
    func deleteAllMatches(tournamentName: String) {
        
        let tournamentNameURL = self.tournament.getName().replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Delete score data
        let urlPath: String = "http://montyratings.com/bluffcitycup/delete_scores.php?tournament=" + tournamentNameURL
        
        print(urlPath)
        
        let url = NSURL(string: urlPath)!
        
        let deleteScoresTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            
            print("Deleted scores")
            return
        })
        
        deleteScoresTask.resume()
        
        var session2: URLSession!
        let configuration2 = URLSessionConfiguration.default
        
        session2 = URLSession(configuration: configuration2, delegate: self, delegateQueue: nil)
        
        // Delete match data
        let urlPath2: String = "http://montyratings.com/bluffcitycup/delete_matches.php?tournament=" + tournamentNameURL
        
        print(urlPath2)
        
        let url2 = NSURL(string: urlPath2)!
        
        let deleteMatchesTask = session2.dataTask(with: url2 as URL, completionHandler: { (data, response, error) in
            
            print("Deleted matches")
            return
        })
        
        deleteMatchesTask.resume()
        
        self.tournament.deleteMatches()
        self.matches = [Match]()
    }
    
    func deletePlayer(_ player: Player) {
        
        let tournamentNameURL = self.tournament.getName().replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        let playerName = player.getName().replacingOccurrences(of: " ", with: "!spa")
        let team = player.getTeam().replacingOccurrences(of: " ", with: "!spa")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Delete player data
        let urlPath: String = "http://montyratings.com/bluffcitycup/delete_player.php?tournament=" + tournamentNameURL + "&player=" + playerName + "&team=" + team + ""
        
        let url = NSURL(string: urlPath)!
        
        let deletePlayerTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            
            print("Deleted player " + player.getName())
            return
        })
        
        deletePlayerTask.resume()
    }
    
    func deleteMatch(_ match: Match) {
        
        let tournamentNameURL = self.tournament.getName().replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Delete match data
        let urlPath: String = "http://montyratings.com/bluffcitycup/delete_match.php?tournament=" + tournamentNameURL + "&round=\(match.getRound())&matchgroup=\(match.getGroup())&match=\(match.getMatchNumber())"
        
        
        let url = NSURL(string: urlPath)!
        
        let deleteMatchTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            
            print("Deleted match")
            return
        })
        
        deleteMatchTask.resume()
        
    }
    
    
    func updateTournament(_ tournament: Tournament, _ completion: @escaping () -> Void) {
        
        let tournamentNameURL = tournament.getName().replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var ownerURL = "Ross!spaMontague"
        print(tournament.getOwner())
        if tournament.getOwner() != "" {
            ownerURL = tournament.getOwner().replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        }
        
        
        var drinkcart = 0
        if tournament.isDrinkCartAvailable() { drinkcart = 1 }
        var drinkcartnumber = ""
        if let dcn = tournament.getDrinkCartNumber() {
            drinkcartnumber = dcn
        }
        
        
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Save player data
        let urlPath: String = "http://montyratings.com/bluffcitycup/update_tournament.php?tournament=" + tournamentNameURL + "&owner=" + ownerURL + "&commissioner=" + ownerURL + "&matchlength=\(tournament.getMatchLength())&numberofmatches=\(tournament.getNumberOfMatches())&drinkcartavailable=\(drinkcart)&drinkcartnumber=" + drinkcartnumber + "&currentround=\(tournament.getCurrentRound())&maxhandicap=\(tournament.getMaxHandicap())&commishpassword=" + tournament.getCommissionerPassword()
        
        print(urlPath)
        
        let url = NSURL(string: urlPath)!
        
        let tournamentTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            print("Saving tournament")
            
            guard error == nil else {
                print("error calling tournament")
                completion()
                return
            }
            // make sure we got data
            if data != nil  {
                print("Success saving tournament")
            }
            else {
                print("Error: did not save tournament data")
                
            }
            completion()
            return
        })
        
        tournamentTask.resume()
        
    }
    
    func updatePlayer(_ player: Player, _ completion: @escaping () -> Void) {
        
        let tournamentNameURL = self.tournament.getName().replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        let playerName = player.getName().replacingOccurrences(of: " ", with: "!spa")
        let team = player.getTeam()
        
        let handicapString = String(player.getHandicap()).replacingOccurrences(of: ".", with: "!dot")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Save player data
        let urlPath: String = "http://montyratings.com/bluffcitycup/update_players.php?tournament=" + tournamentNameURL + "&name=" + playerName + "&team=" + team + "&handicap=" + handicapString
        
        let url = NSURL(string: urlPath)!
        
        let playerTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            print("Saving player")
            
            guard error == nil else {
                print("error calling players")
                completion()
                return
            }
            // make sure we got data
            if data != nil  {
                print("Success saving player")
                print(data.debugDescription)
                print(error.debugDescription)
                print(response.debugDescription)
            }
            else {
                print("Error: did not save player data")
                
            }
            completion()
            return
        })
        
        playerTask.resume()
        
    }
    
    func updateMatch(_ match: Match, _ completion: @escaping () -> Void) {
        
        let courseNameURL = match.getCourse().replacingOccurrences(of: " ", with: "!spa")
        let tournamentNameURL = self.tournament.getName().replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        let player1 = match.blueTeamPlayerOne().getName().replacingOccurrences(of: " ", with: "!spa")
        let player2 = match.redTeamPlayerOne().getName().replacingOccurrences(of: " ", with: "!spa")
        let player1team = match.blueTeamPlayerOne().getTeam().replacingOccurrences(of: " ", with: "!spa")
        let player2team = match.redTeamPlayerOne().getTeam().replacingOccurrences(of: " ", with: "!spa")
        let format = match.getFormat().replacingOccurrences(of: " ", with: "!spa")
        let scorekeeper = match.getScorekeeperName().replacingOccurrences(of: " ", with: "!spa")
        let scorestring = match.getMatchScore(matchLength: self.tournament.getMatchLength()).scoreString.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        let score = match.getMatchScore(matchLength: self.tournament.getMatchLength())
        let tees = match.getTees().replacingOccurrences(of: " ", with: "!spa")
        
        var completed = 0
        if score.finished { completed = 1 }
        
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Change the point value of matches?
        
        // Save hole data
        var urlPath = "http://montyratings.com/bluffcitycup/update_matches.php?tournament=" + tournamentNameURL + "&round=\(match.getRound())&matchgroup=\(match.getGroup())&match=\(match.getMatchNumber())&course=" + courseNameURL + "&slope=\(match.getCourseSlope())&format=" + format + "&scorekeeper=" + scorekeeper + "&points=1&numofplayers=\(match.getPlayers().count)&startinghole=\(match.getStartingHole())&currenthole=\(match.getCurrentHole())&currentscore=\(score.score)&scorestring=" + scorestring + "&winningteam=" + score.teamUp + "&completed=\(completed)&player1=" + player1 + "&player1team=" + player1team + "&player2=" + player2 + "&player2team=" + player2team + "&tees=" + tees
        
        if match.doubles() {
            let player3 = match.blueTeamPlayerTwo()!.getName().replacingOccurrences(of: " ", with: "!spa")
            let player4 = match.redTeamPlayerTwo()!.getName().replacingOccurrences(of: " ", with: "!spa")
            let player3team = match.blueTeamPlayerTwo()!.getTeam().replacingOccurrences(of: " ", with: "!spa")
            let player4team = match.redTeamPlayerTwo()!.getTeam().replacingOccurrences(of: " ", with: "!spa")
            
            urlPath = urlPath + "&player3=" + player3 + "&player3team=" + player3team + "&player4=" + player4 + "&player4team=" + player4team
        }
        
        
        
        let url = NSURL(string: urlPath)!
        
        let matchTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            print("Saving Match")
            
            guard error == nil else {
                print("error save match")
                completion()
                return
            }
            // make sure we got data
            if data != nil  {
                print("Success saving match")
            }
            else {
                print("Error: did not save match data")
                
            }
            completion()
            return
        })
        
        matchTask.resume()
    }
    
    func setTournament(_ tournamentIn: Tournament) {
        self.tournament = tournamentIn
    }
    
    
    func addCourse(holes: [(number: Int, handicap: Int, length: Int, par: Int, location: CLLocation)], courseName: String, tees: String, slope: Int) {
        print("Adding course")
        
        for eachHole in holes {
            
            var session: URLSession!
            let configuration = URLSessionConfiguration.default
            let courseNameURL = courseName.replacingOccurrences(of: " ", with: "!spa")
            
            session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
            
            // Save hole data
            let urlPath: String = "http://montyratings.com/bluffcitycup/update_holes.php?course=" + courseNameURL + "&holenumber=" + String(eachHole.number) + "&handicap=" + String(eachHole.handicap) + "&par=" + String(eachHole.par) + "&length=" + String(eachHole.length) + "&lat=\(eachHole.location.coordinate.latitude)&long=\(eachHole.location.coordinate.longitude)&tees=" + tees
            let url = NSURL(string: urlPath)!
            
            let holeAddTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
                print("Saving Hole")
                
                guard error == nil else {
                    print("error calling players")
                    return
                }
                // make sure we got data
                if data != nil  {
                    print("Success saving hole")
                }
                else {
                    print("Error: did not save hole data")
                    
                }
                return
            })
            
            holeAddTask.resume()
        }
        
        addCourseSlopeRecord(courseName: courseName, tees: tees, slope: slope)
    }
    
    func addCourseSlopeRecord(courseName: String, tees: String, slope: Int) {
        print("Adding course master")
        
        
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        let courseNameURL = courseName.replacingOccurrences(of: " ", with: "!spa")
        let teesURL = tees.replacingOccurrences(of: " ", with: "!spa")
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Save course data
        let urlPath: String = "http://montyratings.com/bluffcitycup/update_courses.php?course=" + courseNameURL + "&tees=" + teesURL + "&lat=\(slope)"
        let url = NSURL(string: urlPath)!
        
        let courseAddTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            print("Saving Course")
            
            guard error == nil else {
                print("error calling course")
                return
            }
            // make sure we got data
            if data != nil  {
                print("Success saving course")
            }
            else {
                print("Error: did not save course data")
                
            }
            return
        })
        
        courseAddTask.resume()
        
    }
    
    func getURLData(_ tournamentName: String, _ completion: @escaping () -> () ) {
        
        self.fetchPlayersJSON(tournamentName: tournamentName) { (playerRecords: [Player]?, error: Error?) in
            
            self.fetchCoursesJSON(tournamentName: tournamentName) { (courseRecords: [(course: String, tees: String, slope: Int, rating: Double, par: Double)]?, error: Error?) in
                
                self.fetchRoundsJSON(tournamentName: tournamentName) { (roundRecords: [(round: Int, course: String)]?, errorRounds: Error?) in
                    
                    self.fetchScoresJSON(tournamentName: tournamentName, players: playerRecords!) { (scoreRecords: [(playerName: String, round: Int, course: String, hole: Int, score: Int)]?, playerScoreRecords: [Player], errorScores: Error?) in
                        
                        self.fetchMatchesJSON(tournamentName: tournamentName, players: playerScoreRecords, scores: scoreRecords!) { (matches: [Match]?, errorMatches: Error?) in
                            
                            self.fetchHolesJSON(courseRecords: courseRecords!) { (courses: [Course]?, errorMatches: Error?) in
                                
                                self.fetchTournamentJSON(tournamentName: tournamentName, players: playerScoreRecords, matches: matches!, rounds: roundRecords!, courses: courses!) { (tournament: Tournament?, errorMatches: Error?) in
                                    
                                    self.players = playerRecords!
                                    self.matches = matches!
                                    self.tournament = tournament
                                    
                                    for match in self.tournament.getMatches() {
                                        match.refreshHoleWinners()
                                    }
                                    
                                    completion()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchPlayersJSON(tournamentName: String, _ completion: @escaping (_ playerRecords: [Player]?, _ error: Error?) -> () ) {
        
        var players = [Player]()
        
        let tournamentNameURL = tournamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Fetch player data
        let urlPath: String = "http://montyratings.com/bluffcitycup/players.php?tournament=" + tournamentNameURL
        let url = NSURL(string: urlPath)!
        
        let playerTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            print("GETTING PLAYERS")
            
            guard error == nil else {
                print("error calling players")
                completion(players,error)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive player data")
                completion(players,error)
                return
            }
            
            players = self.parseJSONplayers(data: data!)
            completion(players,error)
        })
        
        playerTask.resume()
        
    }
    
    func fetchRoundsJSON(tournamentName: String, _ completion: @escaping (_ roundRecords: [(round: Int, course: String)]?, _ error: Error?) -> () ) {
        
        var tournamentRounds = [(round: Int, course: String)]()
        
        let tournamentNameURL = tournamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fetch round data
        let urlPathRounds: String = "http://montyratings.com/bluffcitycup/rounds.php?tournament=" + tournamentNameURL
        let urlRounds = NSURL(string: urlPathRounds)!
        
        let roundsTask = session.dataTask(with: urlRounds as URL, completionHandler: { (data, response, error) in
            print("GETTING ROUNDS")
            
            guard error == nil else {
                print("error getting rounds")
                print(error!)
                completion(tournamentRounds,error)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive round data")
                completion(tournamentRounds,error)
                return
            }
            
            tournamentRounds = self.parseJSONrounds(data: data!)
            completion(tournamentRounds,error)
        })
        
        roundsTask.resume()
        
    }
    
    func fetchScoresJSON(tournamentName: String, players: [Player], _ completion: @escaping (_ scoreRecords: [(playerName: String, round: Int, course: String, hole: Int, score: Int)]?,_ playerScoreRecords: [Player], _ error: Error?) -> () ) {
        
        var scores = [(playerName: String, round: Int, course: String, hole: Int, score: Int)]()
        var playersWithScores = [Player]()
        
        let tournamentNameURL = tournamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fetch scores data
        let urlPathScores: String = "http://montyratings.com/bluffcitycup/scores.php?tournament=" + tournamentNameURL
        let urlScores = NSURL(string: urlPathScores)!
        
        let scoresTask = session.dataTask(with: urlScores as URL, completionHandler: { (data, response, error) in
            print("GETTING SCORES")
            
            guard error == nil else {
                print("error getting rounds")
                print(error!)
                completion(scores,players,error)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive round data")
                completion(scores,players,error)
                return
            }
            
            (scores, playersWithScores) = self.parseJSONscores(data: data!, players: players)
            completion(scores,playersWithScores,error)
        })
        
        scoresTask.resume()
        
    }
    
    func fetchMatchesJSON(tournamentName: String, players: [Player], scores: [(playerName: String, round: Int, course: String, hole: Int, score: Int)], _ completion: @escaping (_ matchRecords: [Match]?, _ error: Error?) -> () ) {
        
        var matches = [Match]()
        
        let tournamentNameURL = tournamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathMatches: String = "http://montyratings.com/bluffcitycup/matches.php?tournament=" + tournamentNameURL
        let urlMatches = NSURL(string: urlPathMatches)!
        
        let matchesTask = session.dataTask(with: urlMatches as URL, completionHandler: { (data, response, error) in
            print("GETTING MATCHES")
            
            guard error == nil else {
                print("error getting matches")
                print(error!)
                completion(matches,error)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive match data")
                completion(matches,error)
                return
            }
            
            matches = self.parseJSONmatches(data: data!, players: players, scores: scores)
            completion(matches,error)
        })
        
        matchesTask.resume()
        
    }
    
    func fetchHolesJSON(courseRecords: [(course: String, tees: String, slope: Int, rating: Double, par: Double)], _ completion: @escaping (_ courses: [Course]?, _ error: Error?) -> () ) {
        
        var courses = [Course]()
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathHoles: String = "http://montyratings.com/bluffcitycup/holes.php"
        let urlHoles = NSURL(string: urlPathHoles)!
        
        let holesTask = session.dataTask(with: urlHoles as URL, completionHandler: { (data, response, error) in
            print("GETTING HOLES")
            
            guard error == nil else {
                print("error getting holes")
                print(error!)
                completion(courses,error)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive hole data")
                completion(courses,error)
                return
            }
            
            courses = self.parseJSONholes(data: data!, courseRecords: courseRecords)
            completion(courses,error)
        })
        
        holesTask.resume()
        
    }
    
    func fetchCoursesJSON(tournamentName: String, _ completion: @escaping (_ courseRecords: [(course: String, tees: String, slope: Int, rating: Double, par: Double)]?, _ error: Error?) -> () ) {
        
        var courses = [(course: String, tees: String, slope: Int, rating: Double, par: Double)]()
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        //Fatch match data
        let urlPathHoles: String = "http://montyratings.com/bluffcitycup/courses.php?"
        let urlHoles = NSURL(string: urlPathHoles)!
        
        let coursesTask = session.dataTask(with: urlHoles as URL, completionHandler: { (data, response, error) in
            print("GETTING COURSES")
            
            guard error == nil else {
                print("error getting courses")
                print(error!)
                completion(courses,error)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive course data")
                completion(courses,error)
                return
            }
            
            courses = self.parseJSONcourses(data: data!)
            completion(courses,error)
        })
        
        coursesTask.resume()
        
    }
    
    func fetchTournamentJSON(tournamentName: String, players: [Player], matches: [Match], rounds: [(round: Int, course: String)], courses: [Course], _ completion: @escaping (_ tournament:Tournament?, _ error: Error?) -> () ) {
        
        var tournament = Tournament()
        
        let tournamentNameURL = tournamentName.replacingOccurrences(of: " ", with: "!spa").replacingOccurrences(of: "&", with: "!amp")
        
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        // Fetch Tournament Data
        let urlPathTourney: String = "http://montyratings.com/bluffcitycup/tournament.php?tournament=" + tournamentNameURL
        let urlTourney = NSURL(string: urlPathTourney)!
        
        let tourneyTask = session.dataTask(with: urlTourney as URL, completionHandler: { (data, response, error) in
            print("GETTING TOURNAMENTS")
            
            guard error == nil else {
                print("error calling tournament")
                print(error!)
                completion(tournament,error)
                return
            }
            // make sure we got data
            guard data != nil else {
                print("Error: did not receive tournament data")
                completion(tournament,error)
                return
            }
            
            tournament = self.parseJSONtournament(data: data!, players: players, matches: matches, rounds: rounds, courses: courses)
            completion(tournament,error)
        })
        
        tourneyTask.resume()
        
    }
    
    
    func parseJSONplayers(data: Data) -> [Player] {
        var players = [Player]()
        var jsonResult: NSArray = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        var total = 0
        if jsonResult.count > 0 { total = jsonResult.count - 1 }
        
        if jsonResult.count > 0 {
            for i in 0 ... (total)
            {
                
                jsonElement = jsonResult[i] as! NSDictionary
                
                //the following insures none of the JsonElement values are nil through optional binding
                if let name = jsonElement["name"] as? String,
                    let hdcp = jsonElement["handicap"] as? String,
                    let team = jsonElement["team"] as? String
                {
                    let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedTeam = team.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let player = Player(name: trimmedName, handicap: Double(hdcp)!, team: trimmedTeam)
                    players.append(player)
                    print(name)
                    print(hdcp)
                    
                }
                
            }
        }
        
        return players
    }
    
    func parseJSONtournament(data: Data, players: [Player],matches: [Match], rounds: [(round: Int, course: String)], courses: [Course]) -> Tournament {
        var tournament = Tournament()
        var jsonResult: NSArray = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
            
        } catch let error as NSError {
            print(error)
            
        }
        
        let jsonElement: NSDictionary = jsonResult[0] as! NSDictionary
        
        //the following insures none of the JsonElement values are nil through optional binding
        if let tourneyname = jsonElement["tournament"] as? String
        {
            //let owner = (jsonElement["owner"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            //let commissioner = (jsonElement["commissioner"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let matchLength = Int((jsonElement["matchlength"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
            let numberofmatches = Int((jsonElement["numberofmatches"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
            
            var drinkcartavail = false
            if let DCavail = jsonElement["drinkcartavailable"] as? String {
                if Int(DCavail)! == 1 {
                    drinkcartavail = true
                }
            }
            
            
            
            let currentround = Int((jsonElement["currentround"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
            let trimmedTourneyName = tourneyname.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let maxHandicap = Int((jsonElement["maxhandicap"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
            let commishPassword = (jsonElement["commishpassword"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            tournament = Tournament(matches: matches, name: trimmedTourneyName, numOfRounds: numberofmatches, currentRound: currentround, matchLength: matchLength, drinkCartAvailable: drinkcartavail, playersInit: players, roundCourses: rounds, maxhandicap: maxHandicap, commishPassword: commishPassword)
            
            if let drinkcartnumber = jsonElement["drinkcartnumber"] as? String {
                let cartNumber = drinkcartnumber.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                tournament.setDrinkCartNumber(cartNumber)
            }
            
            for course in courses {
                tournament.appendCourse(course: course)
            }
            
            
        }
        
        return tournament
    }
    
    func parseJSONscores(data: Data, players: [Player]) -> ([(playerName: String, round: Int, course: String, hole: Int, score: Int)],[Player]) {
        var scores = [(playerName: String, round: Int, course: String, hole: Int, score: Int)]()
        var jsonResult: NSArray = NSArray()
        
        let playersWithScores = players
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        var total = 0
        if jsonResult.count > 0 { total = jsonResult.count - 1 }
        
        if jsonResult.count > 0 {
            for i in 0 ... (total)
            {
                
                jsonElement = jsonResult[i] as! NSDictionary
                
                //the following insures none of the JsonElement values are nil through optional binding
                if let _ = jsonElement["tournament"] as? String,
                    let player = jsonElement["player"] as? String,
                    let round = jsonElement["round"] as? String,
                    let course = jsonElement["course"] as? String,
                    let hole = jsonElement["hole"] as? String,
                    let score = jsonElement["actualscore"] as? String
                {
                    //let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedPlayer = player.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedRound = round.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedCourse = course.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedHole = hole.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedScore = score.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    scores.append((playerName: trimmedPlayer, round: Int(trimmedRound)!, course: trimmedCourse, hole: Int(trimmedHole)!, score: Int(trimmedScore)!))
                    
                    for player in playersWithScores {
                        if player.getName() == trimmedPlayer {
                            player.setHoleResults(round: Int(trimmedRound)!,holeNumber: Int(trimmedHole)!,score: Int(trimmedScore)!)
                        }
                    }
                }
                
            }
            
        }
        
        return (scores,playersWithScores)
    }
    
    func parseJSONrounds(data: Data) -> [(round: Int, course: String)] {
        var rounds = [(round: Int, course: String)]()
        var jsonResult: NSArray = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        var total = 0
        if jsonResult.count > 0 { total = jsonResult.count - 1 }
        
        if jsonResult.count > 0 {
            for i in 0 ... (total)
            {
                
                jsonElement = jsonResult[i] as! NSDictionary
                
                //the following insures none of the JsonElement values are nil through optional binding
                if let _ = jsonElement["tournament"] as? String,
                    let round = jsonElement["round"] as? String,
                    let course = jsonElement["course"] as? String
                {
                    //let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedRound = round.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedCourse = course.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    rounds.append((round: Int(trimmedRound)!, course: trimmedCourse))
                }
                
            }
        }
        
        return rounds
    }
    
    func parseJSONmatches(data: Data, players: [Player], scores: [(playerName: String, round: Int, course: String, hole: Int, score: Int)]) -> [Match] {
        var matches = [Match]()
        var jsonResult: NSArray = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        var total = 0
        if jsonResult.count > 0 { total = jsonResult.count - 1 }
        
        if jsonResult.count > 0 {
            for i in 0 ... (total)
            {
                
                jsonElement = jsonResult[i] as! NSDictionary
                
                //the following insures none of the JsonElement values are nil through optional binding
                if let _ = jsonElement["tournament"] as? String,
                    let round = jsonElement["round"] as? String,
                    let course = jsonElement["course"] as? String,
                    let group = jsonElement["matchgroup"] as? String,
                    let match = jsonElement["match"] as? String,
                    let format = jsonElement["format"] as? String,
                    let scorekeeper = jsonElement["scorekeeper"] as? String
                {
                    
                    let completed = Int((jsonElement["completed"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    
                    
                    let player1 = (jsonElement["player1"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    //let player1Team = (jsonElement["player1team"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let player2 = (jsonElement["player2"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    //let player2Team = (jsonElement["player2team"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    var player3 = ""
                    var player4 = ""
                    
                    if let _ = jsonElement["player3"] as? String
                    {
                        player3 = (jsonElement["player3"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        //let player3Team = (jsonElement["player3team"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        player4 = (jsonElement["player4"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        //let player4Team = (jsonElement["player4team"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    
                    
                    let startingHole = Int((jsonElement["startinghole"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let currentHole = Int((jsonElement["currenthole"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    
                    let teamwinning = (jsonElement["winningteam"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let score = Int((jsonElement["currentscore"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let scoreString = (jsonElement["scorestring"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    
                    //let trimmedName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedRound = round.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedCourse = course.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedGroup = group.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedMatch = match.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedFormat = format.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let trimmedScorekeeper = scorekeeper.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let tees = (jsonElement["tees"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    //FINISH THE LOGIC FOR ADDING MATCHES
                    //      - NEED TO GET HOLE RESULTS
                    
                    
                    var matchPlayers = [Player]()
                    
                    for player in players {
                        if player.getName() == player1
                        {
                            matchPlayers.append(player)
                        }
                        else if player.getName() == player2
                        {
                            matchPlayers.append(player)
                        }
                        else if player.getName() == player3
                        {
                            matchPlayers.append(player)
                        }
                        else if player.getName() == player4
                        {
                            matchPlayers.append(player)
                        }
                    }
                    
                    /*
                     for player in matchPlayers {
                     for eachScore in scores {
                     if player.getName() == eachScore.playerName {
                     player.setHoleResults(round: Int(trimmedRound)!,holeNumber: eachScore.hole,score: eachScore.score)
                     }
                     }
                     }*/
                    
                    
                    var matchCompleted = false
                    if completed == 1 { matchCompleted = true }
                    else { matchCompleted = false }
                    
                    let newMatch = Match(format: trimmedFormat, players: matchPlayers, scorekeeper: trimmedScorekeeper,score: score, scoreString: scoreString,teamWinning: teamwinning, hole: currentHole,course: trimmedCourse, tees: tees, round:Int(trimmedRound)!, group: Int(trimmedGroup)!, startingHole: startingHole,matchNumber: Int(trimmedMatch)!,matchFinished: matchCompleted)
                    
                    //newMatch.refreshHoleWinners()
                    
                    matches.append(newMatch)
                    
                    //self.appendWait(newMatch, updateSelf: true) {current = current + 1 }
                    
                }
            }
        }
        
        
        return matches
    }
    
    func parseJSONholes(data: Data, courseRecords: [(course: String, tees: String, slope: Int, rating: Double, par: Double)]) -> [Course] {
        var courses = [Course]()
        
        var tableHoles = [Hole]()
        var courseNames = [String]()
        var courseHoles = [Hole]()
        
        var jsonResult: NSArray = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
            
        } catch let error as NSError {
            print(error)
            
        }
        
        
        var jsonElement: NSDictionary = NSDictionary()
        var total = 0
        if jsonResult.count > 0 { total = jsonResult.count - 1 }
        
        if jsonResult.count > 0 {
            for i in 0 ... (total)
            {
                jsonElement = jsonResult[i] as! NSDictionary
                
                //the following insures none of the JsonElement values are nil through optional binding
                if let course = jsonElement["course"] as? String
                {
                    let courseName = course.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let holeNumber = Int((jsonElement["holenumber"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let handicap = Int((jsonElement["handicap"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let par = Int((jsonElement["par"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let length = Int((jsonElement["length"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let lat = Double((jsonElement["green_cen_lat"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let long = Double((jsonElement["green_cen_long"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let tees = (jsonElement["tees"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    let coordinate = CLLocation(latitude: lat, longitude: long)
                    
                    var inList = false
                    for course in courseNames
                    {
                        if course == courseName {
                            inList = true
                        }
                    }
                    
                    if !inList {
                        courseNames.append(courseName)
                    }
                    
                    tableHoles.append(Hole(number: holeNumber, length: length, par: par, handicap: handicap, centerOfGreen: coordinate, courseName: courseName, tees: tees))
                }
            }
        }
        
        for course in courseNames {
            
            courseHoles = [Hole]()
            var tees = String()
            var slope = Int()
            var rating = Double()
            var par = Double()
            
            for hole in tableHoles {
                if hole.courseName == course {
                    courseHoles.append(hole)
                    tees = hole.tees
                }
            }
            
            for eachCourse in courseRecords {
                if eachCourse.course == course && eachCourse.tees == tees {
                    slope = eachCourse.slope
                    rating = eachCourse.rating
                    par = eachCourse.par
                }
            }
            
            courses.append(Course(name: course, holes: courseHoles, slope: slope, tees: tees, par: par,rating: rating))
        }
        
        
        return courses
    }
    
    func parseJSONcourses(data: Data) -> [(course: String, tees: String, slope: Int, rating: Double, par: Double)] {
        var courses = [(course: String, tees: String, slope: Int, rating: Double, par: Double)]()
        
        var jsonResult: NSArray = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
            
            
        } catch let error as NSError {
            print(error)
            
        }
        
        
        var jsonElement: NSDictionary = NSDictionary()
        var total = 0
        if jsonResult.count > 0 { total = jsonResult.count - 1 }
        
        if jsonResult.count > 0 {
            for i in 0 ... (total)
            {
                jsonElement = jsonResult[i] as! NSDictionary
                
                //the following insures none of the JsonElement values are nil through optional binding
                if let course = jsonElement["name"] as? String
                {
                    let courseName = course.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let slope = Int((jsonElement["slope"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let tees = (jsonElement["tees"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let rating = Double((jsonElement["rating"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    let par = Double((jsonElement["par"] as! String).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
                    
                    
                    courses.append((course: courseName, tees: tees, slope:slope, rating: rating, par:par))
                }
            }
        }
        
        return courses
    }
}

