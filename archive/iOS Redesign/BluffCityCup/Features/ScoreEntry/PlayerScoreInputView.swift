import SwiftUI

/// A single player's score input row: team dot + name + decrement + score + increment.
struct PlayerScoreInputView: View {
    let player: Player
    @Binding var score: Int

    private let minScore = 1
    private let maxScore = 12

    var body: some View {
        HStack(spacing: 16) {
            // Team color indicator
            Circle()
                .fill(Color.teamColor(player.team))
                .frame(width: 10, height: 10)

            // Player name
            Text(player.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Stepper controls
            HStack(spacing: 20) {
                Button {
                    if score > minScore { score -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(score > minScore ? Color.teamColor(player.team) : .secondary)
                }
                .buttonStyle(.plain)
                .disabled(score <= minScore)

                Text(score == 0 ? "—" : "\(score)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(score == 0 ? .tertiary : .primary)
                    .frame(minWidth: 36)
                    .monospacedDigit()

                Button {
                    if score < maxScore { score += 1 }
                    else if score == 0  { score = 1 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(score < maxScore ? Color.teamColor(player.team) : .secondary)
                }
                .buttonStyle(.plain)
                .disabled(score >= maxScore)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}
