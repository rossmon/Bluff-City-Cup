import Foundation

/// The currently signed-in user. Value type — no singleton.
struct AppUser: Equatable {
    var name: String
    var role: UserRole
    /// The Player record for this user, if they are registered as a player.
    var player: Player?
    /// True when the user is the assigned scorekeeper for at least one active match.
    var isScorekeeper: Bool
    /// True when the user is a participant in at least one active match.
    var isInMatch: Bool

    init(name: String = "",
         role: UserRole = .spectator,
         player: Player? = nil,
         isScorekeeper: Bool = false,
         isInMatch: Bool = false) {
        self.name = name
        self.role = role
        self.player = player
        self.isScorekeeper = isScorekeeper
        self.isInMatch = isInMatch
    }

    var isLoggedIn: Bool { !name.isEmpty }

    var firstName: String {
        String(name.split(separator: " ").first ?? "")
    }
    var lastName: String {
        let parts = name.split(separator: " ")
        return parts.count > 1 ? String(parts.last!) : ""
    }

    static func == (lhs: AppUser, rhs: AppUser) -> Bool {
        lhs.name == rhs.name && lhs.role == rhs.role
    }
}
