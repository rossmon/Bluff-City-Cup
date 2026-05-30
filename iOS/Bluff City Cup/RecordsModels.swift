//
//  RecordsModels.swift
//  Bluff City Cup
//

import Foundation

struct RecordsPayload: Decodable {
    let success: Bool
    let source: String?
    let rowCount: Int?
    let rows: [RecordsMatchResult]
    let yearOutcomes: [RecordsYearOutcome]
    let matchCourses: [RecordsMatchCourse]
    let holes: [RecordsHole]
    let scores: [RecordsScore]
    let playerHandicaps: [RecordsPlayerHandicap]
    let coursesMeta: [RecordsCourseMeta]
    let tournamentSettings: [RecordsTournamentSetting]
    let matchSummaries: [RecordsMatchSummary]
    let playerBios: [RecordsPlayerBio]
    let playerPictures: [RecordsPlayerPicture]
}

struct RecordsMatchResult: Decodable {
    let id: Int?
    let player1: String
    let player2: String
    let player3: String
    let player4: String
    let team: String
    let round: String
    let match: String
    let year: String
    let format: String
    let winOrLoss: String
    let points: String
    let score: String

    enum CodingKeys: String, CodingKey {
        case id, player1, player2, player3, player4, team, round, match, year, format, points, score
        case winOrLoss = "win_or_loss"
    }
}

struct RecordsYearOutcome: Decodable {
    let year: String
    let location: String
    let blueTeamScore: String
    let redTeamScore: String

    enum CodingKeys: String, CodingKey {
        case year, location
        case blueTeamScore = "blue_team_score"
        case redTeamScore = "red_team_score"
    }
}

struct RecordsMatchCourse: Decodable {
    let year: String
    let round: String
    let matchgroup: String
    let match: String
    let course: String
    let tees: String
    let matchlength: String
    let startinghole: String
}

struct RecordsHole: Decodable {
    let course: String
    let tees: String
    let holenumber: String
    let handicap: String
    let par: String
    let length: String
}

struct RecordsScore: Decodable {
    let year: String
    let tournament: String
    let round: String
    let course: String
    let hole: String
    let player: String
    let actualscore: String
}

struct RecordsPlayerHandicap: Decodable {
    let year: String
    let tournament: String
    let name: String
    let team: String
    let handicap: String
}

struct RecordsCourseMeta: Decodable {
    let course: String
    let tees: String
    let slope: String
    let rating: String
    let par: String
}

struct RecordsTournamentSetting: Decodable {
    let year: String
    let tournament: String
    let maxhandicap: String
}

struct RecordsMatchSummary: Decodable {
    let year: String
    let round: String
    let match: String
    let matchUid: String
    let matchgroup: String
    let format: String
    let summary: String
    let wordCount: String
    let model: String

    enum CodingKeys: String, CodingKey {
        case year, round, match, matchgroup, format, summary, model
        case matchUid = "match_uid"
        case wordCount = "word_count"
    }
}

struct RecordsPlayerBio: Decodable {
    let playerName: String
    let team: String
    let firstName: String
    let lastName: String
    let careerMatches: String
    let wins: String
    let losses: String
    let ties: String
    let points: String
    let bio: String
    let wordCount: String
    let model: String

    enum CodingKeys: String, CodingKey {
        case team, wins, losses, ties, points, bio, model
        case playerName = "player_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case careerMatches = "career_matches"
        case wordCount = "word_count"
    }
}

struct RecordsPlayerPicture: Decodable {
    let file: String
    let team: String
    let first: String
    let last: String
    let key: String
    let url: String
}

struct RecordsStats {
    var matches = 0
    var wins = 0
    var losses = 0
    var ties = 0
    var points = 0.0

    mutating func apply(outcome: String, points value: Double) {
        matches += 1
        points += value

        switch outcome.bccNormalized.lowercased() {
        case "win":
            wins += 1
        case "loss":
            losses += 1
        case "tie":
            ties += 1
        default:
            break
        }
    }

    var wlt: String {
        return "\(wins)-\(losses)-\(ties)"
    }

    var winPctValue: Double {
        guard matches > 0 else { return 0 }
        return ((Double(wins) + (0.5 * Double(ties))) / Double(matches)) * 100
    }

    var winTiePctValue: Double {
        guard matches > 0 else { return 0 }
        return ((Double(wins + ties)) / Double(matches)) * 100
    }

    var winPctText: String {
        return RecordsFormatters.percent(winPctValue)
    }

    var winTiePctText: String {
        return RecordsFormatters.percent(winTiePctValue)
    }
}

struct RecordsRankRow {
    let rank: Int
    let title: String
    let subtitle: String
    let team: String
    let format: String
    let stats: RecordsStats
}

struct RecordsComparisonRow {
    let label: String
    let red: RecordsStats
    let blue: RecordsStats
}

struct RecordsMatchOutcomeRow {
    let year: String
    let round: String
    let match: String
    let format: String
    let redPlayers: [String]
    let bluePlayers: [String]
    let winner: String
    let score: String
    let course: String
    let tees: String
    let summary: String
}

struct RecordsHeadToHeadMatch {
    let year: String
    let round: String
    let match: String
    let format: String
    let redPlayers: [String]
    let bluePlayers: [String]
    let redResult: String
    let blueResult: String
    let redPoints: Double
    let bluePoints: Double
    let score: String
}

struct RecordsPlayerProfile {
    let name: String
    let team: String
    let bio: String
    let photoURL: URL?
    let overall: RecordsStats
    let byFormat: [RecordsRankRow]
    let byYear: [RecordsRankRow]
    let recentMatches: [RecordsMatchOutcomeRow]
    let personalRecords: [RecordsPersonalRecord]
}

struct RecordsPersonalRecord {
    let title: String
    let value: String
}

enum RecordsRankSort: String {
    case winPercent
    case points
    case matches
    case name

    var title: String {
        switch self {
        case .winPercent: return "Win %"
        case .points: return "Points"
        case .matches: return "Matches"
        case .name: return "Name"
        }
    }
}

struct RecordsYearPointTotal {
    let year: String
    let red: Double
    let blue: Double
    let location: String
}

enum RecordsFormatters {
    static func points(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }

    static func percent(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
}

extension String {
    var bccNormalized: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
