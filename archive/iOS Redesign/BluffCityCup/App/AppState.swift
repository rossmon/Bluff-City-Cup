import SwiftUI

/// Single source of truth for the active session.
/// Injected into the SwiftUI environment at the root.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Session state

    @Published var user: AppUser = AppUser()
    @Published var tournament: Tournament?
    @Published var isLoading: Bool = false
    @Published var loadError: String?

    // MARK: - Networking

    let api = APIClient.shared

    // MARK: - Persistence keys

    private enum Defaults {
        static let tournamentName = "TournamentName"
        static let userName       = "UserName"
        static let userRole       = "UserRole"
        static let isScorekeeper  = "Scorekeeper"
    }

    var isLoggedIn: Bool { user.isLoggedIn }

    // MARK: - Login

    func login(tournamentName: String, userName: String, role: UserRole,
               player: Player?, isScorekeeper: Bool, isInMatch: Bool) {
        user = AppUser(name: userName, role: role, player: player,
                       isScorekeeper: isScorekeeper, isInMatch: isInMatch)
        persistSession(tournamentName: tournamentName, userName: userName,
                       role: role, isScorekeeper: isScorekeeper)
    }

    func logout() {
        user = AppUser()
        tournament = nil
        clearPersistedSession()
    }

    // MARK: - Data loading

    func loadTournamentData(name: String) async {
        isLoading = true
        loadError = nil
        do {
            let bundle = try await api.fetchTournamentData(name: name)
            tournament = bundle.tournament
            tournament?.refreshAllHoleWinners()
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        guard let name = tournament?.name else { return }
        await loadTournamentData(name: name)
    }

    // MARK: - Session persistence

    func restoreSession() -> (tournamentName: String, userName: String, role: UserRole)? {
        let defaults = UserDefaults.standard
        guard let tournamentName = defaults.string(forKey: Defaults.tournamentName),
              let userName = defaults.string(forKey: Defaults.userName),
              let roleRaw = defaults.string(forKey: Defaults.userRole),
              let role = UserRole(rawValue: roleRaw) else { return nil }
        return (tournamentName, userName, role)
    }

    private func persistSession(tournamentName: String, userName: String,
                                 role: UserRole, isScorekeeper: Bool) {
        let d = UserDefaults.standard
        d.set(tournamentName, forKey: Defaults.tournamentName)
        d.set(userName,       forKey: Defaults.userName)
        d.set(role.rawValue,  forKey: Defaults.userRole)
        d.set(isScorekeeper,  forKey: Defaults.isScorekeeper)
    }

    private func clearPersistedSession() {
        let d = UserDefaults.standard
        d.removeObject(forKey: Defaults.tournamentName)
        d.removeObject(forKey: Defaults.userName)
        d.removeObject(forKey: Defaults.userRole)
        d.removeObject(forKey: Defaults.isScorekeeper)
    }
}

// MARK: - Tournament convenience

extension Tournament {
    /// Refresh hole winners for all matches.
    func refreshAllHoleWinners() {
        for match in matches { refreshHoleWinners(match: match) }
    }
}
