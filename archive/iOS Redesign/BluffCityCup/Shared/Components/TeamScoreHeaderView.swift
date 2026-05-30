import SwiftUI

/// The Blue | Red team score header at the top of the scoreboard.
/// Matches the old app: side-by-side color cards with a floating "Live" badge in the center.
struct TeamScoreHeaderView: View {
    let blueCompleted: Double
    let blueLive: Double
    let redCompleted: Double
    let redLive: Double

    var body: some View {
        HStack(spacing: 2) {
            blueCard
            liveBadge
            redCard
        }
        .frame(height: 62)
        .padding(.horizontal, 2)
    }

    // MARK: - Blue card

    private var blueCard: some View {
        HStack(spacing: 0) {
            Text("Blue")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.white)
            Spacer()
            Text(formatScore(blueCompleted))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blueTeam)
    }

    // MARK: - Red card

    private var redCard: some View {
        HStack(spacing: 0) {
            Text(formatScore(redCompleted))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Text("Red")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.redTeam)
    }

    // MARK: - Live badge

    private var liveBadge: some View {
        VStack(spacing: 2) {
            Text("Live")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.primary)
            HStack(spacing: 6) {
                Text(formatScore(blueLive))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.blueTeam)
                Text(formatScore(redLive))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.redTeam)
            }
        }
        .frame(width: 94, height: 62)
        .padding(.horizontal, 2)
        .padding(.vertical, 5)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color(UIColor.separator), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }

    // MARK: - Helpers

    private func formatScore(_ score: Double) -> String {
        score.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(score))
            : String(format: "%.1f", score)
    }
}
