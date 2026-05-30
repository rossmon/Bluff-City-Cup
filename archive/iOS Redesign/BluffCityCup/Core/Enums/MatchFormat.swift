import Foundation

/// All match formats supported by the tournament.
/// Raw values match the exact strings stored in the backend database.
enum MatchFormat: String, CaseIterable, Identifiable, Codable {
    case singles         = "Singles"
    case alternateShot   = "Alternate Shot"
    case bestBall        = "Best Ball"
    case shamble         = "Shamble"
    case twoManScramble  = "Two Man Scramble"
    case fourManScramble = "Four Man Scramble"

    var id: String { rawValue }

    /// Number of players per team for this format.
    var playersPerTeam: Int {
        switch self {
        case .singles:                      return 1
        case .alternateShot, .twoManScramble, .bestBall, .shamble: return 2
        case .fourManScramble:              return 4
        }
    }

    /// Total players in a match of this format.
    var totalPlayers: Int { playersPerTeam * 2 }

    var isDoubles: Bool { playersPerTeam > 1 }

    var displayName: String { rawValue }
}
