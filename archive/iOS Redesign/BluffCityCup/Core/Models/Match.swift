import Foundation

// MARK: - MatchScore

struct MatchScore {
    let scoreString: String      // e.g. "3 UP", "AS", "2 & 1", "Halved"
    let secondaryString: String  // e.g. "& 1" portion split out, or ""
    let score: Int               // positive = blue winning, negative = red
    let teamLeading: Team?       // nil == all square
    let isFinished: Bool
}

// MARK: - Match

final class Match: ObservableObject, Identifiable {
    let id: UUID = UUID()

    // Identity
    var tournament: String
    var round: Int
    var group: Int
    var matchNumber: Int

    // Setup
    @Published var format: MatchFormat
    @Published var players: [Player]          // ordered: blueP1, blueP2 (if doubles), redP1, redP2
    @Published var scorekeeperName: String
    @Published var courseName: String
    @Published var tees: String
    @Published var startingHole: Int          // 1 or 10
    @Published var matchLength: Int           // 9 or 18
    @Published var points: Double             // 1.0 default

    // Live state
    @Published var currentHole: Int           // hole number currently being played
    @Published var isCompleted: Bool
    @Published var cachedScoreString: String  // last persisted score string (from server)
    @Published var cachedTeamLeading: String  // "Blue", "Red", or "AS"
    @Published var cachedScore: Int

    /// holeWinners[holeNumber] → "Blue", "Red", or "Halved"
    @Published var holeWinners: [Int: String] = [:]

    /// Win probabilities keyed by hole number (fetched separately)
    var matchProbabilities: [(hole: Int, scoreDiff: Int, blueWin: Double, redWin: Double, tie: Double)] = []

    init(tournament: String, round: Int, group: Int, matchNumber: Int,
         format: MatchFormat, players: [Player], scorekeeperName: String,
         courseName: String, tees: String, startingHole: Int, matchLength: Int,
         points: Double, currentHole: Int, isCompleted: Bool,
         cachedScoreString: String, cachedTeamLeading: String, cachedScore: Int) {
        self.tournament       = tournament
        self.round            = round
        self.group            = group
        self.matchNumber      = matchNumber
        self.format           = format
        self.players          = players
        self.scorekeeperName  = scorekeeperName
        self.courseName       = courseName
        self.tees             = tees
        self.startingHole     = startingHole
        self.matchLength      = matchLength
        self.points           = points
        self.currentHole      = currentHole
        self.isCompleted      = isCompleted
        self.cachedScoreString = cachedScoreString
        self.cachedTeamLeading = cachedTeamLeading
        self.cachedScore      = cachedScore
    }

    // MARK: - Player Accessors (sorted by handicap index ascending within each team)

    var bluePlayers: [Player] {
        players.filter { $0.team == .blue }.sorted { $0.handicapIndex < $1.handicapIndex }
    }
    var redPlayers: [Player] {
        players.filter { $0.team == .red }.sorted { $0.handicapIndex < $1.handicapIndex }
    }

    var bluePlayerOne: Player? { bluePlayers.first }
    var bluePlayerTwo: Player? { bluePlayers.count > 1 ? bluePlayers[1] : nil }
    var redPlayerOne:  Player? { redPlayers.first }
    var redPlayerTwo:  Player? { redPlayers.count > 1 ? redPlayers[1] : nil }

    // MARK: - Hole Range

    /// All hole numbers for this match in play order.
    var holeRange: [Int] {
        (0..<matchLength).map { (startingHole - 1 + $0) % 18 + 1 }
    }

    var finalHole: Int { holeRange.last ?? 18 }

    var holesPlayed: Int {
        let played = holeRange.prefix(while: { $0 < currentHole || ($0 == currentHole && holeWinners[$0] != nil) })
        return played.count
    }

    // MARK: - Handicap Stroke Helpers

    /// Returns how many handicap strokes a player receives on a given hole.
    /// - Parameters:
    ///   - playerHandicap: Course-adjusted capped handicap (integer)
    ///   - holeHandicapIndex: Stroke index for the hole (1–18)
    static func strokesOnHole(playerHandicap: Int, holeHandicapIndex: Int) -> Int {
        var strokes = 0
        // First pass: 1 stroke on holes with index ≤ playerHandicap (capped at 18)
        if holeHandicapIndex <= min(playerHandicap, 18) { strokes += 1 }
        // Second pass: if handicap > 18, another stroke on holes with index ≤ (handicap − 18)
        if playerHandicap > 18 && holeHandicapIndex <= (playerHandicap - 18) { strokes += 1 }
        // Third pass: if handicap > 36
        if playerHandicap > 36 && holeHandicapIndex <= (playerHandicap - 36) { strokes += 1 }
        return strokes
    }

    /// Net score after subtracting handicap strokes.
    static func netScore(gross: Int, playerHandicap: Int, holeHandicapIndex: Int) -> Int {
        gross - strokesOnHole(playerHandicap: playerHandicap, holeHandicapIndex: holeHandicapIndex)
    }
}

extension Match: Equatable {
    static func == (lhs: Match, rhs: Match) -> Bool { lhs.id == rhs.id }
}

extension Match: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
