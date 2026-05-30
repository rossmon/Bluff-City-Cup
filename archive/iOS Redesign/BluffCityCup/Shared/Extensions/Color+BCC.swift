import SwiftUI

extension Color {
    /// Blue team navy: #0F296B
    static let blueTeam  = Color(red: 0.059, green: 0.161, blue: 0.420)
    /// Red team crimson: #B70A1C
    static let redTeam   = Color(red: 0.718, green: 0.039, blue: 0.110)
    /// Light blue team tint for backgrounds
    static let blueTeamLight = Color(red: 0.059, green: 0.161, blue: 0.420).opacity(0.15)
    /// Light red team tint for backgrounds
    static let redTeamLight  = Color(red: 0.718, green: 0.039, blue: 0.110).opacity(0.15)

    static func teamColor(_ team: Team) -> Color {
        team == .blue ? .blueTeam : .redTeam
    }

    static func teamLightColor(_ team: Team) -> Color {
        team == .blue ? .blueTeamLight : .redTeamLight
    }
}
