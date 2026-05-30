import Foundation

// MARK: - Tournament Settings

struct TournamentSettings {
    var name: String
    var owner: String
    var commissioner: String
    var commissionerPassword: String
    var numberOfRounds: Int
    var currentRound: Int
    var maxHandicap: Int
    var drinkCartEnabled: Bool
    var drinkCartNumber: String
}

// MARK: - Tournament

final class Tournament: ObservableObject {

    @Published var settings: TournamentSettings
    @Published var matches: [Match] = []
    @Published var players: [Player] = []
    @Published var courses: [Course] = []
    /// round number → course name
    @Published var roundCourses: [Int: String] = [:]

    var maxHandicap: Int { settings.maxHandicap }

    init(settings: TournamentSettings) {
        self.settings = settings
    }

    // MARK: - Convenience accessors

    var name: String { settings.name }

    func course(named name: String) -> Course? {
        courses.first { $0.name == name }
    }

    func course(forRound round: Int) -> Course? {
        guard let name = roundCourses[round] else { return nil }
        return course(named: name)
    }

    func player(named name: String) -> Player? {
        players.first { $0.name == name }
    }

    // MARK: - Match Queries

    func matchesSortedForTable() -> [Match] {
        // Underway first, then not started, then finished
        let underway  = matches.filter { !$0.isCompleted && $0.currentHole > $0.startingHole }
        let notStarted = matches.filter { !$0.isCompleted && $0.currentHole <= $0.startingHole }
        let finished  = matches.filter { $0.isCompleted }
        return underway.sorted(by: sortKey) + notStarted.sorted(by: sortKey) + finished.sorted(by: sortKey)
    }

    private func sortKey(_ a: Match, _ b: Match) -> Bool {
        if a.round != b.round { return a.round < b.round }
        return a.matchNumber < b.matchNumber
    }

    func matches(forRound round: Int) -> [Match] {
        matches.filter { $0.round == round }
    }

    func currentMatch(forPlayer player: Player) -> Match? {
        matches.first {
            !$0.isCompleted && $0.players.contains(player)
        }
    }

    func playerAlreadyInMatch(playerName: String, round: Int) -> Bool {
        matches.filter { $0.round == round }.contains {
            $0.players.map(\.name).contains(playerName)
        }
    }

    // MARK: - Live Scores

    /// Returns (blue, red) total points including in-progress matches.
    func liveScores() -> (blue: Double, red: Double) {
        let (blueCompleted, redCompleted) = completedScores()
        var blueLive = blueCompleted
        var redLive  = redCompleted
        for match in matches where !match.isCompleted {
            let score = matchScore(match)
            if score.teamLeading == .blue {
                blueLive += match.points
            } else if score.teamLeading == .red {
                redLive += match.points
            } else {
                blueLive += match.points / 2.0
                redLive += match.points / 2.0
            }
        }
        return (blueLive, redLive)
    }

    func completedScores() -> (blue: Double, red: Double) {
        var blue = 0.0; var red = 0.0
        for match in matches where match.isCompleted {
            let score = matchScore(match)
            if score.teamLeading == .blue { blue += match.points }
            else if score.teamLeading == .red { red += match.points }
            else {
                blue += match.points / 2
                red  += match.points / 2
            }
        }
        return (blue, red)
    }

    // MARK: - Hole Winner Logic

    /// Determine the winner of a specific hole for a given match.
    /// Returns "Blue", "Red", or "AS" (all square / halved).
    func holeWinner(match: Match, hole: Int, course: Course) -> String {
        let holeData = course.hole(hole)
        let holeHdcp = holeData.handicapIndex
        let slope    = course.slope
        let rating   = course.rating
        let par      = course.par
        let maxHdcp  = maxHandicap

        switch match.format {
        case .singles:
            return singlesHoleWinner(match: match, hole: hole, holeHdcp: holeHdcp,
                                     slope: slope, rating: rating, par: par, maxHdcp: maxHdcp)
        case .alternateShot:
            return alternateShotHoleWinner(match: match, hole: hole, holeHdcp: holeHdcp,
                                           slope: slope, rating: rating, par: par, maxHdcp: maxHdcp)
        case .bestBall:
            return bestBallHoleWinner(match: match, hole: hole, holeHdcp: holeHdcp,
                                      slope: slope, rating: rating, par: par, maxHdcp: maxHdcp, shamble: false)
        case .shamble:
            return bestBallHoleWinner(match: match, hole: hole, holeHdcp: holeHdcp,
                                      slope: slope, rating: rating, par: par, maxHdcp: maxHdcp, shamble: true)
        case .twoManScramble:
            return scrambleHoleWinner(match: match, hole: hole, holeHdcp: holeHdcp,
                                      slope: slope, rating: rating, par: par, maxHdcp: maxHdcp, fourMan: false)
        case .fourManScramble:
            return scrambleHoleWinner(match: match, hole: hole, holeHdcp: holeHdcp,
                                      slope: slope, rating: rating, par: par, maxHdcp: maxHdcp, fourMan: true)
        }
    }

    // MARK: - Singles

    private func singlesHoleWinner(match: Match, hole: Int, holeHdcp: Int,
                                   slope: Int, rating: Double, par: Double, maxHdcp: Int) -> String {
        guard let bp1 = match.bluePlayerOne, let rp1 = match.redPlayerOne else { return "AS" }
        let bGross = bp1.score(hole: hole, round: match.round)
        let rGross = rp1.score(hole: hole, round: match.round)
        guard bGross > 0 || rGross > 0 else { return "AS" }

        let bHdcp = bp1.courseHandicap(slope: slope, rating: rating, par: par, maxHandicap: maxHdcp)
        let rHdcp = rp1.courseHandicap(slope: slope, rating: rating, par: par, maxHandicap: maxHdcp)

        // Subtract lower handicap from both so one becomes 0
        let diff   = abs(bHdcp - rHdcp)
        let bAdj   = bHdcp > rHdcp ? diff : 0
        let rAdj   = rHdcp > bHdcp ? diff : 0

        let bNet = bGross > 0 ? Match.netScore(gross: bGross, playerHandicap: bAdj, holeHandicapIndex: holeHdcp) : Int.max
        let rNet = rGross > 0 ? Match.netScore(gross: rGross, playerHandicap: rAdj, holeHandicapIndex: holeHdcp) : Int.max

        if bNet < rNet { return "Blue" }
        if rNet < bNet { return "Red" }
        return "AS"
    }

    // MARK: - Alternate Shot

    private func alternateShotHoleWinner(match: Match, hole: Int, holeHdcp: Int,
                                         slope: Int, rating: Double, par: Double, maxHdcp: Int) -> String {
        guard let bp1 = match.bluePlayerOne, let rp1 = match.redPlayerOne else { return "AS" }
        let bGross = bp1.score(hole: hole, round: match.round)
        let rGross = rp1.score(hole: hole, round: match.round)
        guard bGross > 0 || rGross > 0 else { return "AS" }

        let bTeamHdcp = teamHandicap(format: .alternateShot, players: match.bluePlayers,
                                     slope: slope, rating: rating, par: par, maxHdcp: maxHdcp)
        let rTeamHdcp = teamHandicap(format: .alternateShot, players: match.redPlayers,
                                     slope: slope, rating: rating, par: par, maxHdcp: maxHdcp)

        let diff = abs(bTeamHdcp - rTeamHdcp)
        let bAdj = bTeamHdcp > rTeamHdcp ? diff : 0
        let rAdj = rTeamHdcp > bTeamHdcp ? diff : 0

        let bNet = bGross > 0 ? Match.netScore(gross: bGross, playerHandicap: bAdj, holeHandicapIndex: holeHdcp) : Int.max
        let rNet = rGross > 0 ? Match.netScore(gross: rGross, playerHandicap: rAdj, holeHandicapIndex: holeHdcp) : Int.max

        if bNet < rNet { return "Blue" }
        if rNet < bNet { return "Red" }
        return "AS"
    }

    // MARK: - Best Ball / Shamble

    private func bestBallHoleWinner(match: Match, hole: Int, holeHdcp: Int,
                                    slope: Int, rating: Double, par: Double,
                                    maxHdcp: Int, shamble: Bool) -> String {
        let lowestHdcp = lowestPlayerHandicap(match: match, slope: slope, rating: rating,
                                              par: par, maxHdcp: maxHdcp, shamble: shamble)

        func teamBestNet(players: [Player]) -> Int {
            var best = Int.max
            for p in players {
                let gross = p.score(hole: hole, round: match.round)
                guard gross > 0 else { continue }
                let hdcp = shamble
                    ? p.shambleHandicap(slope: slope, rating: rating, par: par, maxHandicap: maxHdcp)
                    : p.courseHandicap(slope: slope, rating: rating, par: par, maxHandicap: maxHdcp)
                let adjusted = max(0, hdcp - lowestHdcp)
                let net = Match.netScore(gross: gross, playerHandicap: adjusted, holeHandicapIndex: holeHdcp)
                best = min(best, net)
            }
            return best
        }

        let bNet = teamBestNet(players: match.bluePlayers)
        let rNet = teamBestNet(players: match.redPlayers)

        guard bNet < Int.max || rNet < Int.max else { return "AS" }
        if bNet < rNet { return "Blue" }
        if rNet < bNet { return "Red" }
        return "AS"
    }

    // MARK: - Two Man / Four Man Scramble

    private func scrambleHoleWinner(match: Match, hole: Int, holeHdcp: Int,
                                    slope: Int, rating: Double, par: Double,
                                    maxHdcp: Int, fourMan: Bool) -> String {
        // Team score is the first player's score (scramble format)
        let bGross = match.bluePlayerOne?.score(hole: hole, round: match.round) ?? 0
        let rGross = match.redPlayerOne?.score(hole: hole, round: match.round) ?? 0
        guard bGross > 0 || rGross > 0 else { return "AS" }

        let bTeamHdcp: Int
        let rTeamHdcp: Int
        if fourMan {
            bTeamHdcp = fourManScrambleHandicap(players: match.bluePlayers, slope: slope, maxHdcp: maxHdcp)
            rTeamHdcp = fourManScrambleHandicap(players: match.redPlayers,  slope: slope, maxHdcp: maxHdcp)
        } else {
            bTeamHdcp = teamHandicap(format: .twoManScramble, players: match.bluePlayers,
                                     slope: slope, rating: rating, par: par, maxHdcp: maxHdcp)
            rTeamHdcp = teamHandicap(format: .twoManScramble, players: match.redPlayers,
                                     slope: slope, rating: rating, par: par, maxHdcp: maxHdcp)
        }

        let diff = abs(bTeamHdcp - rTeamHdcp)
        let bAdj = bTeamHdcp > rTeamHdcp ? diff : 0
        let rAdj = rTeamHdcp > bTeamHdcp ? diff : 0

        let bNet = bGross > 0 ? Match.netScore(gross: bGross, playerHandicap: bAdj, holeHandicapIndex: holeHdcp) : Int.max
        let rNet = rGross > 0 ? Match.netScore(gross: rGross, playerHandicap: rAdj, holeHandicapIndex: holeHdcp) : Int.max

        if bNet < rNet { return "Blue" }
        if rNet < bNet { return "Red" }
        return "AS"
    }

    // MARK: - Team Handicap Calculations

    /// Weighted team handicap for 2-player formats.
    func teamHandicap(format: MatchFormat, players: [Player],
                      slope: Int, rating: Double, par: Double, maxHdcp: Int) -> Int {
        let sorted = players.sorted { $0.handicapIndex < $1.handicapIndex }
        var p1Hdcp = 0
        if let p1 = sorted.first {
            let raw = p1.handicapIndex * (Double(slope) / 113.0) + (rating - par)
            p1Hdcp = min(Int(raw.rounded()), maxHdcp)
        }
        var p2Hdcp = 0
        if sorted.count > 1 {
            let raw = sorted[1].handicapIndex * (Double(slope) / 113.0) + (rating - par)
            p2Hdcp = min(Int(raw.rounded()), maxHdcp)
        }

        switch format {
        case .alternateShot:
            return Int((0.5 * Double(p1Hdcp) + 0.5 * Double(p2Hdcp)).rounded())
        case .twoManScramble:
            return Int((0.35 * Double(p1Hdcp) + 0.15 * Double(p2Hdcp)).rounded())
        case .fourManScramble:
            return fourManScrambleHandicap(players: players, slope: slope, maxHdcp: maxHdcp)
        default:
            return p1Hdcp
        }
    }

    /// Four-man scramble team handicap: 20% + 15% + 10% + 5% weighting.
    func fourManScrambleHandicap(players: [Player], slope: Int, maxHdcp: Int) -> Int {
        let sorted = players.sorted { $0.handicapIndex < $1.handicapIndex }
        let weights = [0.20, 0.15, 0.10, 0.05]
        var total = 0.0
        for (i, weight) in weights.enumerated() {
            guard i < sorted.count else { break }
            let p = sorted[i]
            let hdcp = min(Int((p.handicapIndex * (Double(slope) / 113.0)).rounded()), maxHdcp)
            total += weight * Double(hdcp)
        }
        return Int(total.rounded())
    }

    /// Returns the lowest course-handicap among all players in a match (used for Best Ball / Shamble levelling).
    func lowestPlayerHandicap(match: Match, slope: Int, rating: Double, par: Double,
                              maxHdcp: Int, shamble: Bool) -> Int {
        match.players.map { p -> Int in
            shamble
                ? p.shambleHandicap(slope: slope, rating: rating, par: par, maxHandicap: maxHdcp)
                : p.courseHandicap(slope: slope, rating: rating, par: par, maxHandicap: maxHdcp)
        }.min() ?? 0
    }

    // MARK: - Match Scoring

    /// Computes the current match score from the holeWinners dictionary.
    func matchScore(_ match: Match) -> MatchScore {
        if match.isCompleted, let cached = cachedMatchScore(match) {
            return cached
        }

        var blueHoles = 0
        var redHoles  = 0
        let holes = match.holeRange

        for hole in holes {
            switch match.holeWinners[hole] {
            case "Blue": blueHoles += 1
            case "Red":  redHoles  += 1
            default: break
            }
        }

        let score   = blueHoles - redHoles
        let played  = holes.filter { match.holeWinners[$0] != nil }.count
        let remaining = match.matchLength - played

        if played == 0, !match.cachedScoreString.isEmpty, match.cachedScoreString != "AS" {
            let leader = Team(rawValue: match.cachedTeamLeading)
            return MatchScore(scoreString: match.cachedScoreString, secondaryString: "",
                              score: match.cachedScore, teamLeading: leader,
                              isFinished: match.isCompleted)
        }

        if played == match.matchLength {
            if score == 0 {
                return MatchScore(scoreString: "Halved", secondaryString: "", score: 0,
                                  teamLeading: nil, isFinished: true)
            }
            let leader: Team = score > 0 ? .blue : .red
            return MatchScore(scoreString: "\(abs(score))", secondaryString: "UP",
                              score: score, teamLeading: leader, isFinished: true)
        }

        // Check early completion (e.g. 4&3 — winning margin > holes remaining).
        let absScore = abs(score)
        if absScore > remaining {
            let leader: Team = score > 0 ? .blue : .red
            return MatchScore(scoreString: "\(absScore)", secondaryString: "& \(remaining)",
                              score: score, teamLeading: leader, isFinished: true)
        }

        if score == 0 {
            return MatchScore(scoreString: "AS", secondaryString: "", score: 0,
                              teamLeading: nil, isFinished: false)
        }

        let leader: Team = score > 0 ? .blue : .red
        return MatchScore(scoreString: "\(abs(score))", secondaryString: "UP",
                          score: score, teamLeading: leader, isFinished: false)
    }

    /// Per-hole win-probability trajectory for the line chart.
    /// Returns one entry per completed hole — the probability *entering* that hole.
    func matchWinProbabilityHistory(match: Match) -> [(hole: Int, blue: Double, red: Double, tie: Double)] {
        let details = matchCompletionDetails(match)
        let diffs = details.scoreDiffs.isEmpty ? [0] : details.scoreDiffs
        var results: [(hole: Int, blue: Double, red: Double, tie: Double)] = []

        for (index, diff) in diffs.enumerated() {
            let hole = match.startingHole + index
            if let p = probability(match: match, hole: index + 1, scoreDiff: diff) {
                results.append((hole, p.blueWin, p.redWin, p.tie))
            }
        }

        if match.isCompleted || details.matchFinished {
            let finishHole = completedProbabilityFinishHole(match, details: details)
            let winner = cachedMatchScore(match)?.teamLeading.map { $0.rawValue } ?? details.matchWinner
            let finalPoint: (hole: Int, blue: Double, red: Double, tie: Double)
            switch winner {
            case "Blue": finalPoint = (finishHole, 1.0, 0.0, 0.0)
            case "Red": finalPoint = (finishHole, 0.0, 1.0, 0.0)
            default: finalPoint = (finishHole, 0.0, 0.0, 1.0)
            }
            if results.last?.hole == finishHole {
                results[results.count - 1] = finalPoint
            } else {
                results.append(finalPoint)
            }
        }

        return results
    }

    private func cachedMatchScore(_ match: Match) -> MatchScore? {
        let raw = match.cachedScoreString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }

        let leader = Team(rawValue: match.cachedTeamLeading)
        let score = match.cachedScore

        if raw.caseInsensitiveCompare("AS") == .orderedSame {
            return MatchScore(scoreString: "AS", secondaryString: "", score: score,
                              teamLeading: nil, isFinished: match.isCompleted)
        }

        if raw.caseInsensitiveCompare("Halved") == .orderedSame {
            return MatchScore(scoreString: "Halved", secondaryString: "", score: 0,
                              teamLeading: nil, isFinished: true)
        }

        if raw.localizedCaseInsensitiveContains("UP") {
            let primary = raw.replacingOccurrences(of: "UP", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return MatchScore(scoreString: primary.isEmpty ? raw : primary,
                              secondaryString: "UP",
                              score: score,
                              teamLeading: leader,
                              isFinished: match.isCompleted)
        }

        if let amp = raw.firstIndex(of: "&") {
            let primary = raw[..<amp].trimmingCharacters(in: .whitespacesAndNewlines)
            let secondary = raw[amp...].trimmingCharacters(in: .whitespacesAndNewlines)
            return MatchScore(scoreString: String(primary),
                              secondaryString: String(secondary),
                              score: score,
                              teamLeading: leader,
                              isFinished: match.isCompleted)
        }

        return MatchScore(scoreString: raw, secondaryString: "", score: score,
                          teamLeading: leader, isFinished: match.isCompleted)
    }

    private func completedProbabilityFinishHole(
        _ match: Match,
        details: (matchFinished: Bool, matchWinner: String, blueScore: Int, redScore: Int, lastHoleCompleted: Int, scoreDiffs: [Int])
    ) -> Int {
        if match.isCompleted {
            let raw = match.cachedScoreString.trimmingCharacters(in: .whitespacesAndNewlines)
            if let remaining = remainingHoles(fromScoreString: raw) {
                return match.startingHole + max(0, match.matchLength - remaining)
            }
            return match.startingHole + match.matchLength
        }

        return match.startingHole + details.lastHoleCompleted
    }

    private func remainingHoles(fromScoreString raw: String) -> Int? {
        guard let amp = raw.firstIndex(of: "&") else { return nil }
        let tail = raw[raw.index(after: amp)...]
        let digits = tail.filter { $0.isNumber }
        return Int(String(digits))
    }

    /// Update all holeWinners for a match through the last entered hole.
    func refreshHoleWinners(match: Match) {
        guard let courseData = course(named: match.courseName) else { return }
        for hole in match.holeRange {
            let winner = holeWinner(match: match, hole: hole, course: courseData)
            if winner != "AS" {
                match.holeWinners[hole] = winner == "AS" ? "Halved" : winner
            } else {
                // Only set Halved if both players have scores entered for that hole
                let hasScores = match.players.allSatisfy { $0.score(hole: hole, round: match.round) > 0 }
                if hasScores { match.holeWinners[hole] = "Halved" }
            }
        }
    }

    // MARK: - Win Probability

    func probability(match: Match, hole: Int, scoreDiff: Int) -> (blueWin: Double, redWin: Double, tie: Double)? {
        let format = match.format.rawValue
        return Tournament.matchProbabilities[format]?[match.matchLength]?[hole]?[scoreDiff]
    }

    /// High-level probability for a match at its current state.
    /// Returns fractions (0–1) for blue win, red win, and tie.
    func matchProbability(match: Match, course: Course?) -> (blue: Double, red: Double, tie: Double) {
        let details = matchCompletionDetails(match)
        if details.matchFinished {
            switch details.matchWinner {
            case "Blue": return (1.0, 0.0, 0.0)
            case "Red": return (0.0, 1.0, 0.0)
            default: return (0.0, 0.0, 1.0)
            }
        }
        let holeIndex = max(1, details.scoreDiffs.count)
        let scoreDiff = details.scoreDiffs.last ?? 0

        if let p = probability(match: match, hole: holeIndex, scoreDiff: scoreDiff) {
            return (p.blueWin, p.redWin, p.tie)
        }
        // Fallback: even odds
        return (0.333, 0.333, 0.334)
    }

    func matchCompletionDetails(_ match: Match) -> (matchFinished: Bool, matchWinner: String, blueScore: Int, redScore: Int, lastHoleCompleted: Int, scoreDiffs: [Int]) {
        var blueScore = 0
        var redScore = 0
        var scoreDiffs: [Int] = []
        var lastHoleCompleted = 0

        if match.currentHole == match.startingHole && match.holeWinners.isEmpty {
            return (false, "Tie", 0, 0, 0, [])
        }

        for (index, hole) in match.holeRange.enumerated() {
            scoreDiffs.append(blueScore - redScore)

            guard let winner = match.holeWinners[hole] else {
                return (false, matchWinner(blueScore: blueScore, redScore: redScore),
                        blueScore, redScore, lastHoleCompleted, scoreDiffs)
            }

            if winner == "Blue" { blueScore += 1 }
            else if winner == "Red" { redScore += 1 }

            lastHoleCompleted = index + 1
            let remaining = match.matchLength - (index + 1)
            if abs(blueScore - redScore) > remaining || index + 1 == match.matchLength {
                scoreDiffs.append(blueScore - redScore)
                return (true, matchWinner(blueScore: blueScore, redScore: redScore),
                        blueScore, redScore, lastHoleCompleted, scoreDiffs)
            }
        }

        return (false, matchWinner(blueScore: blueScore, redScore: redScore),
                blueScore, redScore, lastHoleCompleted, scoreDiffs)
    }

    private func matchWinner(blueScore: Int, redScore: Int) -> String {
        if blueScore > redScore { return "Blue" }
        if redScore > blueScore { return "Red" }
        return "Tie"
    }

    // MARK: - Player Roster Helpers

    var blueTeamPlayers: [Player] {
        players.filter { $0.team == .blue }.sorted { $0.handicapIndex < $1.handicapIndex }
    }
    var redTeamPlayers: [Player] {
        players.filter { $0.team == .red }.sorted { $0.handicapIndex < $1.handicapIndex }
    }

    // MARK: - Static Probability Tables
    // Structure: format → matchLength → hole (1-based offset from hole 1) → scoreDifference → (blueWin, redWin, tie)
    // These values are directly from the original app's Tournament.swift probability tables.

    static let matchProbabilities: [String: [Int: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]]]] = [
        "Singles": [
            9: singlesProbabilities9,
            18: singlesProbabilities18
        ],
        "Alternate Shot": [
            9: alternateShotProbabilities9,
            18: alternateShotProbabilities18
        ],
        "Best Ball": [
            9: bestBallProbabilities9,
            18: bestBallProbabilities18
        ],
        "Two Man Scramble": [
            9: twoManScrambleProbabilities9,
            18: twoManScrambleProbabilities18
        ],
        "Shamble": [
            9: shambleProbabilities9,
            18: shambleProbabilities18
        ]
    ]

    // MARK: Singles 9-hole
    private static let singlesProbabilities9: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]] = [
        1: [0: (0.416, 0.416, 0.169)],
        2: [-1: (0.249, 0.589, 0.162), 0: (0.411, 0.411, 0.178), 1: (0.589, 0.249, 0.162)],
        3: [-2: (0.112, 0.765, 0.123), -1: (0.235, 0.595, 0.170), 0: (0.405, 0.405, 0.190),
             1: (0.595, 0.235, 0.170),  2: (0.765, 0.112, 0.123)],
        4: [-3: (0.030, 0.906, 0.064), -2: (0.094, 0.783, 0.123), -1: (0.217, 0.602, 0.180),
             0: (0.398, 0.398, 0.204),   1: (0.602, 0.217, 0.180),  2: (0.783, 0.094, 0.123),
             3: (0.906, 0.030, 0.064)],
        5: [-4: (0.002, 0.981, 0.016), -3: (0.019, 0.926, 0.055), -2: (0.074, 0.804, 0.122),
            -1: (0.196, 0.611, 0.192),   0: (0.389, 0.389, 0.223),  1: (0.611, 0.196, 0.192),
             2: (0.804, 0.074, 0.122),   3: (0.926, 0.019, 0.055),  4: (0.981, 0.002, 0.016)],
        6: [-4: (0.000, 0.992, 0.008), -3: (0.008, 0.949, 0.043), -2: (0.051, 0.830, 0.119),
            -1: (0.170, 0.623, 0.206),   0: (0.376, 0.376, 0.247),  1: (0.623, 0.170, 0.206),
             2: (0.830, 0.051, 0.119),   3: (0.949, 0.008, 0.043),  4: (0.992, 0.000, 0.008)],
        7: [-3: (0.000, 0.973, 0.027), -2: (0.027, 0.865, 0.108), -1: (0.135, 0.640, 0.225),
             0: (0.360, 0.360, 0.280),   1: (0.640, 0.135, 0.225),  2: (0.865, 0.027, 0.108),
             3: (0.973, 0.000, 0.027)],
        8: [-2: (0.000, 0.910, 0.090), -1: (0.090, 0.670, 0.240), 0: (0.330, 0.330, 0.340),
             1: (0.670, 0.090, 0.240),  2: (0.910, 0.000, 0.090)],
        9: [-1: (0.000, 0.700, 0.300),  0: (0.300, 0.300, 0.400), 1: (0.700, 0.000, 0.300)]
    ]

    // MARK: Singles 18-hole
    private static let singlesProbabilities18: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]] = [
        1:  [0: (0.440, 0.440, 0.120)],
        2:  [-1: (0.320, 0.562, 0.118),  0: (0.438, 0.438, 0.124), 1: (0.562, 0.320, 0.118)],
        3:  [-2: (0.211, 0.685, 0.104), -1: (0.315, 0.564, 0.121), 0: (0.436, 0.436, 0.127),
              1: (0.564, 0.315, 0.121),  2: (0.685, 0.211, 0.104)],
        4:  [-3: (0.118, 0.782, 0.100), -2: (0.218, 0.671, 0.111), -1: (0.329, 0.557, 0.114),
              0: (0.443, 0.443, 0.114),   1: (0.557, 0.329, 0.114),  2: (0.671, 0.218, 0.111),
              3: (0.782, 0.118, 0.100)],
        5:  [-4: (0.052, 0.876, 0.072), -3: (0.124, 0.767, 0.109), -2: (0.233, 0.653, 0.114),
             -1: (0.347, 0.541, 0.112),   0: (0.459, 0.459, 0.082),  1: (0.541, 0.347, 0.112),
              2: (0.653, 0.233, 0.114),   3: (0.767, 0.124, 0.109),  4: (0.876, 0.052, 0.072)],
        6:  [-5: (0.016, 0.939, 0.045), -4: (0.061, 0.850, 0.089), -3: (0.150, 0.743, 0.107),
             -2: (0.257, 0.630, 0.113),  -1: (0.370, 0.517, 0.113),  0: (0.483, 0.483, 0.034),
              1: (0.517, 0.370, 0.113),   2: (0.630, 0.257, 0.113),  3: (0.743, 0.150, 0.107),
              4: (0.850, 0.061, 0.089),   5: (0.939, 0.016, 0.045)],
        7:  [-6: (0.002, 0.976, 0.022), -5: (0.024, 0.921, 0.055), -4: (0.079, 0.833, 0.088),
             -3: (0.167, 0.726, 0.107),  -2: (0.274, 0.614, 0.112), -1: (0.386, 0.502, 0.112),
              0: (0.498, 0.498, 0.004),   1: (0.502, 0.386, 0.112),  2: (0.614, 0.274, 0.112),
              3: (0.726, 0.167, 0.107),   4: (0.833, 0.079, 0.088),  5: (0.921, 0.024, 0.055),
              6: (0.976, 0.002, 0.022)],
        8:  [-5: (0.002, 0.960, 0.038), -4: (0.040, 0.885, 0.075), -3: (0.115, 0.785, 0.100),
             -2: (0.215, 0.674, 0.111),  -1: (0.326, 0.562, 0.112),  0: (0.438, 0.438, 0.124),
              1: (0.562, 0.326, 0.112),   2: (0.674, 0.215, 0.111),  3: (0.785, 0.115, 0.100),
              4: (0.885, 0.040, 0.075),   5: (0.960, 0.002, 0.038)],
        9:  [-4: (0.009, 0.936, 0.055), -3: (0.064, 0.852, 0.084), -2: (0.148, 0.748, 0.104),
             -1: (0.252, 0.635, 0.113),   0: (0.365, 0.365, 0.270),  1: (0.635, 0.252, 0.113),
              2: (0.748, 0.148, 0.104),   3: (0.852, 0.064, 0.084),  4: (0.936, 0.009, 0.055)],
        10: [-3: (0.021, 0.909, 0.070), -2: (0.091, 0.822, 0.087), -1: (0.178, 0.713, 0.109),
              0: (0.287, 0.287, 0.426),   1: (0.713, 0.178, 0.109),  2: (0.822, 0.091, 0.087),
              3: (0.909, 0.021, 0.070)],
        11: [-2: (0.027, 0.882, 0.091), -1: (0.118, 0.778, 0.104),  0: (0.222, 0.222, 0.556),
              1: (0.778, 0.118, 0.104),   2: (0.882, 0.027, 0.091)],
        12: [-1: (0.061, 0.842, 0.097),  0: (0.158, 0.158, 0.684),  1: (0.842, 0.061, 0.097)],
        13: [ 0: (0.100, 0.100, 0.800)],
        14: [ 0: (0.060, 0.060, 0.880)],
        15: [ 0: (0.031, 0.031, 0.938)],
        16: [ 0: (0.012, 0.012, 0.976)],
        17: [ 0: (0.003, 0.003, 0.994)],
        18: [ 0: (0.000, 0.000, 1.000)]
    ]

    // MARK: Alternate Shot 9-hole
    private static let alternateShotProbabilities9: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]] = [
        1: [0: (0.416, 0.416, 0.169)],
        2: [-1: (0.249, 0.589, 0.162), 0: (0.411, 0.411, 0.178), 1: (0.589, 0.249, 0.162)],
        3: [-2: (0.112, 0.765, 0.123), -1: (0.235, 0.595, 0.170), 0: (0.405, 0.405, 0.190),
             1: (0.595, 0.235, 0.170),  2: (0.765, 0.112, 0.123)],
        4: [-3: (0.030, 0.906, 0.064), -2: (0.094, 0.783, 0.123), -1: (0.217, 0.602, 0.180),
             0: (0.398, 0.398, 0.204),   1: (0.602, 0.217, 0.180),  2: (0.783, 0.094, 0.123),
             3: (0.906, 0.030, 0.064)],
        5: [-4: (0.002, 0.981, 0.016), -3: (0.019, 0.926, 0.055), -2: (0.074, 0.804, 0.122),
            -1: (0.196, 0.611, 0.192),   0: (0.389, 0.389, 0.223),  1: (0.611, 0.196, 0.192),
             2: (0.804, 0.074, 0.122),   3: (0.926, 0.019, 0.055),  4: (0.981, 0.002, 0.016)],
        6: [-4: (0.000, 0.992, 0.008), -3: (0.008, 0.949, 0.043), -2: (0.051, 0.830, 0.119),
            -1: (0.170, 0.623, 0.206),   0: (0.376, 0.376, 0.247),  1: (0.623, 0.170, 0.206),
             2: (0.830, 0.051, 0.119),   3: (0.949, 0.008, 0.043),  4: (0.992, 0.000, 0.008)],
        7: [-3: (0.000, 0.973, 0.027), -2: (0.027, 0.865, 0.108), -1: (0.135, 0.640, 0.225),
             0: (0.360, 0.360, 0.280),   1: (0.640, 0.135, 0.225),  2: (0.865, 0.027, 0.108),
             3: (0.973, 0.000, 0.027)],
        8: [-2: (0.000, 0.910, 0.090), -1: (0.090, 0.670, 0.240), 0: (0.330, 0.330, 0.340),
             1: (0.670, 0.090, 0.240),  2: (0.910, 0.000, 0.090)],
        9: [-1: (0.000, 0.700, 0.300),  0: (0.300, 0.300, 0.400), 1: (0.700, 0.000, 0.300)]
    ]

    // MARK: Alternate Shot 18-hole (same as singles 18)
    private static let alternateShotProbabilities18 = singlesProbabilities18

    // MARK: Best Ball 9-hole
    private static let bestBallProbabilities9: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]] = [
        1: [0: (0.424, 0.424, 0.152)],
        2: [-1: (0.256, 0.592, 0.152), 0: (0.416, 0.416, 0.168), 1: (0.592, 0.256, 0.152)],
        3: [-2: (0.118, 0.761, 0.121), -1: (0.241, 0.591, 0.168), 0: (0.410, 0.410, 0.180),
             1: (0.591, 0.241, 0.168),  2: (0.761, 0.118, 0.121)],
        4: [-3: (0.033, 0.901, 0.066), -2: (0.099, 0.779, 0.122), -1: (0.222, 0.599, 0.179),
             0: (0.401, 0.401, 0.198),   1: (0.599, 0.222, 0.179),  2: (0.779, 0.099, 0.122),
             3: (0.901, 0.033, 0.066)],
        5: [-4: (0.003, 0.979, 0.018), -3: (0.021, 0.923, 0.056), -2: (0.078, 0.802, 0.120),
            -1: (0.199, 0.609, 0.192),   0: (0.391, 0.391, 0.218),  1: (0.609, 0.199, 0.192),
             2: (0.802, 0.078, 0.120),   3: (0.923, 0.021, 0.056),  4: (0.979, 0.003, 0.018)],
        6: [-4: (0.000, 0.991, 0.009), -3: (0.009, 0.947, 0.044), -2: (0.053, 0.829, 0.118),
            -1: (0.173, 0.621, 0.206),   0: (0.379, 0.379, 0.242),  1: (0.621, 0.173, 0.206),
             2: (0.829, 0.053, 0.118),   3: (0.947, 0.009, 0.044),  4: (0.991, 0.000, 0.009)],
        7: [-3: (0.001, 0.971, 0.028), -2: (0.029, 0.863, 0.108), -1: (0.138, 0.638, 0.224),
             0: (0.363, 0.363, 0.274),   1: (0.638, 0.138, 0.224),  2: (0.863, 0.029, 0.108),
             3: (0.971, 0.001, 0.028)],
        8: [-2: (0.001, 0.909, 0.090), -1: (0.091, 0.669, 0.240), 0: (0.331, 0.331, 0.338),
             1: (0.669, 0.091, 0.240),  2: (0.909, 0.001, 0.090)],
        9: [-1: (0.001, 0.699, 0.300),  0: (0.301, 0.301, 0.398), 1: (0.699, 0.001, 0.300)]
    ]

    // MARK: Best Ball 18-hole
    private static let bestBallProbabilities18 = singlesProbabilities18

    // MARK: Two Man Scramble 9-hole
    private static let twoManScrambleProbabilities9 = alternateShotProbabilities9

    // MARK: Two Man Scramble 18-hole
    private static let twoManScrambleProbabilities18 = singlesProbabilities18

    // MARK: Shamble 9-hole
    private static let shambleProbabilities9 = bestBallProbabilities9

    // MARK: Shamble 18-hole
    private static let shambleProbabilities18 = singlesProbabilities18
}

// MARK: - Helper extension on Array<Player>

private extension Array where Element == Player {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        self.map { $0[keyPath: keyPath] }
    }
}

// Disambiguate Optional.map vs Array.map used on Optional<Player>
private extension Optional where Wrapped == Player {
    func map<T>(_ transform: (Wrapped) -> T) -> T? {
        switch self {
        case .some(let v): return transform(v)
        case .none: return nil
        }
    }
}
