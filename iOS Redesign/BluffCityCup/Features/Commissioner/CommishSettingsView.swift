import SwiftUI

struct CommishSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if let tournament = appState.tournament {
            CommishSettingsInner(tournament: tournament)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "lock")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("Tournament not loaded.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Inner view (owns the stable ViewModel)

private struct CommishSettingsInner: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm: CommishSettingsViewModel
    @State private var showDetail: CommishDetailMode?

    init(tournament: Tournament) {
        _vm = StateObject(wrappedValue: CommishSettingsViewModel(tournament: tournament))
    }

    var body: some View {
        Form {
            tournamentSection
            drinkCartSection
            managementSection
            dangerSection
        }
        .navigationTitle("Commish Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { Task { await vm.save() } }
                    .disabled(vm.isSaving)
            }
        }
        .overlay {
            if vm.isSaving { LoadingOverlayView(message: "Saving…") }
        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .confirmationDialog("Delete All Matches",
                            isPresented: $vm.showDeleteMatchesConfirmation,
                            titleVisibility: .visible) {
            Button("Delete All Matches and Scores", role: .destructive) {
                Task { await vm.deleteAllMatches() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all matches and hole scores for this tournament.")
        }
        .sheet(item: $showDetail) { mode in
            NavigationStack {
                CommishDetailView(mode: mode)
            }
            .environmentObject(appState)
        }
    }

    // MARK: - Sections

    private var tournamentSection: some View {
        Section("Tournament") {
            Stepper("Rounds: \(vm.numberOfRounds)",
                    value: $vm.numberOfRounds, in: 1...10)

            Stepper("Current Round: \(vm.currentRound)",
                    value: $vm.currentRound, in: 1...vm.numberOfRounds)

            HStack {
                Text("Max Handicap")
                Spacer()
                TextField("36", value: $vm.maxHandicap, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
            }

            HStack {
                Text("Commissioner Password")
                Spacer()
                SecureField("Password", text: $vm.commishPassword)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var drinkCartSection: some View {
        Section("Drink Cart") {
            Toggle("Enable Drink Cart", isOn: $vm.drinkCartEnabled)
            if vm.drinkCartEnabled {
                HStack {
                    Text("Phone Number")
                    Spacer()
                    TextField("555-0100", text: $vm.drinkCartNumber)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.phonePad)
                }
            }
        }
    }

    private var managementSection: some View {
        Section("Management") {
            Button {
                showDetail = .players
            } label: {
                Label("Edit Players", systemImage: "person.2")
                    .foregroundStyle(.primary)
            }

            Button {
                showDetail = .matches
            } label: {
                Label("Edit Matches", systemImage: "flag.2.crossed")
                    .foregroundStyle(.primary)
            }
        }
    }

    private var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                vm.showDeleteMatchesConfirmation = true
            } label: {
                Label("Delete All Matches", systemImage: "trash")
            }
        }
    }
}

// MARK: - Detail mode

enum CommishDetailMode: Identifiable {
    case players, matches
    var id: Self { self }
    var title: String {
        switch self {
        case .players: return "Edit Players"
        case .matches: return "Edit Matches"
        }
    }
}
