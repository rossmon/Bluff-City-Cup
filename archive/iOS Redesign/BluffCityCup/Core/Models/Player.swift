import Foundation

/// A tournament participant.
final class Player: ObservableObject, Identifiable {
    let id: UUID = UUID()
    @Published var name: String
    @Published var handicapIndex: Double   // raw USGA handicap index
    @Published var team: Team

    /// hole scores keyed by [round][holeNumber] → gross strokes
    @Published private var holeScores: [Int: [Int: Int]] = [:]

    init(name: String, handicapIndex: Double, team: Team) {
        self.name = name
        self.handicapIndex = handicapIndex
        self.team = team
    }

    // MARK: - Handicap Calculations

    /// Course handicap adjusted for slope, rating, and par.
    /// Formula: round( handicapIndex × (slope / 113) + (rating − par) ), capped at maxHandicap.
    func courseHandicap(slope: Int, rating: Double, par: Double, maxHandicap: Int) -> Int {
        let adjusted = (handicapIndex * (Double(slope) / 113.0)) + (rating - par)
        return min(Int(adjusted.rounded()), maxHandicap)
    }

    /// Shamble handicap: 80 % of course handicap, capped at maxHandicap.
    func shambleHandicap(slope: Int, rating: Double, par: Double, maxHandicap: Int) -> Int {
        let adjusted = 0.8 * ((handicapIndex * (Double(slope) / 113.0)) + (rating - par))
        return min(Int(adjusted.rounded()), maxHandicap)
    }

    // MARK: - Hole Score Management

    func score(hole: Int, round: Int) -> Int {
        holeScores[round]?[hole] ?? 0
    }

    func setScore(_ score: Int, hole: Int, round: Int) {
        if holeScores[round] == nil { holeScores[round] = [:] }
        holeScores[round]![hole] = score
    }

    func allScores(round: Int) -> [Int: Int] {
        holeScores[round] ?? [:]
    }

    func clearScores(round: Int) {
        holeScores[round] = [:]
    }

    // MARK: - Display

    var lastName: String {
        let parts = name.split(separator: " ")
        return parts.count > 1 ? String(parts.last!) : name
    }
}

extension Player: Equatable {
    static func == (lhs: Player, rhs: Player) -> Bool { lhs.id == rhs.id }
}

extension Player: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Team

enum Team: String, Codable, CaseIterable {
    case blue = "Blue"
    case red  = "Red"

    var displayName: String { rawValue }
    var opposite: Team { self == .blue ? .red : .blue }
}
