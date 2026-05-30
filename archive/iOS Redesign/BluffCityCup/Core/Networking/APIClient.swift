import Foundation
import CoreLocation

// MARK: - Codable Response Types

private struct TournamentResponse: Decodable {
    let tournament: String
    let commissioner: String?
    let commishpassword: String?
    let owner: String?
    let numberofmatches: String
    let drinkcartavailable: String
    let drinkcartnumber: String?
    let currentround: String
    let maxhandicap: String
}

private struct PlayerResponse: Decodable {
    let name: String
    let team: String
    let handicap: String
    let tournament: String
}

private struct MatchResponse: Decodable {
    let tournament, round, matchgroup, match: String
    let course, format, scorekeeper: String
    let points, numofplayers, startinghole, currenthole: String
    let currentscore, scorestring, winningteam, completed: String
    let player1, player1team, player2, player2team: String
    let player3: String?; let player3team: String?
    let player4: String?; let player4team: String?
    let tees, matchlength: String
}

private struct ScoreResponse: Decodable {
    let tournament, player, round, course, hole, actualscore: String
}

private struct RoundResponse: Decodable {
    let tournament, round, course: String
}

private struct HoleResponse: Decodable {
    let course, tees, holenumber, handicap, par, length: String
    let green_cen_lat: String
    let green_cen_long: String
}

private struct CourseResponse: Decodable {
    let name, tees, slope, rating, par: String
}

private struct ProbabilityResponse: Decodable {
    let hole_number, score_difference: String
    let blue_win_probability, red_win_probability, tie_probability: String
}

struct TournamentDataBundle {
    let tournament: Tournament
    let matches: [Match]
    let players: [Player]
}

// MARK: - APIClient

actor APIClient {

    /// Shared instance — use this everywhere to avoid duplicate network state.
    static let shared = APIClient()

    // MARK: - Load all tournament data

    func fetchTournamentData(name: String) async throws -> TournamentDataBundle {
        // Fetch independent data concurrently
        async let playerData  = fetchRaw(PlayerResponse.self, url: APIEndpoints.players(tournament: name))
        async let courseData  = fetchRaw(CourseResponse.self, url: APIEndpoints.courses())
        async let roundData   = fetchRaw(RoundResponse.self, url: APIEndpoints.rounds(tournament: name))
        async let scoreData   = fetchRaw(ScoreResponse.self, url: APIEndpoints.scores(tournament: name))
        async let holeData    = fetchRaw(HoleResponse.self, url: APIEndpoints.holes())
        async let tourneyData = fetchRaw(TournamentResponse.self, url: APIEndpoints.tournament(name: name))
        async let matchData   = fetchRaw(MatchResponse.self, url: APIEndpoints.matches(tournament: name))

        let (pr, cr, rr, sr, hr, tr, mr) = try await (playerData, courseData, roundData, scoreData,
                                                        holeData, tourneyData, matchData)

        let players  = buildPlayers(pr)
        let courses  = buildCourses(cr, holes: hr)
        let scores   = buildScoreMap(sr)
        applyScores(scores, to: players)
        let matches  = buildMatches(mr, players: players)
        let tournament = buildTournament(tr.first, name: name, players: players,
                                         matches: matches, rounds: rr, courses: courses)
        return TournamentDataBundle(tournament: tournament, matches: matches, players: players)
    }

    // MARK: - Auth checks

    func getTournamentNames() async throws -> [(name: String, commish: String)] {
        let items = try await fetchRaw(TournamentResponse.self, url: APIEndpoints.tournaments())
        return items.map { (trim($0.tournament), trim($0.commissioner ?? "")) }
    }

    func checkTournament(_ name: String) async throws -> (found: Bool, commissionerName: String, commishPassword: String) {
        let items = try await fetchRaw(TournamentResponse.self, url: APIEndpoints.tournament(name: name))
        guard let first = items.first else { return (false, "", "") }
        return (true, trim(first.commissioner ?? ""), trim(first.commishpassword ?? ""))
    }

    func checkUser(name: String, tournament: String) async throws -> (found: Bool, player: Player?, inCurrentMatch: Bool) {
        let items = try await fetchRaw(PlayerResponse.self, url: APIEndpoints.player(name: name, tournament: tournament))
        guard let pr = items.first else { return (false, nil, false) }
        let player = Player(name: trim(pr.name),
                            handicapIndex: Double(trim(pr.handicap)) ?? 0,
                            team: Team(rawValue: trim(pr.team)) ?? .blue)
        let inMatch = try await checkPlayerInMatch(name: name, tournament: tournament)
        return (true, player, inMatch)
    }

    func checkPlayerInMatch(name: String, tournament: String) async throws -> Bool {
        let items = try await fetchRaw(MatchResponse.self, url: APIEndpoints.playerInMatch(tournament: tournament, player: name))
        return !items.isEmpty
    }

    func checkScorekeeper(name: String, tournament: String) async throws -> Bool {
        let items = try await fetchRaw(MatchResponse.self, url: APIEndpoints.scorekeeperMatches(tournament: tournament, scorekeeper: name))
        // A scorekeeper has an active match if they appear as scorekeeper on an incomplete match
        return items.contains { $0.scorekeeper.trimmingCharacters(in: .whitespaces) == name
                                && Int($0.completed) == 0 }
    }

    func checkCreatePassword(_ password: String) async throws -> Bool {
        // Returns non-empty array if password is valid
        let data = try await rawData(url: APIEndpoints.checkCreatePassword(password))
        let json = try JSONSerialization.jsonObject(with: data)
        if let arr = json as? [[String: Any]] { return !arr.isEmpty }
        return false
    }

    // MARK: - Write endpoints

    func updateTournament(_ tournament: Tournament) async throws {
        let s = tournament.settings
        let url = APIEndpoints.updateTournament(
            name: s.name, owner: s.owner, numberOfMatches: s.numberOfRounds,
            drinkCart: s.drinkCartEnabled ? 1 : 0, drinkCartNumber: s.drinkCartNumber,
            currentRound: s.currentRound, maxHandicap: s.maxHandicap,
            commishPassword: s.commissionerPassword)
        _ = try await rawData(url: url)
    }

    func updatePlayer(_ player: Player, tournament: String) async throws {
        _ = try await rawData(url: APIEndpoints.updatePlayer(
            tournament: tournament, name: player.name,
            team: player.team.rawValue, handicap: player.handicapIndex))
    }

    func updateHoleScore(player: Player, round: Int, course: String, hole: Int, score: Int, tournament: String) async throws {
        _ = try await rawData(url: APIEndpoints.updateScore(
            tournament: tournament, player: player.name, round: round,
            course: course, hole: hole, score: score))
    }

    func updateMatch(_ match: Match, tournament: Tournament) async throws {
        let score = tournament.matchScore(match)
        let completed = match.isCompleted ? 1 : 0
        let winTeam = score.teamLeading?.rawValue ?? "AS"
        let slope = tournament.course(named: match.courseName)?.slope ?? 113

        var url: URL
        if match.format.totalPlayers == 4,
           let bp1 = match.bluePlayerOne, let bp2 = match.bluePlayerTwo,
           let rp1 = match.redPlayerOne,  let rp2 = match.redPlayerTwo {
            url = APIEndpoints.updateMatch(
                tournament: match.tournament, round: match.round, group: match.group, match: match.matchNumber,
                course: match.courseName, slope: slope, format: match.format.rawValue,
                scorekeeper: match.scorekeeperName, points: match.points, numPlayers: 4,
                startingHole: match.startingHole, currentHole: match.currentHole,
                score: score.score, scoreString: score.scoreString, matchLength: match.matchLength,
                winningTeam: winTeam, completed: completed, tees: match.tees,
                p1: bp1.name, p1team: bp1.team.rawValue, p2: rp1.name, p2team: rp1.team.rawValue,
                p3: bp2.name, p3team: bp2.team.rawValue, p4: rp2.name, p4team: rp2.team.rawValue)
        } else if let bp1 = match.bluePlayerOne, let rp1 = match.redPlayerOne {
            url = APIEndpoints.updateMatch(
                tournament: match.tournament, round: match.round, group: match.group, match: match.matchNumber,
                course: match.courseName, slope: slope, format: match.format.rawValue,
                scorekeeper: match.scorekeeperName, points: match.points, numPlayers: 2,
                startingHole: match.startingHole, currentHole: match.currentHole,
                score: score.score, scoreString: score.scoreString, matchLength: match.matchLength,
                winningTeam: winTeam, completed: completed, tees: match.tees,
                p1: bp1.name, p1team: bp1.team.rawValue, p2: rp1.name, p2team: rp1.team.rawValue)
        } else { return }

        _ = try await rawData(url: url)
    }

    func deletePlayer(name: String, team: String, tournament: String) async throws {
        _ = try await rawData(url: APIEndpoints.deletePlayer(tournament: tournament, player: name, team: team))
    }

    func deleteMatch(_ match: Match) async throws {
        _ = try await rawData(url: APIEndpoints.deleteMatch(
            tournament: match.tournament, round: match.round,
            group: match.group, match: match.matchNumber))
    }

    func deleteAllMatches(tournament: String) async throws {
        async let s = rawData(url: APIEndpoints.deleteAllScores(tournament: tournament))
        async let m = rawData(url: APIEndpoints.deleteAllMatches(tournament: tournament))
        _ = try await (s, m)
    }

    func addToken(_ token: String, username: String) async throws {
        _ = try await rawData(url: APIEndpoints.addToken(token: token, username: username))
    }

    func updateRound(tournament: String, round: Int, course: String) async throws {
        _ = try await rawData(url: APIEndpoints.updateRound(tournament: tournament, round: round, course: course))
    }

    // MARK: - Notifications

    func sendMatchNotification(winningTeam: String, winnerNames: String, loserNames: String,
                               scoreString: String, round: Int, matchNum: Int) async throws {
        guard let url = URL(string: APIEndpoints.notificationServer) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let title = "Round: \(round), Match: \(matchNum)"
        let message: String
        if winningTeam == "AS" {
            message = "\(winnerNames) tied \(loserNames)."
        } else {
            message = "\(winnerNames) def. \(loserNames) \(scoreString)."
        }
        let payload: [String: Any] = ["title": title, "message": message]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        _ = try await URLSession.shared.data(for: request)
    }

    // MARK: - Private: Network helpers

    private func fetchRaw<T: Decodable>(_ type: T.Type, url: URL) async throws -> [T] {
        let data = try await rawData(url: url)
        // The server returns an empty body or empty JSON array on no results
        if data.isEmpty { return [] }
        // Trim any leading/trailing whitespace
        let trimmed = data.trimmingWhitespace()
        if trimmed.isEmpty { return [] }
        if let trimmedStr = String(data: trimmed, encoding: .utf8),
           trimmedStr == "null" || trimmedStr == "[]" { return [] }
        do {
            return try JSONDecoder().decode([T].self, from: trimmed)
        } catch {
            // Some endpoints return a single object rather than array — wrap it
            if let single = try? JSONDecoder().decode(T.self, from: trimmed) { return [single] }
            return []
        }
    }

    private func rawData(url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    // MARK: - Private: Builders

    private func trim(_ s: String) -> String { s.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func buildPlayers(_ responses: [PlayerResponse]) -> [Player] {
        responses.compactMap { r -> Player? in
            let name = trim(r.name)
            guard !name.isEmpty, let hdcp = Double(trim(r.handicap)) else { return nil }
            let team = Team(rawValue: trim(r.team)) ?? .blue
            return Player(name: name, handicapIndex: hdcp, team: team)
        }
    }

    private func buildCourses(_ courseResponses: [CourseResponse], holes: [HoleResponse]) -> [Course] {
        var result: [Course] = []
        for cr in courseResponses {
            let name  = trim(cr.name)
            let tees  = trim(cr.tees)
            let slope = Int(trim(cr.slope)) ?? 113
            let rating = Double(trim(cr.rating)) ?? 72.0
            let par   = Double(trim(cr.par)) ?? 72.0

            let courseHoles: [Hole] = holes.compactMap { hr -> Hole? in
                guard trim(hr.course) == name, trim(hr.tees) == tees else { return nil }
                guard let num = Int(trim(hr.holenumber)),
                      let hdcp = Int(trim(hr.handicap)),
                      let p = Int(trim(hr.par)),
                      let len = Int(trim(hr.length)),
                      let lat = Double(trim(hr.green_cen_lat)),
                      let lng = Double(trim(hr.green_cen_long)) else { return nil }
                return Hole(number: num, par: p, handicapIndex: hdcp, length: len,
                            greenCenter: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                            courseName: name, tees: tees)
            }.sorted { $0.number < $1.number }

            result.append(Course(name: name, tees: tees, slope: slope, rating: rating, par: par, holes: courseHoles))
        }
        return result
    }

    private typealias ScoreKey = String  // "playerName|round|hole"
    private func buildScoreMap(_ responses: [ScoreResponse]) -> [String: [String: [Int: Int]]] {
        // [playerName: [tournamentRound: [hole: score]]]
        var map: [String: [String: [Int: Int]]] = [:]
        for sr in responses {
            let player = trim(sr.player)
            let round  = trim(sr.round)
            guard let hole = Int(trim(sr.hole)),
                  let score = Int(trim(sr.actualscore)) else { continue }
            if map[player] == nil { map[player] = [:] }
            if map[player]![round] == nil { map[player]![round] = [:] }
            map[player]![round]![hole] = score
        }
        return map
    }

    private func applyScores(_ scores: [String: [String: [Int: Int]]], to players: [Player]) {
        for player in players {
            guard let roundMap = scores[player.name] else { continue }
            for (roundStr, holeMap) in roundMap {
                guard let round = Int(roundStr) else { continue }
                for (hole, score) in holeMap {
                    player.setScore(score, hole: hole, round: round)
                }
            }
        }
    }

    private func buildMatches(_ responses: [MatchResponse], players: [Player]) -> [Match] {
        responses.compactMap { r -> Match? in
            guard let round = Int(trim(r.round)),
                  let group = Int(trim(r.matchgroup)),
                  let matchNum = Int(trim(r.match)),
                  let numPlayers = Int(trim(r.numofplayers)),
                  let startHole = Int(trim(r.startinghole)),
                  let curHole  = Int(trim(r.currenthole)),
                  let score    = Int(trim(r.currentscore)),
                  let completed = Int(trim(r.completed)),
                  let matchLen = Int(trim(r.matchlength)) else { return nil }

            let format = MatchFormat(rawValue: trim(r.format)) ?? .singles

            // Resolve players: p1+p3 = Blue, p2+p4 = Red
            var matchPlayers: [Player] = []
            let names = [trim(r.player1), trim(r.player2),
                         r.player3.map(trim) ?? "", r.player4.map(trim) ?? ""]
            let teams: [Team] = [.blue, .red, .blue, .red]
            for (i, name) in names.enumerated() where !name.isEmpty {
                if let p = players.first(where: { $0.name == name }) {
                    matchPlayers.append(p)
                } else {
                    // Create placeholder player if not found in roster
                    matchPlayers.append(Player(name: name, handicapIndex: 0, team: teams[i]))
                }
            }

            return Match(tournament: trim(r.tournament),
                         round: round, group: group, matchNumber: matchNum,
                         format: format, players: matchPlayers,
                         scorekeeperName: trim(r.scorekeeper),
                         courseName: trim(r.course), tees: trim(r.tees),
                         startingHole: startHole, matchLength: matchLen,
                         points: Double(trim(r.points)) ?? 1.0,
                         currentHole: curHole, isCompleted: completed == 1,
                         cachedScoreString: trim(r.scorestring),
                         cachedTeamLeading: trim(r.winningteam),
                         cachedScore: score)
        }
    }

    private func buildTournament(_ response: TournamentResponse?,
                                  name: String, players: [Player], matches: [Match],
                                  rounds: [RoundResponse], courses: [Course]) -> Tournament {
        let r = response
        let settings = TournamentSettings(
            name: name,
            owner: r.flatMap { trim($0.owner ?? "") } ?? "",
            commissioner: r.flatMap { trim($0.commissioner ?? "") } ?? "",
            commissionerPassword: r.flatMap { trim($0.commishpassword ?? "") } ?? "",
            numberOfRounds: Int(r.map { trim($0.numberofmatches) } ?? "1") ?? 1,
            currentRound: Int(r.map { trim($0.currentround) } ?? "1") ?? 1,
            maxHandicap: Int(r.map { trim($0.maxhandicap) } ?? "36") ?? 36,
            drinkCartEnabled: Int(r.map { trim($0.drinkcartavailable) } ?? "0") == 1,
            drinkCartNumber: r.flatMap { trim($0.drinkcartnumber ?? "") } ?? ""
        )
        let tournament = Tournament(settings: settings)
        tournament.players = players
        tournament.matches = matches
        tournament.courses = courses
        tournament.roundCourses = Dictionary(
            uniqueKeysWithValues: rounds.compactMap { rr -> (Int, String)? in
                guard let round = Int(trim(rr.round)) else { return nil }
                return (round, trim(rr.course))
            }
        )
        return tournament
    }
}

// MARK: - Data helper

private extension Data {
    func trimmingWhitespace() -> Data {
        guard let str = String(data: self, encoding: .utf8) else { return self }
        return Data(str.trimmingCharacters(in: .whitespacesAndNewlines).utf8)
    }
}
