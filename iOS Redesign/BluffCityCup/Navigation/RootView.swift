import SwiftUI

/// The top-level view. Shows LoginView when the user is not authenticated,
/// otherwise presents the main NavigationSplitView with sidebar navigation.
struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainSplitView()
            } else {
                LoginView()
            }
        }
        .overlay {
            if appState.isLoading {
                LoadingOverlayView(message: "Loading tournament…")
            }
        }
    }
}
