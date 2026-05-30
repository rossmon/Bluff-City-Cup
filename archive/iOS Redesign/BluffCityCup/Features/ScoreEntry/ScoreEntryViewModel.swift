import Foundation

/// Manages per-hole score entry for a single match.
@MainActor
final class ScoreEntryViewModel: ObservableObject {

    // MARK: - Published state

    /// The hole number currently displayed (1-based course hole number).
    @Published var viewingHole: Int
    /// Scores keyed by player id.
    @Published var scores: [UUID: Int] = [:]
    /// Whether the "end match" confirmation sheet is showing.
    @Published var showEndMatchConfirmation: Bool = false
    /// Whether an async save is in progress.
    @Published var isSaving: Bool = false
    /// Non-nil when an error should be presented to the user.
    @Published var errorMessage: String?

    // MARK: - Dependencies

    let match: Match
    private let tournament: Tournament
    private let api: APIClient

    // MARK: - Init

    init(match: Match, tournament: Tournament, api: APIClient = .shared) {
        self.match      = match
        self.tournament = tournament
        self.api        = api

        // Start on current hole (capped to valid hole range)
        let displayHole: Int
        if match.isCompleted || match.currentHole > match.finalHole {
            displayHole = match.finalHole
        } else {
            displayHole = max(match.startingHole, match.currentHole)
        }
        self.viewingHole = displayHole
        loadScores(for: displayHole)
    }

    // MARK: - Computed

    var isOnLastHole: Bool { viewingHole == match.finalHole }
    var isOnFirstHole: Bool { viewingHole == match.startingHole }

    var currentHoleData: Hole? {
        tournament.course(named: match.courseName)?.hole(viewingHole)
    }

    var matchScoreDisplay: MatchScore {
        tournament.matchScore(match)
    }

    /// Players shown in the score entry UI, in order.
    var entryPlayers: [Player] {
        switch match.format {
        case .fourManScramble:
            // One score per team — return one player per team as representative
            return [match.bluePlayerOne, match.redPlayerOne].compactMap { $0 }
        default:
            // All players: blue first, then red
            return match.bluePlayers + match.redPlayers
        }
    }

    var allScoresEntered: Bool {
        entryPlayers.allSatisfy { player in
            let s = scores[player.id] ?? 0
            return s > 0
        }
    }

    // MARK: - Navigation

    func goToPreviousHole() {
        guard !isOnFirstHole else { return }
        let idx = match.holeRange.firstIndex(of: viewingHole) ?? 0
        if idx > 0 {
            viewingHole = match.holeRange[idx - 1]
            loadScores(for: viewingHole)
        }
    }

    /// Attempt to advance. If on last hole, trigger end-match confirmation.
    func requestNextHole() {
        guard allScoresEntered else {
            errorMessage = "Please enter all players' scores before advancing."
            return
        }
        if isOnLastHole {
            showEndMatchConfirmation = true
        } else {
            Task { await saveHoleAndAdvance(finish: false) }
        }
    }

    func confirmEndMatch() {
        Task { await saveHoleAndAdvance(finish: true) }
    }

    // MARK: - Private: Save + Advance

    private func saveHoleAndAdvance(finish: Bool) async {
        isSaving = true
        defer { isSaving = false }

        guard let course = tournament.course(named: match.courseName) else { return }
        let holeData = course.hole(viewingHole)

        // 1. Persist individual scores to server
        await saveScoresToServer(hole: viewingHole, course: course)

        // 2. Set player scores in model
        for player in match.players {
            let s = scores[player.id] ?? 0
            if s > 0 { player.setScore(s, hole: viewingHole, round: match.round) }
        }

        // 3. Compute and record hole winner
        tournament.refreshHoleWinners(match: match)

        // 4. Advance match state
        if finish {
            match.isCompleted = true
            let holeAfter = nextHoleNumber(after: viewingHole)
            match.currentHole = holeAfter ?? (viewingHole + 1)
        } else {
            let next = nextHoleNumber(after: viewingHole) ?? (viewingHole + 1)
            if match.currentHole <= viewingHole {
                match.currentHole = next
            }
            viewingHole = next
            loadScores(for: viewingHole)
        }

        // 5. Persist match state to server
        do {
            try await api.updateMatch(match, tournament: tournament)
        } catch {
            errorMessage = "Failed to save match: \(error.localizedDescription)"
        }

        // 6. If finishing, send push notification
        if finish {
            await sendCompletionNotification()
        }

        _ = holeData  // suppress unused warning
    }

    private func saveScoresToServer(hole: Int, course: Course) async {
        let courseName = course.name
        await withTaskGroup(of: Void.self) { group in
            for player in match.players {
                let s = scores[player.id] ?? 0
                guard s > 0 else { continue }
                group.addTask { [weak self] in
                    guard let self else { return }
                    try? await self.api.updateHoleScore(
                        player: player,
                        round: self.match.round,
                        course: courseName,
                        hole: hole,
                        score: s,
                        tournament: self.match.tournament
                    )
                }
            }
        }
    }

    private func sendCompletionNotification() async {
        let matchScoreResult = tournament.matchScore(match)
        let winTeam = matchScoreResult.teamLeading?.rawValue ?? "AS"

        var winnerNames = ""
        var loserNames  = ""
        let bp1 = match.bluePlayerOne?.name ?? ""
        let rp1 = match.redPlayerOne?.name  ?? ""

        if match.format.isDoubles {
            let bp2 = match.bluePlayerTwo?.name ?? ""
            let rp2 = match.redPlayerTwo?.name  ?? ""
            let blueNames = lastName(bp1) + "/" + lastName(bp2)
            let redNames  = lastName(rp1) + "/" + lastName(rp2)
            if winTeam == "Blue" { winnerNames = blueNames; loserNames = redNames }
            else if winTeam == "Red" { winnerNames = redNames; loserNames = blueNames }
        } else {
            if winTeam == "Blue" { winnerNames = bp1; loserNames = rp1 }
            else if winTeam == "Red" { winnerNames = rp1; loserNames = bp1 }
        }

        try? await api.sendMatchNotification(
            winningTeam: winTeam,
            winnerNames: winnerNames,
            loserNames: loserNames,
            scoreString: matchScoreResult.scoreString,
            round: match.round,
            matchNum: match.matchNumber
        )
    }

    // MARK: - Private helpers

    private func loadScores(for hole: Int) {
        for player in match.players {
            scores[player.id] = player.score(hole: hole, round: match.round)
        }
    }

    private func nextHoleNumber(after hole: Int) -> Int? {
        guard let idx = match.holeRange.firstIndex(of: hole),
              idx + 1 < match.holeRange.count else { return nil }
        return match.holeRange[idx + 1]
    }

    private func lastName(_ fullName: String) -> String {
        fullName.split(separator: " ").last.map(String.init) ?? fullName
    }
}
