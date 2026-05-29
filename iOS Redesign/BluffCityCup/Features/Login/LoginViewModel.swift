import Foundation

/// Manages all state and logic for the login screen.
@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Form state

    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var selectedTournament: String = ""
    @Published var commishPassword: String = ""

    // MARK: - Loading / error state

    @Published var tournaments: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let api: APIClient
    weak var appState: AppState?

    // MARK: - Private tournament metadata

    private var tournamentCommishName: String = ""
    private var tournamentCommishPassword: String = ""

    init(api: APIClient) {
        self.api = api
    }

    // MARK: - Computed

    var userName: String {
        "\(firstName.trimmingCharacters(in: .whitespaces)) \(lastName.trimmingCharacters(in: .whitespaces))"
    }

    var canLogin: Bool {
        !selectedTournament.isEmpty && !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Actions

    /// Fetch the list of available tournaments from the server.
    func loadTournaments() async {
        isLoading = true
        errorMessage = nil
        do {
            let list = try await api.getTournamentNames()
            tournaments = list.map(\.name).sorted(by: tournamentSort)
            if selectedTournament.isEmpty || !tournaments.contains(selectedTournament),
               let first = tournaments.first {
                selectedTournament = first
            }
        } catch {
            errorMessage = "Could not load tournaments: \(error.localizedDescription)"
        }
        isLoading = false
    }

    /// Restore the last-used tournament name from UserDefaults (call on appear).
    func restoreLastTournament() {
        if let saved = UserDefaults.standard.string(forKey: "TournamentName"),
           !saved.isEmpty {
            selectedTournament = saved
        }
    }

    /// Execute the full login/role-determination flow.
    func login() async {
        guard canLogin else { return }
        guard let appState else { return }

        isLoading = true
        errorMessage = nil

        do {
            // Step 1: Verify tournament exists and fetch commish credentials
            let tourneyCheck = try await api.checkTournament(selectedTournament)
            guard tourneyCheck.found else {
                errorMessage = "No record found for \"\(selectedTournament)\". Please check the tournament name."
                isLoading = false
                return
            }

            tournamentCommishName     = tourneyCheck.commissionerName
            tournamentCommishPassword = tourneyCheck.commishPassword

            // Step 2: Determine role
            let (role, player, isScorekeeper, isInMatch) = try await determineRole()

            // Step 3: Commit session to AppState
            appState.login(
                tournamentName: selectedTournament,
                userName: userName,
                role: role,
                player: player,
                isScorekeeper: isScorekeeper,
                isInMatch: isInMatch
            )

            // Step 4: Load full tournament data in the background (AppState shows loading overlay)
            Task {
                await appState.loadTournamentData(name: selectedTournament)
            }

        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    #if DEBUG
    func loginForScreenshotValidationIfRequested() async {
        guard ProcessInfo.processInfo.arguments.contains("-BCCUITestAutoLogin"),
              appState?.isLoggedIn == false,
              !isLoading else { return }

        firstName = "Luke"
        lastName = "Jensen"
        if selectedTournament.isEmpty {
            selectedTournament = "Bluff City Cup 2025"
        }
        await login()
    }
    #endif

    // MARK: - Private: Role determination

    private func determineRole() async throws -> (role: UserRole, player: Player?, isScorekeeper: Bool, isInMatch: Bool) {
        let userIsCommish = (userName == tournamentCommishName)

        // Check if user exists as a player in the tournament
        let userCheck = try await api.checkUser(name: userName, tournament: selectedTournament)

        if userCheck.found, let player = userCheck.player {
            // User is a registered player
            if userIsCommish {
                // Verify commissioner password
                guard !commishPassword.isEmpty, commishPassword == tournamentCommishPassword else {
                    throw LoginError.incorrectCommissionerPassword
                }
                let isSK = try await api.checkScorekeeper(name: userName, tournament: selectedTournament)
                return (.commissioner, player, isSK, userCheck.inCurrentMatch)
            } else {
                // Regular player — check if also scorekeeper
                let isSK = try await api.checkScorekeeper(name: userName, tournament: selectedTournament)
                if isSK {
                    return (.scorekeeper, player, true, userCheck.inCurrentMatch)
                } else if userCheck.inCurrentMatch {
                    return (.player, player, false, true)
                } else {
                    return (.spectator, player, false, false)
                }
            }
        } else {
            // Not a registered player
            if userIsCommish {
                // Commissioner without a player entry
                guard !commishPassword.isEmpty, commishPassword == tournamentCommishPassword else {
                    throw LoginError.incorrectCommissionerPassword
                }
                return (.commissioner, nil, false, false)
            } else {
                // Offer spectator access
                return (.spectator, nil, false, false)
            }
        }
    }

    private func tournamentSort(_ lhs: String, _ rhs: String) -> Bool {
        let lhsYear = Int(lhs.split(separator: " ").last ?? "") ?? 0
        let rhsYear = Int(rhs.split(separator: " ").last ?? "") ?? 0
        if lhsYear != rhsYear { return lhsYear > rhsYear }
        return lhs > rhs
    }
}

// MARK: - Login Errors

enum LoginError: LocalizedError {
    case incorrectCommissionerPassword

    var errorDescription: String? {
        switch self {
        case .incorrectCommissionerPassword:
            return "Incorrect commissioner password."
        }
    }
}
