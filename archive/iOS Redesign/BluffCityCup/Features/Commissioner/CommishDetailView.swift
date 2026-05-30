import SwiftUI

struct CommishDetailView: View {
    @EnvironmentObject private var appState: AppState
    let mode: CommishDetailMode

    var body: some View {
        Group {
            if let tournament = appState.tournament {
                CommishDetailContentView(
                    mode: mode,
                    vm: CommishDetailViewModel(tournament: tournament)
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No Tournament")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Content

private struct CommishDetailContentView: View {
    @Environment(\.dismiss) private var dismiss
    let mode: CommishDetailMode
    @StateObject var vm: CommishDetailViewModel
    @State private var showAddSheet = false

    var body: some View {
        List {
            switch mode {
            case .players: playerRows
            case .matches: matchRows
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") { dismiss() }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                switch mode {
                case .players: AddPlayerSheet(vm: vm)
                case .matches: AddMatchSheet(vm: vm)
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .overlay {
            if vm.isBusy { LoadingOverlayView(message: "Working…") }
        }
    }

    // MARK: - Player rows

    private var playerRows: some View {
        ForEach(vm.sortedPlayers) { player in
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.teamColor(player.team))
                    .frame(width: 10, height: 10)
                Text(player.name)
                Spacer()
                Text("Hdcp \(String(format: "%.1f", player.handicapIndex))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    Task { await vm.deletePlayer(player) }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    // MARK: - Match rows

    private var matchRows: some View {
        ForEach(vm.sortedMatches) { match in
            VStack(alignment: .leading, spacing: 3) {
                Text(vm.matchDisplayName(match))
                    .font(.subheadline.weight(.medium))
                Text("R\(match.round)  ·  M\(match.matchNumber)  ·  \(match.format.rawValue)  ·  \(match.courseName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    Task { await vm.deleteMatch(match) }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - Add Player sheet

private struct AddPlayerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: CommishDetailViewModel

    var body: some View {
        Form {
            Section("Player Info") {
                TextField("Full Name", text: $vm.newPlayerName)
                    .textContentType(.name)
                    .autocorrectionDisabled()

                HStack {
                    Text("Handicap Index")
                    Spacer()
                    TextField("0.0", text: $vm.newPlayerHandicap)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 70)
                }

                Picker("Team", selection: $vm.newPlayerTeam) {
                    Text("Blue").tag(Team.blue)
                    Text("Red").tag(Team.red)
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Add Player")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await vm.addPlayer(); dismiss() }
                }
                .disabled(vm.newPlayerName.isEmpty || vm.newPlayerHandicap.isEmpty)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}

// MARK: - Add Match sheet

private struct AddMatchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: CommishDetailViewModel

    var body: some View {
        Form {
            Section("Match Info") {
                Stepper("Round \(vm.newMatchRound)", value: $vm.newMatchRound, in: 1...10)
                Stepper("Group \(vm.newMatchGroup)", value: $vm.newMatchGroup, in: 1...99)
                Stepper("Match # \(vm.newMatchNumber)", value: $vm.newMatchNumber, in: 1...99)

                Picker("Format", selection: $vm.newMatchFormat) {
                    ForEach(MatchFormat.allCases, id: \.self) { fmt in
                        Text(fmt.rawValue).tag(fmt)
                    }
                }

                Picker("Length", selection: $vm.newMatchLength) {
                    Text("9 Holes").tag(9)
                    Text("18 Holes").tag(18)
                }
                .pickerStyle(.segmented)

                Picker("Starting Hole", selection: $vm.newMatchStartingHole) {
                    Text("Hole 1").tag(1)
                    Text("Hole 10").tag(10)
                }
                .pickerStyle(.segmented)

                HStack {
                    Text("Points")
                    Spacer()
                    TextField("1.0", value: $vm.newMatchPoints, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 60)
                }
            }

            Section("Course") {
                TextField("Course Name", text: $vm.newMatchCourse)
                    .autocorrectionDisabled()
                TextField("Tees", text: $vm.newMatchTees)
                    .autocorrectionDisabled()
                TextField("Scorekeeper Name", text: $vm.newMatchScorekeeper)
                    .autocorrectionDisabled()
            }

            Section("Players") {
                playerNameField("Blue Player 1", binding: $vm.newBluePlayer1, team: .blue)
                playerNameField("Red Player 1",  binding: $vm.newRedPlayer1,  team: .red)
                if vm.newMatchFormat.isDoubles {
                    playerNameField("Blue Player 2", binding: $vm.newBluePlayer2, team: .blue)
                    playerNameField("Red Player 2",  binding: $vm.newRedPlayer2,  team: .red)
                }
            }
        }
        .navigationTitle("Add Match")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await vm.addMatch(); dismiss() }
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private func playerNameField(_ label: String, binding: Binding<String>, team: Team) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.teamColor(team))
                .frame(width: 8, height: 8)
            TextField(label, text: binding)
                .autocorrectionDisabled()
        }
    }
}
