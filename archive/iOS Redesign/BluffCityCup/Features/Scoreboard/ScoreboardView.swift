import SwiftUI
import Combine

struct ScoreboardView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = ScoreboardViewModel()

    // Gray table background matching old app (#AAAAAA)
    private static let listBg = Color(red: 170/255, green: 170/255, blue: 170/255)

    var body: some View {
        VStack(spacing: 0) {
            // Score header (navy-toned cards)
            TeamScoreHeaderView(
                blueCompleted: vm.blueCompleted,
                blueLive:      vm.blueLive,
                redCompleted:  vm.redCompleted,
                redLive:       vm.redLive
            )
            .padding(.vertical, 2)
            .background(Color.blueTeam)

            // Match card list
            ScrollView {
                LazyVStack(spacing: 0) {
                    if vm.sortedMatches.isEmpty && !appState.isLoading {
                        UnavailableView(
                            title: "No Matches",
                            systemImage: "flag.checkered",
                            description: "No matches have been created yet."
                        )
                        .padding(.top, 60)
                    } else {
                        ForEach(vm.sortedMatches) { match in
                            MatchRowView(match: match)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .refreshable { await vm.refresh(appState: appState) }
            .background(Self.listBg)
        }
        .background(Self.listBg.ignoresSafeArea())
        .onAppear {
            vm.reload(from: appState.tournament)
            vm.startAutoRefresh(appState: appState)
        }
        .onDisappear { vm.stopAutoRefresh() }
        .onReceive(appState.$tournament) { vm.reload(from: $0) }
        .overlay {
            if appState.isLoading && vm.sortedMatches.isEmpty {
                LoadingOverlayView(message: "Loading scoreboard…")
            }
        }
    }
}
