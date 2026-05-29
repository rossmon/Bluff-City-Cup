import Foundation

/// Centralised URL builder for all backend endpoints.
/// Base: https://glizzyattheturn.app/bluffcitycup
enum APIEndpoints {

    private static let base = "https://glizzyattheturn.app/bluffcitycup"
    static let notificationServer = "http://glizzyattheturn.app:5000/send-notification"

    // MARK: - Encoding

    /// Encode a string for use in BCC query parameters.
    /// The PHP backend decodes !spa → space, !amp → &, !dot → .
    static func encode(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "!amp")
         .replacingOccurrences(of: " ", with: "!spa")
         .replacingOccurrences(of: ".", with: "!dot")
    }

    // MARK: - READ endpoints

    static func tournaments() -> URL { url("/tournament.php") }
    static func tournament(name: String) -> URL { url("/tournament.php?tournament=\(encode(name))") }
    static func matches(tournament: String) -> URL { url("/matches.php?tournament=\(encode(tournament))") }
    static func players(tournament: String) -> URL { url("/players.php?tournament=\(encode(tournament))") }
    static func player(name: String, tournament: String) -> URL {
        url("/players.php?tournament=\(encode(tournament))&player=\(encode(name))")
    }
    static func scores(tournament: String) -> URL { url("/scores.php?tournament=\(encode(tournament))") }
    static func rounds(tournament: String) -> URL { url("/rounds.php?tournament=\(encode(tournament))") }
    static func holes() -> URL { url("/holes.php") }
    static func courses() -> URL { url("/courses.php?") }
    static func scorekeeperMatches(tournament: String, scorekeeper: String) -> URL {
        url("/scorekeeper_matches.php?tournament=\(encode(tournament))&scorekeeper=\(encode(scorekeeper))")
    }
    static func playerInMatch(tournament: String, player: String) -> URL {
        url("/player_in_match.php?tournament=\(encode(tournament))&player=\(encode(player))")
    }
    static func checkCreatePassword(_ password: String) -> URL {
        url("/check_create_password.php?password=\(encode(password))")
    }
    static func matchProbabilities(tournament: String, round: Int, match: Int) -> URL {
        url("/match_probabilities/match_probabilities.php?tournament=\(encode(tournament))&round=\(round)&match=\(match)")
    }

    // MARK: - WRITE endpoints

    static func updateTournament(name: String, owner: String, numberOfMatches: Int,
                                 drinkCart: Int, drinkCartNumber: String,
                                 currentRound: Int, maxHandicap: Int,
                                 commishPassword: String) -> URL {
        let t = encode(name); let o = encode(owner); let dc = encode(drinkCartNumber); let cp = encode(commishPassword)
        return url("/update_tournament.php?tournament=\(t)&owner=\(o)&commissioner=\(o)&numberofmatches=\(numberOfMatches)&drinkcartavailable=\(drinkCart)&drinkcartnumber=\(dc)&currentround=\(currentRound)&maxhandicap=\(maxHandicap)&commishpassword=\(cp)")
    }

    static func updatePlayer(tournament: String, name: String, team: String, handicap: Double) -> URL {
        let t = encode(tournament); let n = encode(name); let h = encode(String(handicap))
        return url("/update_players.php?tournament=\(t)&name=\(n)&team=\(team)&handicap=\(h)")
    }

    static func updateScore(tournament: String, player: String, round: Int,
                            course: String, hole: Int, score: Int) -> URL {
        let t = encode(tournament); let p = encode(player); let c = encode(course)
        return url("/update_scores.php?tournament=\(t)&player=\(p)&round=\(round)&course=\(c)&hole=\(hole)&actualscore=\(score)")
    }

    static func updateMatch(tournament: String, round: Int, group: Int, match: Int,
                            course: String, slope: Int, format: String, scorekeeper: String,
                            points: Double, numPlayers: Int, startingHole: Int, currentHole: Int,
                            score: Int, scoreString: String, matchLength: Int, winningTeam: String,
                            completed: Int, tees: String,
                            p1: String, p1team: String, p2: String, p2team: String,
                            p3: String? = nil, p3team: String? = nil,
                            p4: String? = nil, p4team: String? = nil) -> URL {
        let t  = encode(tournament); let c = encode(course)
        let f  = encode(format);     let sk = encode(scorekeeper)
        let ss = encode(scoreString); let wt = encode(winningTeam); let te = encode(tees)
        var s  = "/update_matches.php?tournament=\(t)&round=\(round)&matchgroup=\(group)&match=\(match)"
        s += "&course=\(c)&slope=\(slope)&format=\(f)&scorekeeper=\(sk)&points=\(points)"
        s += "&numofplayers=\(numPlayers)&startinghole=\(startingHole)&currenthole=\(currentHole)"
        s += "&currentscore=\(score)&scorestring=\(ss)&matchlength=\(matchLength)"
        s += "&winningteam=\(wt)&completed=\(completed)&tees=\(te)"
        s += "&player1=\(encode(p1))&player1team=\(encode(p1team))"
        s += "&player2=\(encode(p2))&player2team=\(encode(p2team))"
        if let p3, let p3team, let p4, let p4team {
            s += "&player3=\(encode(p3))&player3team=\(encode(p3team))&player4=\(encode(p4))&player4team=\(encode(p4team))"
        }
        return url(s)
    }

    static func updateRound(tournament: String, round: Int, course: String) -> URL {
        let t = encode(tournament); let c = encode(course)
        return url("/update_rounds.php?tournament=\(t)&round=\(round)&course=\(c)")
    }

    static func addToken(token: String, username: String) -> URL {
        url("/add_token.php?token=\(token)&username=\(encode(username))")
    }

    // MARK: - DELETE endpoints

    static func deleteAllMatches(tournament: String) -> URL {
        url("/delete_matches.php?tournament=\(encode(tournament))")
    }
    static func deleteAllScores(tournament: String) -> URL {
        url("/delete_scores.php?tournament=\(encode(tournament))")
    }
    static func deleteMatch(tournament: String, round: Int, group: Int, match: Int) -> URL {
        url("/delete_match.php?tournament=\(encode(tournament))&round=\(round)&matchgroup=\(group)&match=\(match)")
    }
    static func deletePlayer(tournament: String, player: String, team: String) -> URL {
        url("/delete_player.php?tournament=\(encode(tournament))&player=\(encode(player))&team=\(encode(team))")
    }

    // MARK: - Private helper

    private static func url(_ path: String) -> URL {
        URL(string: base + path)!
    }
}
