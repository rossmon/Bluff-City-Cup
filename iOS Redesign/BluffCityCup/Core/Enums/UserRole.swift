import Foundation

/// The role a user plays within a tournament.
/// Raw values match the strings persisted in UserDefaults and passed to the backend.
enum UserRole: String, Codable {
    case commissioner = "Commissioner"
    case scorekeeper  = "Scorekeeper"
    case player       = "Player"
    case spectator    = "Spectator"

    /// Whether this role can access score entry.
    var canEnterScores: Bool {
        self == .scorekeeper || self == .commissioner
    }

    /// Whether this role has access to commissioner settings.
    var isCommissioner: Bool {
        self == .commissioner
    }

    /// Whether this role can view personal scorecard / hole map.
    var hasPlayerView: Bool {
        self == .player || self == .scorekeeper || self == .commissioner
    }
}
