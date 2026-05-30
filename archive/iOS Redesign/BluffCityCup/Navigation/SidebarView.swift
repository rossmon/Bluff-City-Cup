import SwiftUI

// MARK: - Navigation Destination

enum NavDestination: String, Hashable, CaseIterable {
    case scoreboard      = "Scoreboard"
    case scoreEntry      = "Score Entry"
    case scorecard       = "Scorecard"
    case holeMap         = "Hole Map"
    case drinkCart       = "Drink Cart"
    case settings        = "Settings"
    case commishSettings = "Commish Settings"

    var icon: String {
        switch self {
        case .scoreboard:      return "list.number"
        case .scoreEntry:      return "pencil.circle"
        case .scorecard:       return "tablecells"
        case .holeMap:         return "map"
        case .drinkCart:       return "cart"
        case .settings:        return "gear"
        case .commishSettings: return "person.badge.key"
        }
    }
}

// MARK: - Main Split View

struct MainSplitView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedDestination: NavDestination? = Self.initialDestination
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selected: $selectedDestination)
        } detail: {
            destinationView(for: selectedDestination ?? .scoreboard)
                .navigationTitle(selectedDestination?.rawValue ?? "")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.blueTeam, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationSplitViewStyle(.balanced)
    }

    private static var initialDestination: NavDestination {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if let index = args.firstIndex(of: "-BCCUITestInitialView"),
           args.indices.contains(index + 1),
           let destination = NavDestination(rawValue: args[index + 1]) {
            return destination
        }
        #endif
        return .scoreboard
    }

    @ViewBuilder
    private func destinationView(for dest: NavDestination) -> some View {
        switch dest {
        case .scoreboard:
            ScoreboardView()
        case .scoreEntry:
            ScoreEntryContainerView()
        case .scorecard:
            ScorecardContainerView()
        case .holeMap:
            HoleMapContainerView()
        case .drinkCart:
            DrinkCartView()
        case .settings:
            Text("Settings") // SettingsView placeholder until Phase 6
        case .commishSettings:
            CommishSettingsView()
        }
    }
}

// MARK: - Sidebar

struct SidebarView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var selected: NavDestination?

    var body: some View {
        List(availableDestinations, id: \.self, selection: $selected) { dest in
            Label(dest.rawValue, systemImage: dest.icon)
                .tag(dest)
        }
        .listStyle(.sidebar)
        .navigationTitle(appState.tournament?.name ?? "Bluff City Cup")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { appState.logout() }) {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }

    /// Compute available menu items based on role and tournament state.
    private var availableDestinations: [NavDestination] {
        let user = appState.user
        let tournament = appState.tournament
        var items: [NavDestination] = [.scoreboard]

        if user.role.canEnterScores && user.isScorekeeper {
            items.append(.scoreEntry)
        }
        if user.role.hasPlayerView {
            items.append(.scorecard)
            items.append(.holeMap)
        }
        if tournament?.settings.drinkCartEnabled == true && user.role.hasPlayerView {
            items.append(.drinkCart)
        }
        if user.role.isCommissioner {
            items.append(.settings)
            items.append(.commishSettings)
        }
        return items
    }
}

// MARK: - Container stubs for views requiring a match

struct ScoreEntryContainerView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if let player = appState.user.player,
           let tournament = appState.tournament,
           let match = tournament.currentMatch(forPlayer: player) {
            ScoreEntryView(match: match, tournament: tournament)
        } else if appState.user.isScorekeeper {
            UnavailableView(title: "No Active Match",
                            systemImage: "flag.checkered",
                            description: "You are not assigned to an active match.")
        } else {
            UnavailableView(title: "Score Entry Unavailable",
                            systemImage: "lock",
                            description: "You must be a scorekeeper to enter scores.")
        }
    }
}

struct ScorecardContainerView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if let player = appState.user.player,
           let tournament = appState.tournament,
           let match = tournament.currentMatch(forPlayer: player) {
            ScorecardView(match: match, tournament: tournament)
        } else if let tournament = appState.tournament,
                  let match = tournament.matches.first {
            ScorecardView(match: match, tournament: tournament)
        } else {
            UnavailableView(title: "No Match", systemImage: "tablecells",
                            description: "No matches available.")
        }
    }
}

struct HoleMapContainerView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if let tournament = appState.tournament,
           let player = appState.user.player,
           let match = tournament.currentMatch(forPlayer: player) {
            HoleMapView(match: match, tournament: tournament)
        } else if let tournament = appState.tournament,
                  let match = tournament.matches.first {
            HoleMapView(match: match, tournament: tournament)
        } else {
            UnavailableView(title: "No Match", systemImage: "map",
                            description: "No matches available.")
        }
    }
}
