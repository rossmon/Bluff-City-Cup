import SwiftUI
import Charts

// MARK: - Triangle shapes

private struct RightPointingTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: 0, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

private struct LeftPointingTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.maxX, y: 0))
        p.addLine(to: CGPoint(x: 0, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - MatchRowView

/// A single match card in the scoreboard list.
/// Matches the old app's MatchTableViewCell18/Cell9 layout exactly.
struct MatchRowView: View {
    @EnvironmentObject private var appState: AppState
    let match: Match
    @State private var isExpanded = ProcessInfo.processInfo.arguments.contains("-BCCUITestExpandMatches")

    // MARK: - Derived

    private var tournament: Tournament? { appState.tournament }

    private var matchScore: MatchScore {
        tournament?.matchScore(match) ?? MatchScore(
            scoreString: match.cachedScoreString,
            secondaryString: "",
            score: match.cachedScore,
            teamLeading: Team(rawValue: match.cachedTeamLeading),
            isFinished: match.isCompleted
        )
    }

    private var leadingTeam: Team? { matchScore.teamLeading }

    // The last hole that has been scored
    private var lastScoredHole: Int {
        guard let tournament else { return match.holeWinners.keys.max() ?? (match.startingHole - 1) }
        let completed = tournament.matchCompletionDetails(match).lastHoleCompleted
        guard completed > 0 else { return match.startingHole - 1 }
        return match.startingHole + completed - 1
    }

    // MARK: - Panel & score colors

    private var bluePanelBg: Color {
        leadingTeam == .blue ? .blueTeam : Color(UIColor.systemBackground)
    }
    private var redPanelBg: Color {
        leadingTeam == .red ? .redTeam : Color(UIColor.systemBackground)
    }
    private var blueNameColor: Color {
        leadingTeam == .blue ? .white : .primary
    }
    private var redNameColor: Color {
        leadingTeam == .red ? .white : .primary
    }
    private var scoreColor: Color {
        switch leadingTeam {
        case .blue: return .blueTeam
        case .red:  return .redTeam
        default:    return .primary
        }
    }

    // MARK: - Status

    private var isNotStarted: Bool { lastScoredHole < match.startingHole }
    private var isUnderway:   Bool { !match.isCompleted && !isNotStarted }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            teamPanelRow
            holeCirclesRow
            expandButton
            if isExpanded {
                probabilitySection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.35), radius: 5, x: 0, y: 2)
        .padding(.horizontal, 4)
        .padding(.vertical, 5)
    }

    // MARK: - Team Panel Row

    private let triangleWidth: CGFloat = 14

    private var teamPanelRow: some View {
        HStack(spacing: 0) {
            bluePanel
            RightPointingTriangle()
                .fill(bluePanelBg)
                .frame(width: triangleWidth)
            scoreCenter
                .frame(minWidth: 80)
                .padding(.vertical, 8)
            LeftPointingTriangle()
                .fill(redPanelBg)
                .frame(width: triangleWidth)
            redPanel
        }
    }

    private var bluePanel: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(match.bluePlayers) { player in
                playerNameStack(player: player, alignment: .leading)
                    .foregroundStyle(blueNameColor)
            }
        }
        .padding(.vertical, 10)
        .padding(.leading, 10)
        .padding(.trailing, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bluePanelBg)
    }

    private var redPanel: some View {
        VStack(alignment: .trailing, spacing: 2) {
            ForEach(match.redPlayers) { player in
                playerNameStack(player: player, alignment: .trailing)
                    .foregroundStyle(redNameColor)
            }
        }
        .padding(.vertical, 10)
        .padding(.trailing, 10)
        .padding(.leading, 2)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(redPanelBg)
    }

    private func playerNameStack(player: Player, alignment: HorizontalAlignment) -> some View {
        let parts = player.name.split(separator: " ")
        let first = parts.first.map(String.init) ?? player.name
        let last  = parts.dropFirst().last.map(String.init) ?? ""
        return VStack(alignment: alignment, spacing: 0) {
            Text(first)
                .font(.system(size: 13).italic())
            if !last.isEmpty {
                Text(last)
                    .font(.system(size: 13).italic())
            }
        }
    }

    // MARK: - Score Center (includes round/match info + score)

    private var scoreCenter: some View {
        VStack(spacing: 2) {
            // Match info line
            Text("Round \(match.round), Match \(match.matchNumber)")
                .font(.system(size: 10).italic())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Score
            if matchScore.scoreString == "AS" {
                Text("AS")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
            } else if matchScore.scoreString == "Halved" {
                Text("Halved")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)
            } else {
                // e.g. "2" + "UP"  or  "3" + "& 2"
                HStack(alignment: .lastTextBaseline, spacing: 1) {
                    Text(matchScore.scoreString)
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(scoreColor)
                    if !matchScore.secondaryString.isEmpty {
                        Text(matchScore.secondaryString.replacingOccurrences(of: " ", with: ""))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(scoreColor)
                    }
                }
            }

            // Status label
            if match.isCompleted {
                Text("Final")
                    .font(.system(size: 11).italic())
                    .foregroundStyle(.secondary)
            } else if isNotStarted {
                Text("Not Started")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Hole Circles Row

    private var holeCirclesRow: some View {
        GeometryReader { geo in
            let holes  = match.holeRange
            let count  = max(holes.count, 1)
            let gap    = CGFloat(1)
            let diam   = min(18, (geo.size.width - 8 - gap * CGFloat(count - 1)) / CGFloat(count))

            HStack(spacing: gap) {
                ForEach(holes, id: \.self) { hole in
                    holeCircleView(hole: hole, diameter: max(diam, 10))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
        }
        .frame(height: 24)
        .padding(.top, 2)
        .padding(.bottom, 2)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Color(UIColor.separator)),
                 alignment: .top)
    }

    private func holeCircleView(hole: Int, diameter: CGFloat) -> some View {
        let state = holeState(hole)
        return ZStack {
            Circle().fill(state.bg)
            if state.showX {
                Canvas { ctx, size in
                    var p1 = Path()
                    p1.move(to: CGPoint(x: size.width * 0.15, y: size.height * 0.85))
                    p1.addLine(to: CGPoint(x: size.width * 0.85, y: size.height * 0.15))
                    ctx.stroke(p1, with: .color(.gray), lineWidth: 1.5)

                    var p2 = Path()
                    p2.move(to: CGPoint(x: size.width * 0.15, y: size.height * 0.15))
                    p2.addLine(to: CGPoint(x: size.width * 0.85, y: size.height * 0.85))
                    ctx.stroke(p2, with: .color(.gray), lineWidth: 1.5)
                }
                .clipShape(Circle())
            }
            Text("\(hole)")
                .font(.system(size: max(7, diameter * 0.40), weight: .semibold))
                .foregroundStyle(state.fg)
        }
        .frame(width: diameter, height: diameter)
    }

    private struct HoleState {
        let bg: Color
        let fg: Color
        let showX: Bool
    }

    private static let notPlayedColor = Color(red: 220/255, green: 220/255, blue: 220/255)

    private func holeState(_ hole: Int) -> HoleState {
        guard hole <= lastScoredHole else {
            let showX = match.isCompleted
            return HoleState(bg: Self.notPlayedColor, fg: Color(UIColor.darkGray), showX: showX)
        }
        switch match.holeWinners[hole] {
        case "Blue":
            return HoleState(bg: .blueTeam, fg: .white, showX: false)
        case "Red":
            return HoleState(bg: .redTeam, fg: .white, showX: false)
        default:
            return HoleState(bg: Color(UIColor.darkGray), fg: .white, showX: false)
        }
    }

    // MARK: - Expand / Collapse Button

    private var expandButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 16, weight: .regular))
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .frame(maxWidth: .infinity)
                .frame(height: 22)
                .foregroundStyle(Color(red: 0.0, green: 0.48, blue: 1.0))
        }
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Color(UIColor.separator)),
                 alignment: .top)
    }

    // MARK: - Probability Section (expanded)

    private var probabilitySection: some View {
        VStack(spacing: 4) {
            // Title
            Text("Match Projections")
                .font(.system(size: 13).italic())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

            // Chart
            ProbabilityLineChartView(match: match, tournament: tournament)

            // BLUE / TIE / RED probability rows
            probabilityRows

            // Attribution
            HStack(spacing: 0) {
                Spacer()
                Text("POWERED BY ")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                Text("MontyRatings AI")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 12)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Color(UIColor.separator)),
                 alignment: .top)
    }

    private var probabilityRows: some View {
        let (blueP, redP, tieP) = currentProbability
        return VStack(spacing: 0) {
            probRow(label: "BLUE", pct: blueP, color: .blueTeam)
            Divider().padding(.horizontal, 4)
            probRow(label: "TIE",  pct: tieP,  color: Color(UIColor.secondaryLabel))
            Divider().padding(.horizontal, 4)
            probRow(label: "RED",  pct: redP,  color: .redTeam)
        }
    }

    private func probRow(label: String, pct: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
            Spacer()
            Text(String(format: "%.1f%%", pct * 100))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 4)
    }

    // Current probability for the labels
    private var currentProbability: (blue: Double, red: Double, tie: Double) {
        if match.isCompleted {
            switch matchScore.teamLeading {
            case .blue: return (1.0, 0.0, 0.0)
            case .red:  return (0.0, 1.0, 0.0)
            default:    return (0.0, 0.0, 1.0)
            }
        }
        let course = tournament?.course(named: match.courseName)
        let p = tournament?.matchProbability(match: match, course: course)
        return p ?? (0.333, 0.333, 0.334)
    }
}

// MARK: - Probability Line Chart

private struct ProbabilityLineChartView: View {
    let match: Match
    let tournament: Tournament?

    private var chartData: [(hole: Int, blue: Double, red: Double, tie: Double)] {
        tournament?.matchWinProbabilityHistory(match: match) ?? []
    }

    var body: some View {
        let startHole = match.startingHole
        let endHole   = match.finalHole
        let xDomain   = startHole...(endHole + 1)

        Chart {
            ForEach(chartData, id: \.hole) { pt in
                LineMark(
                    x: .value("Hole", pt.hole),
                    y: .value("Prob",  pt.blue * 100),
                    series: .value("Team", "Blue")
                )
                .foregroundStyle(Color.blueTeam)
                .interpolationMethod(.linear)
                .symbol(Circle().strokeBorder(lineWidth: 1))
                .symbolSize(24)
            }
            ForEach(chartData, id: \.hole) { pt in
                LineMark(
                    x: .value("Hole", pt.hole),
                    y: .value("Prob",  pt.red * 100),
                    series: .value("Team", "Red")
                )
                .foregroundStyle(Color.redTeam)
                .interpolationMethod(.linear)
                .symbol(Circle().strokeBorder(lineWidth: 1))
                .symbolSize(24)
            }
            ForEach(chartData, id: \.hole) { pt in
                LineMark(
                    x: .value("Hole", pt.hole),
                    y: .value("Prob",  pt.tie * 100),
                    series: .value("Team", "Tie")
                )
                .foregroundStyle(Color.gray)
                .interpolationMethod(.linear)
                .symbol(Circle().strokeBorder(lineWidth: 1))
                .symbolSize(24)
            }
        }
        .chartLegend(.hidden)
        .chartXScale(domain: xDomain)
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: Array(startHole...(endHole + 1))) { value in
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text("\(v)").font(.system(size: 9))
                    }
                }
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                if let v = value.as(Int.self) {
                    if v == 25 || v == 75 {
                        AxisGridLine(stroke: StrokeStyle(dash: [4, 4]))
                    } else {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
            }
        }
        .frame(height: 109)
    }
}

// MARK: - Player display name helper

private extension Player {
    var displayName: String {
        let parts = name.split(separator: " ")
        guard parts.count >= 2 else { return name }
        return "\(parts[0]) \(parts[parts.count - 1])"
    }
}
