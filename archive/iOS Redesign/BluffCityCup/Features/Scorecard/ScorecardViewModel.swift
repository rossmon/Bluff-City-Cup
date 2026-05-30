import Foundation

enum ScorecardDisplayMode: String, CaseIterable {
    case score  = "Scores"
    case handicapStrokes = "Strokes"
}

/// Drives ScorecardView — computes per-player, per-hole display values.
@MainActor
final class ScorecardViewModel: ObservableObject {

    // MARK: - Published

    @Published var displayMode: ScorecardDisplayMode = .score

    // MARK: - Input

    let match: Match
    let tournament: Tournament

    // MARK: - Init

    init(match: Match, tournament: Tournament) {
        self.match      = match
        self.tournament = tournament
    }

    // MARK: - Course

    var course: Course? { tournament.course(named: match.courseName) }

    // MARK: - Holes (front 9 and back 9 separately for the full grid)

    var frontHoles: [Hole] {
        guard let c = course else { return [] }
        let all = c.holes.sorted { $0.number < $1.number }
        if match.matchLength == 9 {
            return all.filter { $0.number >= match.startingHole && $0.number < match.startingHole + 9 }
        }
        return all.filter { (1...9).contains($0.number) }
    }

    var backHoles: [Hole] {
        guard let c = course, match.matchLength == 18 else { return [] }
        let all = c.holes.sorted { $0.number < $1.number }
        return all.filter { (10...18).contains($0.number) }
    }

    var showBothNines: Bool { match.matchLength == 18 }

    // MARK: - Match score for header display

    var matchScoreDisplay: String {
        let ms = tournament.matchScore(match)
        if ms.scoreString == "AS" || ms.scoreString == "Halved" {
            return ms.scoreString
        }
        let secondary = ms.secondaryString.replacingOccurrences(of: " ", with: "")
        return secondary.isEmpty ? ms.scoreString : "\(ms.scoreString) \(secondary)"
    }

    var matchScoreLeader: Team? {
        tournament.matchScore(match).teamLeading
    }

    // MARK: - Player rows (team-level for scramble, individual for others)

    /// Players displayed as rows. For scramble/alternate shot: one per team.
    var displayRows: [ScorecardRow] {
        switch match.format {
        case .twoManScramble, .alternateShot, .fourManScramble:
            return [
                ScorecardRow(player: match.bluePlayers.first, team: .blue,
                             label: teamLabel(for: .blue)),
                ScorecardRow(player: match.redPlayers.first, team: .red,
                             label: teamLabel(for: .red))
            ].compactMap { $0.player != nil ? $0 : nil }
        default:
            // Best ball / singles — individual rows
            return (match.bluePlayers + match.redPlayers).map { p in
                return ScorecardRow(player: p, team: p.team, label: playerRowLabel(p))
            }
        }
    }

    private func teamLabel(for team: Team) -> String {
        guard let c = course else { return team == .blue ? "Blue" : "Red" }
        let players = team == .blue ? match.bluePlayers : match.redPlayers
        let hdcp = tournament.teamHandicap(format: match.format, players: players,
                                           slope: c.slope, rating: c.rating,
                                           par: c.par, maxHdcp: tournament.maxHandicap)
        return "\(team == .blue ? "Blue" : "Red") (\(hdcp))"
    }

    private func playerRowLabel(_ player: Player) -> String {
        guard let c = course else { return player.lastName }
        let hdcp: Int
        if match.format == .shamble {
            hdcp = player.shambleHandicap(slope: c.slope, rating: c.rating,
                                          par: c.par, maxHandicap: tournament.maxHandicap)
        } else {
            hdcp = player.courseHandicap(slope: c.slope, rating: c.rating,
                                         par: c.par, maxHandicap: tournament.maxHandicap)
        }
        return "\(player.lastName) (\(hdcp))"
    }

    // MARK: - Score display value

    func displayValue(player: Player, hole: Hole) -> Int? {
        let gross = player.score(hole: hole.number, round: match.round)
        switch displayMode {
        case .score:
            guard gross > 0 else { return nil }
            return gross
        case .handicapStrokes:
            let strokes = strokesForDisplay(player: player, hole: hole)
            return strokes > 0 ? strokes : nil
        }
    }

    private func strokesForDisplay(player: Player, hole: Hole) -> Int {
        guard let c = course else { return 0 }

        switch match.format {
        case .alternateShot, .twoManScramble, .fourManScramble:
            let blue = tournament.teamHandicap(format: match.format, players: match.bluePlayers,
                                               slope: c.slope, rating: c.rating,
                                               par: c.par, maxHdcp: tournament.maxHandicap)
            let red = tournament.teamHandicap(format: match.format, players: match.redPlayers,
                                              slope: c.slope, rating: c.rating,
                                              par: c.par, maxHdcp: tournament.maxHandicap)
            let adjusted = player.team == .blue ? max(0, blue - red) : max(0, red - blue)
            return Match.strokesOnHole(playerHandicap: adjusted, holeHandicapIndex: hole.handicapIndex)

        case .singles:
            guard let opponent = (player.team == .blue ? match.redPlayers.first : match.bluePlayers.first) else { return 0 }
            let playerHdcp = player.courseHandicap(slope: c.slope, rating: c.rating,
                                                   par: c.par, maxHandicap: tournament.maxHandicap)
            let oppHdcp = opponent.courseHandicap(slope: c.slope, rating: c.rating,
                                                  par: c.par, maxHandicap: tournament.maxHandicap)
            return Match.strokesOnHole(playerHandicap: max(0, playerHdcp - oppHdcp),
                                       holeHandicapIndex: hole.handicapIndex)

        case .bestBall, .shamble:
            let shamble = match.format == .shamble
            let playerHdcp = shamble
                ? player.shambleHandicap(slope: c.slope, rating: c.rating,
                                         par: c.par, maxHandicap: tournament.maxHandicap)
                : player.courseHandicap(slope: c.slope, rating: c.rating,
                                        par: c.par, maxHandicap: tournament.maxHandicap)
            let low = tournament.lowestPlayerHandicap(match: match, slope: c.slope,
                                                      rating: c.rating, par: c.par,
                                                      maxHdcp: tournament.maxHandicap,
                                                      shamble: shamble)
            return Match.strokesOnHole(playerHandicap: max(0, playerHdcp - low),
                                       holeHandicapIndex: hole.handicapIndex)
        }
    }

    func scoreAnnotation(gross: Int, par: Int) -> ScoreAnnotation {
        let diff = gross - par
        switch diff {
        case ..<(-1): return .eagle
        case -1:      return .birdie
        case 0:       return .par
        case 1:       return .bogey
        default:      return .doubleBogey
        }
    }

    func holeWinner(for hole: Hole) -> Team? {
        Team(rawValue: match.holeWinners[hole.number] ?? "")
    }

    func holeTotalFor(player: Player, holes: [Hole]) -> Int {
        holes.reduce(0) { $0 + player.score(hole: $1.number, round: match.round) }
    }

    // MARK: - Player header info

    /// "LASTNAME (index)" for the VS header
    func playerHeaderName(_ player: Player) -> String {
        let parts = player.name.split(separator: " ")
        let last = parts.last.map(String.init) ?? player.name
        return "\(last.uppercased()) (\(String(format: "%.1f", player.handicapIndex)))"
    }

    func playerImageURL(_ player: Player) -> URL? {
        let slug = player.name.lowercased().replacingOccurrences(of: " ", with: "_")
        return URL(string: "https://glizzyattheturn.app/bcc/\(slug).png")
    }
}

// MARK: - Row model

struct ScorecardRow {
    let player: Player?
    let team: Team
    let label: String
}

// MARK: - Score annotation kind

enum ScoreAnnotation: Equatable {
    case eagle, birdie, par, bogey, doubleBogey
}
