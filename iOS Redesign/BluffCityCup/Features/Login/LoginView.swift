import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = LoginViewModel(api: APIClient.shared)

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blueTeam, Color.blueTeam.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        headerSection
                        formCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            vm.appState = appState
            vm.restoreLastTournament()
            await vm.loadTournaments()
            #if DEBUG
            await vm.loginForScreenshotValidationIfRequested()
            #endif
        }
        .onAppear {
            vm.appState = appState
        }
        .alert("Login Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "flag.fill")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.white)

            Text("Bluff City Cup")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Golf Tournament")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 20) {
            // Tournament picker
            VStack(alignment: .leading, spacing: 6) {
                Label("Tournament", systemImage: "trophy")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                if vm.isLoading && vm.tournaments.isEmpty {
                    HStack {
                        ProgressView()
                            .padding(.trailing, 4)
                        Text("Loading tournaments…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Picker("Tournament", selection: $vm.selectedTournament) {
                        ForEach(vm.tournaments, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Divider()

            // Name fields
            VStack(alignment: .leading, spacing: 6) {
                Label("Your Name", systemImage: "person")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    TextField("First", text: $vm.firstName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.givenName)
                        .autocorrectionDisabled()

                    TextField("Last", text: $vm.lastName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.familyName)
                        .autocorrectionDisabled()
                }
            }

            Divider()

            // Commissioner password (optional)
            VStack(alignment: .leading, spacing: 6) {
                Label("Commissioner Password", systemImage: "lock")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                SecureField("Optional — commissioner access only", text: $vm.commishPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
            }

            // Debug quick-login button (simulator only)
            #if DEBUG
            Button("Quick Login (Luke Jensen)") {
                vm.firstName = "Luke"
                vm.lastName  = "Jensen"
                Task { await vm.login() }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            #endif

            // Login button
            Button(action: {
                Task { await vm.login() }
            }) {
                HStack {
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.trailing, 4)
                    }
                    Text(vm.isLoading ? "Signing in…" : "Sign In")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(vm.canLogin ? Color.blueTeam : Color.secondary.opacity(0.4),
                            in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .disabled(!vm.canLogin || vm.isLoading)
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
