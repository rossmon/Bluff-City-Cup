import SwiftUI

struct ScoreEntryView: View {
    @StateObject private var vm: ScoreEntryViewModel

    init(match: Match, tournament: Tournament) {
        _vm = StateObject(wrappedValue: ScoreEntryViewModel(match: match, tournament: tournament))
    }

    var body: some View {
        VStack(spacing: 0) {
            holeHeader
            matchScoreBadge
            Divider()
            playerInputList
            Spacer()
            navigationBar
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            "End Match",
            isPresented: $vm.showEndMatchConfirmation,
            titleVisibility: .visible
        ) {
            Button("Finish Match", role: .destructive) { vm.confirmEndMatch() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to end this match?")
        }
        .alert("Score Entry", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .overlay {
            if vm.isSaving {
                LoadingOverlayView(message: "Saving…")
            }
        }
        .disabled(vm.match.isCompleted)
    }

    // MARK: - Hole header strip

    private var holeHeader: some View {
        HStack(spacing: 0) {
            holeHeaderItem(title: "Hole", value: "\(vm.viewingHole)")
            Divider().frame(height: 32)
            holeHeaderItem(title: "Par",  value: "\(vm.currentHoleData?.par ?? 0)")
            Divider().frame(height: 32)
            holeHeaderItem(title: "Yds",  value: "\(vm.currentHoleData?.length ?? 0)")
            Divider().frame(height: 32)
            holeHeaderItem(title: "Hdcp", value: "\(vm.currentHoleData?.handicapIndex ?? 0)")
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private func holeHeaderItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.bold))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Match score badge

    private var matchScoreBadge: some View {
        let ms = vm.matchScoreDisplay
        let bgColor: Color = {
            switch ms.teamLeading {
            case .blue: return .blueTeam
            case .red:  return .redTeam
            default:    return Color(.systemGray4)
            }
        }()

        return HStack(spacing: 6) {
            Image(systemName: "flag.fill")
                .font(.caption)
            Text(ms.scoreString)
                .font(.subheadline.weight(.semibold))
            if !ms.secondaryString.isEmpty {
                Text(ms.secondaryString.trimmingCharacters(in: .whitespaces))
                    .font(.subheadline)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(bgColor, in: Capsule())
        .padding(.vertical, 10)
    }

    // MARK: - Player input rows

    private var playerInputList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(vm.entryPlayers) { player in
                    PlayerScoreInputView(
                        player: player,
                        score: Binding(
                            get: { vm.scores[player.id] ?? 0 },
                            set: { vm.scores[player.id] = $0 }
                        )
                    )
                    Divider().padding(.leading, 36)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        }
    }

    // MARK: - Navigation bar

    private var navigationBar: some View {
        HStack(spacing: 12) {
            Button {
                vm.goToPreviousHole()
            } label: {
                Label("Previous", systemImage: "chevron.left")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
            }
            .disabled(vm.isOnFirstHole)
            .foregroundStyle(vm.isOnFirstHole ? .secondary : .primary)

            Button {
                vm.requestNextHole()
            } label: {
                Group {
                    if vm.isOnLastHole {
                        Label("Finish Match", systemImage: "flag.checkered")
                    } else {
                        Label("Next Hole", systemImage: "chevron.right")
                            .labelStyle(ReversedLabelStyle())
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blueTeam, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
        .background(.regularMaterial)
    }
}

// MARK: - Reversed label style (icon on right)

private struct ReversedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

