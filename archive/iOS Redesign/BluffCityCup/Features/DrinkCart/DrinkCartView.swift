import SwiftUI
import MessageUI

struct DrinkCartView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showMessageCompose = false
    @State private var cannotSendAlert   = false

    private var drinkCartNumber: String {
        appState.tournament?.settings.drinkCartNumber ?? ""
    }

    private var messageBody: String {
        let name = appState.user.name
        if let player = appState.user.player,
           let tournament = appState.tournament,
           let match = tournament.currentMatch(forPlayer: player) {
            return "\(name) is requesting beers on hole \(match.currentHole)."
        }
        return "\(name) is requesting beers. Please text back this number for their location."
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "cart.fill")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(Color.blueTeam)

            VStack(spacing: 8) {
                Text("Drink Cart")
                    .font(.title.weight(.bold))
                Text("Tap the button below to request\nbeers delivered to your hole.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                if MFMessageComposeViewController.canSendText() {
                    showMessageCompose = true
                } else {
                    cannotSendAlert = true
                }
            } label: {
                Label("Request Drinks", systemImage: "message.fill")
                    .font(.headline)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 16)
                    .background(Color.blueTeam, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showMessageCompose) {
            MessageComposeView(recipients: [drinkCartNumber], body: messageBody)
        }
        .alert("Unavailable", isPresented: $cannotSendAlert) {
            Button("OK") {}
        } message: {
            Text("You are unable to send a text message from this device.")
        }
    }
}

// MARK: - UIViewControllerRepresentable wrapper for MFMessageComposeViewController

struct MessageComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let body: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.recipients = recipients
        vc.body = body
        vc.messageComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }

        func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                          didFinishWith result: MessageComposeResult) {
            dismiss()
        }
    }
}
