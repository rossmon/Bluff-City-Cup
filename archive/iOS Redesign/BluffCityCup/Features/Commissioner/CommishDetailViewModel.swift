import Foundation

/// Manages add/delete operations for players and matches in the commissioner detail screen.
@MainActor
final class CommishDetailViewModel: ObservableObject {

    // MARK: - Published

    @Published var errorMessage: String?
    @Published var isBusy: Bool = false

    // MARK: - Add Player form state

    @Published var newPlayerName: String = ""
    @Published var newPlayerHandicap: String = ""
    @Published var newPlayerTeam: Team = .blue

    // MARK: - Add Match form state

    @Published var newMatchRound: Int = 1
    @Published var newMatchGroup: Int = 1
    @Published var newMatchNumber: Int = 1
    @Published var newMatchFormat: MatchFormat = .singles
    @Published var newMatchCourse: String = ""
    @Published var newMatchTees: String = ""
    @Published var newMatchScorekeeper: String = ""
    @Published var newMatchStartingHole: Int = 1
    @Published var newMatchLength: Int = 18
    @Published var newMatchPoints: Double = 1.0
    @Published var newBluePlayer1: String = ""
    @Published var newRedPlayer1: String  = ""
    @Published var newBluePlayer2: String = ""
    @Published var newRedPlayer2: String  = ""

    // MARK: - Dependencies

    let tournament: Tournament
    private let api: APIClient

    // MARK: - Init

    init(tournament: Tournament, api: APIClient = .shared) {
        self.tournament   = tournament
        self.api          = api
        newMatchRound     = tournament.settings.currentRound
        newMatchCourse    = tournament.courses.first?.name ?? ""
        newMatchTees      = tournament.courses.first?.tees ?? ""
        newMatchNumber    = (tournament.matches.map(\.matchNumber).max() ?? 0) + 1
    }

    // MARK: - Player operations

    var sortedPlayers: [Player] {
        tournament.players.sorted {
            if $0.team != $1.team { return $0.team == .blue }
            return $0.handicapIndex < $1.handicapIndex
        }
    }

    func addPlayer() async {
        let name = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, let handicap = Double(newPlayerHandicap) else {
            errorMessage = "Please enter a valid name and handicap."
            return
        }
        isBusy = true
        let player = Player(name: name, handicapIndex: handicap, team: newPlayerTeam)
        tournament.players.append(player)
        do {
            try await api.updatePlayer(player, tournament: tournament.name)
        } catch {
            errorMessage = "Failed to save player: \(error.localizedDescription)"
            tournament.players.removeAll { $0.id == player.id }
        }
        newPlayerName = ""; newPlayerHandicap = ""
        isBusy = false
    }

    func deletePlayer(_ player: Player) async {
        guard !tournament.matches.contains(where: { $0.players.contains(player) }) else {
            errorMessage = "This player is in a match. Delete the match first."
            return
        }
        isBusy = true
        tournament.players.removeAll { $0.id == player.id }
        do {
            try await api.deletePlayer(name: player.name,
                                       team: player.team.rawValue,
                                       tournament: tournament.name)
        } catch {
            errorMessage = "Failed to delete player: \(error.localizedDescription)"
        }
        isBusy = false
    }

    // MARK: - Match operations

    var sortedMatches: [Match] {
        tournament.matches.sorted {
            if $0.round != $1.round { return $0.round < $1.round }
            return $0.matchNumber < $1.matchNumber
        }
    }

    func addMatch() async {
        guard !newMatchCourse.isEmpty else {
            errorMessage = "Please select a course."
            return
        }
        guard let bp1 = tournament.player(named: newBluePlayer1),
              let rp1 = tournament.player(named: newRedPlayer1) else {
            errorMessage = "Blue Player 1 and Red Player 1 are required."
            return
        }

        isBusy = true

        var players: [Player] = [bp1, rp1]
        if newMatchFormat.isDoubles {
            if let bp2 = tournament.player(named: newBluePlayer2),
               let rp2 = tournament.player(named: newRedPlayer2) {
                players += [bp2, rp2]
            } else {
                errorMessage = "All four players are required for a doubles format."
                isBusy = false
                return
            }
        }

        let match = Match(
            tournament: tournament.name,
            round: newMatchRound, group: newMatchGroup, matchNumber: newMatchNumber,
            format: newMatchFormat, players: players,
            scorekeeperName: newMatchScorekeeper,
            courseName: newMatchCourse, tees: newMatchTees,
            startingHole: newMatchStartingHole, matchLength: newMatchLength,
            points: newMatchPoints,
            currentHole: newMatchStartingHole, isCompleted: false,
            cachedScoreString: "AS", cachedTeamLeading: "AS", cachedScore: 0
        )

        tournament.matches.append(match)

        do {
            try await api.updateMatch(match, tournament: tournament)
        } catch {
            errorMessage = "Failed to save match: \(error.localizedDescription)"
            tournament.matches.removeAll { $0.id == match.id }
        }

        // Increment match number for next add
        newMatchNumber += 1
        isBusy = false
    }

    func deleteMatch(_ match: Match) async {
        guard !match.isCompleted && match.currentHole <= match.startingHole else {
            errorMessage = "This match has already started and cannot be deleted."
            return
        }
        isBusy = true
        tournament.matches.removeAll { $0.id == match.id }
        do {
            try await api.deleteMatch(match)
        } catch {
            errorMessage = "Failed to delete match: \(error.localizedDescription)"
        }
        isBusy = false
    }

    // MARK: - Match display helpers

    func matchDisplayName(_ match: Match) -> String {
        let bp1 = lastName(match.bluePlayerOne?.name ?? "?")
        let rp1 = lastName(match.redPlayerOne?.name  ?? "?")
        if match.format.isDoubles {
            let bp2 = lastName(match.bluePlayerTwo?.name ?? "?")
            let rp2 = lastName(match.redPlayerTwo?.name  ?? "?")
            return "\(bp1)/\(bp2) vs \(rp1)/\(rp2)"
        }
        return "\(bp1) vs \(rp1)"
    }

    private func lastName(_ full: String) -> String {
        full.split(separator: " ").last.map(String.init) ?? full
    }
}
