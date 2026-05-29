import Foundation

/// Holds derived display state for ScoreboardView.
/// The View owns the EnvironmentObject and calls reload/refresh directly.
@MainActor
final class ScoreboardViewModel: ObservableObject {

    // MARK: - Published state

    @Published var sortedMatches: [Match] = []
    @Published var blueCompleted: Double = 0
    @Published var blueLive:      Double = 0
    @Published var redCompleted:  Double = 0
    @Published var redLive:       Double = 0

    // MARK: - Auto-refresh

    private var refreshTimer: Timer?

    // MARK: - Public API (called from View)

    func reload(from tournament: Tournament?) {
        guard let tournament else {
            sortedMatches = []
            blueCompleted = 0; blueLive = 0; redCompleted = 0; redLive = 0
            return
        }
        sortedMatches = tournament.matchesSortedForTable()
        let (bc, rc) = tournament.completedScores()
        let (bl, rl) = tournament.liveScores()
        blueCompleted = bc
        redCompleted  = rc
        blueLive      = bl
        redLive       = rl
    }

    func refresh(appState: AppState) async {
        await appState.refresh()
    }

    func startAutoRefresh(appState: AppState) {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard self != nil else { return }
            Task { await appState.refresh() }
        }
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
