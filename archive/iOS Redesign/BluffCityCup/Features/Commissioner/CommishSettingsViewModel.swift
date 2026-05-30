import Foundation

/// Drives CommishSettingsView. Holds editable copies of tournament settings
/// and persists them via APIClient when the user saves.
@MainActor
final class CommishSettingsViewModel: ObservableObject {

    // MARK: - Editable fields

    @Published var numberOfRounds: Int
    @Published var currentRound: Int
    @Published var maxHandicap: Int
    @Published var commishPassword: String
    @Published var drinkCartEnabled: Bool
    @Published var drinkCartNumber: String

    // MARK: - State

    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var errorMessage: String?
    @Published var showDeleteMatchesConfirmation: Bool = false

    // MARK: - Dependencies

    private let tournament: Tournament
    private let api: APIClient

    // MARK: - Init

    init(tournament: Tournament, api: APIClient = .shared) {
        self.tournament    = tournament
        self.api           = api
        let s              = tournament.settings
        numberOfRounds     = s.numberOfRounds
        currentRound       = s.currentRound
        maxHandicap        = s.maxHandicap
        commishPassword    = s.commissionerPassword
        drinkCartEnabled   = s.drinkCartEnabled
        drinkCartNumber    = s.drinkCartNumber
    }

    // MARK: - Save

    func save() async {
        isSaving = true
        errorMessage = nil

        // Apply changes back to the model
        tournament.settings.numberOfRounds       = numberOfRounds
        tournament.settings.currentRound         = currentRound
        tournament.settings.maxHandicap          = maxHandicap
        tournament.settings.commissionerPassword = commishPassword
        tournament.settings.drinkCartEnabled     = drinkCartEnabled
        tournament.settings.drinkCartNumber      = drinkCartNumber

        do {
            try await api.updateTournament(tournament)
            saveSuccess = true
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
        isSaving = false
    }

    // MARK: - Delete all matches

    func deleteAllMatches() async {
        isSaving = true
        errorMessage = nil
        do {
            try await api.deleteAllMatches(tournament: tournament.name)
            tournament.matches.removeAll()
        } catch {
            errorMessage = "Failed to delete matches: \(error.localizedDescription)"
        }
        isSaving = false
    }
}
