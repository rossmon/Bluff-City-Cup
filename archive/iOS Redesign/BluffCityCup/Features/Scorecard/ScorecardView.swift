import SwiftUI
import UIKit

struct ScorecardView: View {
    @StateObject private var vm: ScorecardViewModel

    init(match: Match, tournament: Tournament) {
        _vm = StateObject(wrappedValue: ScorecardViewModel(match: match, tournament: tournament))
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                playerHeaderSection
                controlsBar
                VStack(spacing: 0) {
                    nineSection(holes: vm.frontHoles, sectionLabel: "OUT")
                    if vm.showBothNines {
                        nineSection(holes: vm.backHoles, sectionLabel: "IN")
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 6)
            }
        }
        .background(Color(red: 239/255, green: 240/255, blue: 244/255))
    }

    // MARK: - Player VS Header

    private var playerHeaderSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                // Blue team players
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        ForEach(vm.match.bluePlayers) { player in
                            playerAvatar(player: player)
                        }
                    }
                    ForEach(vm.match.bluePlayers) { player in
                        Text(vm.playerHeaderName(player))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // VS + score center
                VStack(spacing: 2) {
                    Text("VS")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.primary)
                    Text(vm.matchScoreDisplay)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(scoreColor)
                }
                .frame(minWidth: 80)

                // Red team players
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        ForEach(vm.match.redPlayers) { player in
                            playerAvatar(player: player)
                        }
                    }
                    ForEach(vm.match.redPlayers) { player in
                        Text(vm.playerHeaderName(player))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 30)
            .background(Color(.systemBackground))
        }
    }

    private func playerAvatar(player: Player) -> some View {
        PlayerAvatarImage(url: vm.playerImageURL(player), player: player)
        .frame(width: 52, height: 52)
        .clipped()
    }

    private var scoreColor: Color {
        switch vm.matchScoreLeader {
        case .blue: return .blueTeam
        case .red:  return .redTeam
        default:    return .primary
        }
    }

    // MARK: - Controls Bar (match info + picker)

    private var controlsBar: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "Round %d, Match %d (%.1f pts)", vm.match.round, vm.match.matchNumber, vm.match.points))
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(UIColor.darkGray))
                Text("\(vm.match.courseName) - \(vm.match.format.rawValue)")
                    .font(.caption2)
                    .foregroundStyle(Color(UIColor.darkGray))
            }
            Spacer()
            Picker("Display", selection: $vm.displayMode) {
                ForEach(ScorecardDisplayMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 120)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    // MARK: - Nine-hole section grid

    private func nineSection(holes: [Hole], sectionLabel: String) -> some View {
        GeometryReader { geo in
            let availW = geo.size.width
            let labelW: CGFloat = 54
            let totalW: CGFloat = 34
            let separatorW = CGFloat(holes.count) * 0.5
            let cellW = floor((availW - labelW - totalW - separatorW) / CGFloat(max(holes.count, 1)))

            VStack(spacing: 0) {
                // HOLE header row
                gridRow(
                    label: "HOLE",
                    cells: holes.map { AnyView(headerCell("\($0.number)")) },
                    total: AnyView(headerCell(sectionLabel)),
                    labelW: labelW, cellW: cellW, totalW: totalW,
                    isHeader: true
                )
                // HDCP row
                gridRow(
                    label: "HDCP",
                    cells: holes.map { AnyView(headerCell("\($0.handicapIndex)")) },
                    total: AnyView(headerCell("")),
                    labelW: labelW, cellW: cellW, totalW: totalW,
                    isHeader: true
                )
                // PAR row
                gridRow(
                    label: "PAR",
                    cells: holes.map { AnyView(headerCell("\($0.par)")) },
                    total: AnyView(headerCell("\(holes.reduce(0) { $0 + $1.par })")),
                    labelW: labelW, cellW: cellW, totalW: totalW,
                    isHeader: true
                )
                // Player rows
                ForEach(vm.displayRows, id: \.label) { row in
                    if let player = row.player {
                        let teamColor = Color.teamColor(row.team)
                        let total = vm.holeTotalFor(player: player, holes: holes)
                        gridRow(
                            label: row.label,
                            cells: holes.map { hole in
                                AnyView(scoreCellView(player: player, hole: hole, teamColor: teamColor))
                            },
                            total: AnyView(
                                Text(total > 0 ? "\(total)" : "")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Color(UIColor.darkGray))
                            ),
                            labelW: labelW, cellW: cellW, totalW: totalW,
                            isHeader: false,
                            labelColor: teamColor
                        )
                    }
                }
            }
        }
        .frame(height: CGFloat(3 + vm.displayRows.count) * rowHeight)
        .background(Color(.systemBackground))
    }

    private let rowHeight: CGFloat = 26

    // MARK: - Header cell

    private func headerCell(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold).italic())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grid row

    private func gridRow(label: String, cells: [AnyView], total: AnyView,
                          labelW: CGFloat, cellW: CGFloat, totalW: CGFloat,
                          isHeader: Bool, labelColor: Color = .white) -> some View {
        HStack(spacing: 0) {
            // Label
            Text(label)
                .font(isHeader
                      ? .system(size: 13, weight: .bold).italic()
                      : .system(size: 13, weight: .regular))
                .foregroundStyle(isHeader ? .white : Color(UIColor.darkGray))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.leading, 4)
                .frame(width: labelW, height: rowHeight, alignment: .leading)
                .background(isHeader ? Color.blueTeam : Color(.systemBackground))

            // Cells
            ForEach(0..<cells.count, id: \.self) { i in
                cells[i]
                    .frame(width: cellW, height: rowHeight)
                    .background(isHeader ? Color.blueTeam : Color(.systemBackground))
                Rectangle()
                    .fill(Color(.separator).opacity(isHeader ? 0 : 0.2))
                    .frame(width: 0.5, height: rowHeight)
            }

            // Total
            total
                .frame(width: totalW, height: rowHeight)
                .background(isHeader ? Color.blueTeam : Color(.systemBackground))
        }
        .overlay(
            Rectangle()
                .fill(Color(.separator).opacity(isHeader ? 0 : 0.2))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }

    // MARK: - Score cell

    @ViewBuilder
    private func scoreCellView(player: Player, hole: Hole, teamColor: Color) -> some View {
        if let value = vm.displayValue(player: player, hole: hole) {
            if vm.displayMode == .score {
                let annotation = vm.scoreAnnotation(gross: value, par: hole.par)
                scoreCell(
                    value: value,
                    annotation: annotation,
                    teamColor: teamColor,
                    wonHole: vm.holeWinner(for: hole) == player.team
                )
            } else {
                Text("\(value)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(UIColor.darkGray))
            }
        } else {
            Text("")
                .font(.system(size: 13))
        }
    }

    @ViewBuilder
    private func scoreCell(value: Int, annotation: ScoreAnnotation, teamColor: Color, wonHole: Bool) -> some View {
        let text = Text("\(value)").font(.system(size: 13, weight: .regular))
        if wonHole || annotation == .birdie || annotation == .eagle {
            text
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(teamColor, in: Circle())
        } else {
            text.foregroundStyle(Color(UIColor.darkGray))
        }
    }
}

private struct PlayerAvatarImage: View {
    let url: URL?
    let player: Player
    @StateObject private var loader = PlayerAvatarLoader()

    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.teamColor(player.team)
                Text(player.name.first.map(String.init) ?? "?")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .task(id: url) {
            await loader.load(url: url)
        }
    }
}

@MainActor
private final class PlayerAvatarLoader: ObservableObject {
    @Published var image: UIImage?
    private var loadedURL: URL?
    private static let cache = NSCache<NSURL, UIImage>()

    func load(url: URL?) async {
        guard let url else {
            image = nil
            loadedURL = nil
            return
        }

        if loadedURL == url, image != nil { return }
        if let cached = Self.cache.object(forKey: url as NSURL) {
            image = cached
            loadedURL = url
            return
        }

        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let loaded = UIImage(data: data) else { return }
            Self.cache.setObject(loaded, forKey: url as NSURL)
            image = loaded
            loadedURL = url
        } catch {
            image = nil
            loadedURL = nil
        }
    }
}
