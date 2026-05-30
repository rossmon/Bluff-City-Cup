//
//  RecordsViewController.swift
//  Bluff City Cup
//

import UIKit

@objc
protocol RecordsViewControllerDelegate: AnyObject {
    @objc optional func toggleTopPanelRecords()
    @objc optional func collapseTopPanelRecords()
    @objc optional func changeViewRecords(_ menu: String, scorecardMatch: Match?)
}

final class RecordsViewController: UITableViewController {
    enum Section: Int {
        case overview
        case profiles
        case teamFormat
        case course
        case headToHead
        case players
        case pairings
        case singles
        case matches
        case website

        static let all: [Section] = [.overview, .profiles, .teamFormat, .headToHead, .players, .pairings, .singles, .matches, .website]

        var title: String {
            switch self {
            case .overview: return "Overview"
            case .profiles: return "Player Profiles"
            case .teamFormat: return "Team and Format Records"
            case .course: return "Course Records"
            case .headToHead: return "Head-to-Head"
            case .players: return "Player Records"
            case .pairings: return "2-Man Pairings"
            case .singles: return "Singles Records"
            case .matches: return "All Match Outcomes"
            case .website: return "Detailed Records"
            }
        }
    }

    weak var delegate: RecordsViewControllerDelegate?
    let viewModel = RecordsViewModel()

    private var expanded: [Section: Bool] = [:]
    private var selectedYears = Set<String>()
    private var selectedFormats = Set<String>()
    private var selectedPlayers = Set<String>()
    private var playerTeam = "All"
    private var pairTeam = "All"
    private var singlesTeam = "All"
    private var matchTeam = "All"
    private var matchPlayer = "All"
    private var playerMinMatches = 0
    private var pairMinMatches = 0
    private var singlesMinMatches = 0
    private var playerSort: RecordsRankSort = .winPercent
    private var pairSort: RecordsRankSort = .winPercent
    private var singlesSort: RecordsRankSort = .winPercent
    private var pairIncludeFormat = false
    private var isLoading = false
    private var loadError: String?
    private let heroHeader = RecordsHeroHeaderView()
    private let backgroundGradient = CAGradientLayer()

    private let blue = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
    private let red = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1)
    private let surface = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Records"
        tableView.backgroundColor = surface
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 24, right: 0)
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(RecordsDashboardCell.self, forCellReuseIdentifier: "RecordsDashboardCell")
        tableView.register(RecordsPointsChartCell.self, forCellReuseIdentifier: "RecordsPointsChartCell")
        tableView.register(RecordsProfileGridCell.self, forCellReuseIdentifier: "RecordsProfileGridCell")
        tableView.register(RecordsComparisonCardCell.self, forCellReuseIdentifier: "RecordsComparisonCardCell")
        tableView.register(RecordsRankCardCell.self, forCellReuseIdentifier: "RecordsRankCardCell")
        tableView.register(RecordsMatchCardCell.self, forCellReuseIdentifier: "RecordsMatchCardCell")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(menuTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))

        configureNavigationStyle()
        configureHeroHeader()
        Section.all.forEach { expanded[$0] = $0 == .overview || $0 == .profiles || $0 == .teamFormat || $0 == .website }
        loadRecords(forceRefresh: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = tableView.bounds
        resizeHeroHeader()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func configureNavigationStyle() {
        navigationController?.navigationBar.barTintColor = blue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false
    }

    private func configureHeroHeader() {
        backgroundGradient.colors = [
            UIColor(red: 0.98, green: 0.99, blue: 1.0, alpha: 1).cgColor,
            surface.cgColor
        ]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1)
        tableView.backgroundView = UIView()
        tableView.backgroundView?.layer.insertSublayer(backgroundGradient, at: 0)

        heroHeader.configure(rowCountText: "Dynamic records from the website API")
        tableView.tableHeaderView = heroHeader
        resizeHeroHeader()
    }

    private func resizeHeroHeader() {
        guard tableView.tableHeaderView === heroHeader else { return }
        let width = tableView.bounds.width
        guard width > 0 else { return }
        let targetSize = heroHeader.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                                                            withHorizontalFittingPriority: .required,
                                                            verticalFittingPriority: .fittingSizeLevel)
        if abs(heroHeader.frame.height - targetSize.height) > 0.5 || abs(heroHeader.frame.width - width) > 0.5 {
            heroHeader.frame = CGRect(x: 0, y: 0, width: width, height: targetSize.height)
            tableView.tableHeaderView = heroHeader
        }
    }

    @objc private func menuTapped() {
        delegate?.toggleTopPanelRecords?()
    }

    @objc private func refreshTapped() {
        loadRecords(forceRefresh: true)
    }

    private func loadRecords(forceRefresh: Bool) {
        isLoading = true
        loadError = nil
        tableView.reloadData()

        viewModel.load(forceRefresh: forceRefresh) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.loadError = error?.localizedDescription
            self.heroHeader.configure(rowCountText: self.viewModel.loadedSummary)
            self.resizeHeroHeader()
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recordsSection = recordsSection(at: section), expanded[recordsSection] == true else { return 0 }
        if isLoading || loadError != nil || viewModel.payload == nil {
            return recordsSection == .overview ? 1 : 0
        }

        switch recordsSection {
        case .overview:
            return 1
        case .profiles:
            return 1
        case .teamFormat:
            return min(18, viewModel.teamFormatRows(years: selectedYears).count + 1)
        case .course:
            return min(14, viewModel.courseRows(years: selectedYears).count + 1)
        case .headToHead:
            return 1
        case .players:
            return min(25, viewModel.playerRows(team: playerTeam, years: selectedYears, formats: selectedFormats, players: selectedPlayers, minMatches: playerMinMatches, sort: playerSort).count + 1)
        case .pairings:
            return min(25, viewModel.pairingRows(team: pairTeam, years: selectedYears, formats: selectedFormats, players: selectedPlayers, minMatches: pairMinMatches, includeFormat: pairIncludeFormat, sort: pairSort).count + 1)
        case .singles:
            return min(25, viewModel.singlesRows(team: singlesTeam, minMatches: singlesMinMatches, sort: singlesSort).count + 1)
        case .matches:
            return min(40, viewModel.matchOutcomeRows(team: matchTeam, years: selectedYears, formats: selectedFormats, player: matchPlayer).count + 1)
        case .website:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let recordsSection = recordsSection(at: section) else { return nil }
        let header = RecordsSectionHeaderView()
        header.configure(title: recordsSection.title, isExpanded: expanded[recordsSection] == true, tag: section)
        header.addTarget(self, action: #selector(sectionTapped(_:)), for: .touchUpInside)
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }

    @objc private func sectionTapped(_ sender: UIControl) {
        guard let section = recordsSection(at: sender.tag) else { return }
        expanded[section] = !(expanded[section] ?? false)
        tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = recordsSection(at: indexPath.section) else { return UITableViewCell() }
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsDashboardCell", for: indexPath) as! RecordsDashboardCell
            cell.configure(title: "Loading Bluff City Cup records...", detail: "Pulling live website data from the records API.", accent: blue)
            return cell
        }
        if let error = loadError {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsDashboardCell", for: indexPath) as! RecordsDashboardCell
            cell.configure(title: "Records unavailable", detail: error, accent: red)
            return cell
        }

        switch section {
        case .overview:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsPointsChartCell", for: indexPath) as! RecordsPointsChartCell
            cell.configure(title: "Points by Team by Year", totals: viewModel.yearlyPointTotals())
            return cell
        case .profiles:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsProfileGridCell", for: indexPath) as! RecordsProfileGridCell
            let pools = viewModel.headToHeadPlayerPools()
            let redPlayers = pools.red.prefix(9).map { ($0.team, viewModel.displayName(for: $0), viewModel.absolutePictureURL($0)) }
            let bluePlayers = pools.blue.prefix(9).map { ($0.team, viewModel.displayName(for: $0), viewModel.absolutePictureURL($0)) }
            cell.configure(redPlayers: Array(redPlayers), bluePlayers: Array(bluePlayers)) { [weak self] team, name in
                guard let self = self else { return }
                let profile = self.viewModel.playerProfile(name: name, team: team)
                self.navigationController?.pushViewController(RecordsPlayerProfileViewController(profile: profile), animated: true)
            }
            return cell
        case .teamFormat:
            return comparisonCell(indexPath: indexPath, rows: viewModel.teamFormatRows(years: selectedYears), filterText: yearsFilterText())
        case .course:
            return comparisonCell(indexPath: indexPath, rows: viewModel.courseRows(years: selectedYears), filterText: yearsFilterText())
        case .headToHead:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsDashboardCell", for: indexPath) as! RecordsDashboardCell
            cell.configure(title: "Open Head-to-Head Compare",
                           detail: "Select one Red player and one Blue player. Includes all formats, including partnered matches.",
                           accent: blue)
            cell.showsChevron = true
            return cell
        case .players:
            return rankCell(indexPath: indexPath, rows: viewModel.playerRows(team: playerTeam, years: selectedYears, formats: selectedFormats, players: selectedPlayers, minMatches: playerMinMatches, sort: playerSort), filterText: playerFilterText())
        case .pairings:
            return rankCell(indexPath: indexPath, rows: viewModel.pairingRows(team: pairTeam, years: selectedYears, formats: selectedFormats, players: selectedPlayers, minMatches: pairMinMatches, includeFormat: pairIncludeFormat, sort: pairSort), filterText: pairFilterText())
        case .singles:
            return rankCell(indexPath: indexPath, rows: viewModel.singlesRows(team: singlesTeam, minMatches: singlesMinMatches, sort: singlesSort), filterText: singlesFilterText())
        case .matches:
            return matchCell(indexPath: indexPath)
        case .website:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsDashboardCell", for: indexPath) as! RecordsDashboardCell
            cell.configure(title: "Open Detailed Records Website",
                           detail: "View the complete Bluff City Cup records page.",
                           accent: blue)
            cell.showsChevron = true
            return cell
        }
    }

    private func comparisonCell(indexPath: IndexPath, rows: [RecordsComparisonRow], filterText: String) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsDashboardCell", for: indexPath) as! RecordsDashboardCell
            cell.configure(title: "Filters", detail: filterText, accent: blue)
            cell.showsChevron = true
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsComparisonCardCell", for: indexPath) as! RecordsComparisonCardCell
        let item = rows[indexPath.row - 1]
        cell.configure(row: item)
        return cell
    }

    private func rankCell(indexPath: IndexPath, rows: [RecordsRankRow], filterText: String) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsDashboardCell", for: indexPath) as! RecordsDashboardCell
            cell.configure(title: "Filters and Sorting", detail: filterText, accent: blue)
            cell.showsChevron = true
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsRankCardCell", for: indexPath) as! RecordsRankCardCell
        let item = rows[indexPath.row - 1]
        cell.configure(row: item)
        cell.accessoryType = .none
        return cell
    }

    private func matchCell(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsDashboardCell", for: indexPath) as! RecordsDashboardCell
            cell.configure(title: "Filters", detail: matchFilterText(), accent: blue)
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        let rows = viewModel.matchOutcomeRows(team: matchTeam, years: selectedYears, formats: selectedFormats, player: matchPlayer)
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsMatchCardCell", for: indexPath) as! RecordsMatchCardCell
        cell.configure(row: rows[indexPath.row - 1], viewModel: viewModel)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    private func configureBaseCell(_ cell: UITableViewCell) {
        cell.selectionStyle = .default
        cell.backgroundColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cell.textLabel?.textColor = UIColor(red: 0.08, green: 0.13, blue: 0.23, alpha: 1)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        cell.detailTextLabel?.textColor = UIColor(red: 0.35, green: 0.40, blue: 0.50, alpha: 1)
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .none
        cell.imageView?.image = nil
    }

    private func configureOverviewCell(_ cell: UITableViewCell, row: Int) {
        if row == 0 {
            cell.textLabel?.text = "Bluff City Cup Records"
            cell.detailTextLabel?.text = viewModel.loadedSummary
            return
        }

        let rows = viewModel.teamYearPointsRows()
        let index = row - 1
        cell.textLabel?.text = index < rows.count ? rows[index] : "Records source"
        cell.detailTextLabel?.text = index < rows.count ? "Points by team by year" : "https://glizzyattheturn.app/bluffcitycup/api.php"
    }

    private func configureComparisonCell(_ cell: UITableViewCell, row: Int, rows: [RecordsComparisonRow], filterText: String) {
        if row == 0 {
            cell.textLabel?.text = "Filters"
            cell.detailTextLabel?.text = filterText
            cell.accessoryType = .disclosureIndicator
            return
        }

        let item = rows[row - 1]
        cell.textLabel?.text = item.label
        cell.detailTextLabel?.text = "Red \(item.red.wlt) \(item.red.winPctText)  |  Blue \(item.blue.wlt) \(item.blue.winPctText)"
    }

    private func configureRankCell(_ cell: UITableViewCell, row: Int, rows: [RecordsRankRow], filterText: String) {
        if row == 0 {
            cell.textLabel?.text = "Filters and Sorting"
            cell.detailTextLabel?.text = filterText
            cell.accessoryType = .disclosureIndicator
            return
        }

        let item = rows[row - 1]
        let format = item.format.isEmpty ? "" : " - \(item.format)"
        cell.textLabel?.text = "\(item.rank). \(item.title)\(format)"
        cell.detailTextLabel?.text = "\(item.team) - \(item.stats.matches) matches, \(item.stats.wlt), \(RecordsFormatters.points(item.stats.points)) pts, \(item.stats.winPctText)"
        if !item.team.isEmpty {
            cell.imageView?.image = UIImage(systemName: "circle.fill")
            cell.imageView?.tintColor = color(for: item.team)
        }
        cell.accessoryType = .none
    }

    private func configureMatchCell(_ cell: UITableViewCell, row: Int) {
        if row == 0 {
            cell.textLabel?.text = "Filters"
            cell.detailTextLabel?.text = matchFilterText()
            cell.accessoryType = .disclosureIndicator
            return
        }

        let rows = viewModel.matchOutcomeRows(team: matchTeam, years: selectedYears, formats: selectedFormats, player: matchPlayer)
        let item = rows[row - 1]
        cell.textLabel?.text = "\(item.year) \(item.format): \(item.winner) \(item.score)"
        cell.detailTextLabel?.text = "Red \(item.redPlayers.map(viewModel.playerLastName).joined(separator: ", ")) vs Blue \(item.bluePlayers.map(viewModel.playerLastName).joined(separator: ", "))\(item.course.isEmpty ? "" : " - \(item.course)")"
        cell.accessoryType = .disclosureIndicator
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = recordsSection(at: indexPath.section), !isLoading, viewModel.payload != nil else { return }

        switch section {
        case .profiles:
            return
        case .teamFormat, .course:
            if indexPath.row == 0 { showYearPicker() }
        case .headToHead:
            navigationController?.pushViewController(RecordsHeadToHeadViewController(viewModel: viewModel), animated: true)
        case .players:
            if indexPath.row == 0 { showPlayerFilters() }
            else {
                let row = viewModel.playerRows(team: playerTeam, years: selectedYears, formats: selectedFormats, players: selectedPlayers, minMatches: playerMinMatches, sort: playerSort)[indexPath.row - 1]
                navigationController?.pushViewController(RecordsPlayerProfileViewController(profile: viewModel.playerProfile(name: row.title, team: row.team)), animated: true)
            }
        case .pairings:
            if indexPath.row == 0 { showPairFilters() }
        case .singles:
            if indexPath.row == 0 { showSinglesFilters() }
            else {
                let row = viewModel.singlesRows(team: singlesTeam, minMatches: singlesMinMatches, sort: singlesSort)[indexPath.row - 1]
                navigationController?.pushViewController(RecordsPlayerProfileViewController(profile: viewModel.playerProfile(name: row.title, team: row.team)), animated: true)
            }
        case .matches:
            if indexPath.row == 0 { showMatchFilters() }
            else {
                let item = viewModel.matchOutcomeRows(team: matchTeam, years: selectedYears, formats: selectedFormats, player: matchPlayer)[indexPath.row - 1]
                showMatchDetail(item)
            }
        case .website:
            if let url = URL(string: "https://glizzyattheturn.app/bluffcitycup/index.php") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .overview:
            break
        }
    }

    private func recordsSection(at index: Int) -> Section? {
        guard index >= 0 && index < Section.all.count else { return nil }
        return Section.all[index]
    }

    private func profilePictures() -> [RecordsPlayerPicture] {
        let pools = viewModel.headToHeadPlayerPools()
        return Array((pools.red + pools.blue).prefix(18))
    }

    private func showYearPicker() {
        showMultiPicker(title: "Years", options: viewModel.years, selected: selectedYears) { [weak self] selection in
            self?.selectedYears = selection
            self?.tableView.reloadData()
        }
    }

    private func showPlayerFilters() {
        let alert = filterAlert(title: "Player Records Filters")
        alert.addAction(UIAlertAction(title: "Team: \(playerTeam)", style: .default) { _ in self.showTeamPicker(current: self.playerTeam) { self.playerTeam = $0 } })
        alert.addAction(UIAlertAction(title: "Sort: \(playerSort.title)", style: .default) { _ in self.showRankSortPicker(current: self.playerSort) { self.playerSort = $0 } })
        alert.addAction(UIAlertAction(title: yearsFilterText(), style: .default) { _ in self.showYearPicker() })
        alert.addAction(UIAlertAction(title: formatsFilterText(), style: .default) { _ in self.showFormatPicker() })
        alert.addAction(UIAlertAction(title: playersFilterText(), style: .default) { _ in self.showPlayersPicker() })
        alert.addAction(UIAlertAction(title: "Min Matches: \(playerMinMatches)", style: .default) { _ in self.showMinMatchesPicker(current: self.playerMinMatches) { self.playerMinMatches = $0 } })
        present(alert, animated: true)
    }

    private func showPairFilters() {
        let alert = filterAlert(title: "Pairing Filters")
        alert.addAction(UIAlertAction(title: "Team: \(pairTeam)", style: .default) { _ in self.showTeamPicker(current: self.pairTeam) { self.pairTeam = $0 } })
        alert.addAction(UIAlertAction(title: "Sort: \(pairSort.title)", style: .default) { _ in self.showRankSortPicker(current: self.pairSort) { self.pairSort = $0 } })
        alert.addAction(UIAlertAction(title: yearsFilterText(), style: .default) { _ in self.showYearPicker() })
        alert.addAction(UIAlertAction(title: pairFormatsFilterText(), style: .default) { _ in self.showPairFormatPicker() })
        alert.addAction(UIAlertAction(title: playersFilterText(), style: .default) { _ in self.showPlayersPicker() })
        alert.addAction(UIAlertAction(title: "Min Matches: \(pairMinMatches)", style: .default) { _ in self.showMinMatchesPicker(current: self.pairMinMatches) { self.pairMinMatches = $0 } })
        alert.addAction(UIAlertAction(title: pairIncludeFormat ? "Hide Format Breakdown" : "Include Format Breakdown", style: .default) { _ in
            self.pairIncludeFormat = !self.pairIncludeFormat
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }

    private func showSinglesFilters() {
        let alert = filterAlert(title: "Singles Filters")
        alert.addAction(UIAlertAction(title: "Team: \(singlesTeam)", style: .default) { _ in self.showTeamPicker(current: self.singlesTeam) { self.singlesTeam = $0 } })
        alert.addAction(UIAlertAction(title: "Sort: \(singlesSort.title)", style: .default) { _ in self.showRankSortPicker(current: self.singlesSort) { self.singlesSort = $0 } })
        alert.addAction(UIAlertAction(title: "Min Matches: \(singlesMinMatches)", style: .default) { _ in self.showMinMatchesPicker(current: self.singlesMinMatches) { self.singlesMinMatches = $0 } })
        present(alert, animated: true)
    }

    private func showMatchFilters() {
        let alert = filterAlert(title: "Match Filters")
        alert.addAction(UIAlertAction(title: "Team/Winner: \(matchTeam)", style: .default) { _ in self.showTeamPicker(current: self.matchTeam) { self.matchTeam = $0 } })
        alert.addAction(UIAlertAction(title: yearsFilterText(), style: .default) { _ in self.showYearPicker() })
        alert.addAction(UIAlertAction(title: formatsFilterText(), style: .default) { _ in self.showFormatPicker() })
        alert.addAction(UIAlertAction(title: "Player: \(matchPlayer)", style: .default) { _ in self.showSinglePicker(title: "Player", options: ["All"] + self.viewModel.players, current: self.matchPlayer) { self.matchPlayer = $0 } })
        present(alert, animated: true)
    }

    private func filterAlert(title: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }

    private func showTeamPicker(current: String, completion: @escaping (String) -> Void) {
        showSinglePicker(title: "Team", options: ["All", "Red", "Blue"], current: current) { value in
            completion(value)
            self.tableView.reloadData()
        }
    }

    private func showFormatPicker() {
        showMultiPicker(title: "Formats", options: viewModel.formats, selected: selectedFormats) { [weak self] selection in
            self?.selectedFormats = selection
            self?.tableView.reloadData()
        }
    }

    private func showPairFormatPicker() {
        let options = pairFormatOptions()
        showMultiPicker(title: "Pairing Formats", options: options, selected: selectedFormats.intersection(Set(options))) { [weak self] selection in
            self?.selectedFormats = selection
            self?.tableView.reloadData()
        }
    }

    private func showPlayersPicker() {
        showMultiPicker(title: "Players", options: viewModel.players, selected: selectedPlayers) { [weak self] selection in
            self?.selectedPlayers = selection
            self?.tableView.reloadData()
        }
    }

    private func showSinglePicker(title: String, options: [String], current: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for option in options {
            alert.addAction(UIAlertAction(title: option == current ? "✓ \(option)" : option, style: .default) { _ in completion(option) })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showMultiPicker(title: String, options: [String], selected: Set<String>, completion: @escaping (Set<String>) -> Void) {
        let controller = RecordsOptionListViewController(title: title, options: options, selected: selected, completion: completion)
        navigationController?.pushViewController(controller, animated: true)
    }

    private func showRankSortPicker(current: RecordsRankSort, completion: @escaping (RecordsRankSort) -> Void) {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        let options: [RecordsRankSort] = [.winPercent, .points, .matches, .name]
        for option in options {
            let title = option.rawValue == current.rawValue ? "✓ \(option.title)" : option.title
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                completion(option)
                self.tableView.reloadData()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showMinMatchesPicker(current: Int, completion: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: "Minimum Matches", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.text = String(current)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Apply", style: .default) { _ in
            completion(Int(alert.textFields?.first?.text ?? "0") ?? 0)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }

    private func showMatchDetail(_ match: RecordsMatchOutcomeRow) {
        let title = "\(match.year) \(match.format)"
        let course = match.course.isEmpty ? "" : "\nCourse: \(match.course) \(match.tees)"
        let players = "\nRed: \(match.redPlayers.joined(separator: ", "))\nBlue: \(match.bluePlayers.joined(separator: ", "))"
        let summary = match.summary.isEmpty ? "" : "\n\n\(match.summary)"
        let alert = UIAlertController(title: title, message: "\(match.winner) \(match.score)\(course)\(players)\(summary)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }

    private func yearsFilterText() -> String {
        return "Years: " + (selectedYears.isEmpty ? "All" : selectedYears.sorted().joined(separator: ", "))
    }

    private func formatsFilterText() -> String {
        return "Formats: " + (selectedFormats.isEmpty ? "All" : selectedFormats.sorted().joined(separator: ", "))
    }

    private func pairFormatsFilterText() -> String {
        let pairFormats = selectedFormats.intersection(Set(pairFormatOptions()))
        return "Formats: " + (pairFormats.isEmpty ? "All" : pairFormats.sorted().joined(separator: ", "))
    }

    private func pairFormatOptions() -> [String] {
        let allowed = Set(["Best Ball", "Mod. Alt. Shot", "2-Man Scramble", "Shamble"])
        return viewModel.formats.filter { allowed.contains($0) }
    }

    private func playersFilterText() -> String {
        return "Players: " + (selectedPlayers.isEmpty ? "All" : selectedPlayers.sorted().joined(separator: ", "))
    }

    private func playerFilterText() -> String {
        return "Team: \(playerTeam), Sort: \(playerSort.title), \(yearsFilterText()), \(formatsFilterText()), \(playersFilterText()), Min: \(playerMinMatches)"
    }

    private func pairFilterText() -> String {
        return "Team: \(pairTeam), Sort: \(pairSort.title), \(yearsFilterText()), \(pairFormatsFilterText()), \(playersFilterText()), Min: \(pairMinMatches), Format detail: \(pairIncludeFormat ? "On" : "Off")"
    }

    private func singlesFilterText() -> String {
        return "Team: \(singlesTeam), Sort: \(singlesSort.title), Min: \(singlesMinMatches)"
    }

    private func matchFilterText() -> String {
        return "Team: \(matchTeam), \(yearsFilterText()), \(formatsFilterText()), Player: \(matchPlayer)"
    }

    private func color(for team: String) -> UIColor {
        return team.bccNormalized == "Red" ? red : blue
    }
}

extension RecordsViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        delegate?.collapseTopPanelRecords?()
        delegate?.changeViewRecords?(menu, scorecardMatch: scorecardMatch)
    }
}

final class RecordsOptionListViewController: UITableViewController {
    private let options: [String]
    private var selected: Set<String>
    private let completion: (Set<String>) -> Void

    init(title: String, options: [String], selected: Set<String>, completion: @escaping (Set<String>) -> Void) {
        self.options = options
        self.selected = selected
        self.completion = completion
        super.init(style: .plain)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(allTapped))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") ?? UITableViewCell(style: .default, reuseIdentifier: "OptionCell")
        let option = options[indexPath.row]
        cell.textLabel?.text = option
        cell.accessoryType = selected.contains(option) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    @objc private func allTapped() {
        selected.removeAll()
        tableView.reloadData()
    }

    @objc private func doneTapped() {
        completion(selected)
        navigationController?.popViewController(animated: true)
    }
}

final class RecordsPlayerProfileViewController: UITableViewController {
    private enum ProfileTableSort {
        case name
        case matches
        case record
        case points
        case winPercent
    }

    private enum Section: Int {
        case hero
        case bio
        case overall
        case format
        case year
        case personal

        static let all: [Section] = [.hero, .bio, .overall, .format, .year, .personal]
    }

    private let profile: RecordsPlayerProfile
    private let navy = UIColor(red: 0.08, green: 0.18, blue: 0.36, alpha: 1)
    private let muted = UIColor(red: 0.34, green: 0.40, blue: 0.52, alpha: 1)
    private var isBioCollapsed = true
    private var formatSort: ProfileTableSort = .matches
    private var formatSortAscending = false
    private var yearSort: ProfileTableSort = .name
    private var yearSortAscending = false

    init(profile: RecordsPlayerProfile) {
        self.profile = profile
        super.init(style: .plain)
        title = profile.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(red: 0.98, green: 0.985, blue: 0.995, alpha: 1)
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        tableView.register(RecordsProfileHeroCell.self, forCellReuseIdentifier: "RecordsProfileHeroCell")
        tableView.register(RecordsProfileBioCell.self, forCellReuseIdentifier: "RecordsProfileBioCell")
        tableView.register(RecordsProfileStatsGridCell.self, forCellReuseIdentifier: "RecordsProfileStatsGridCell")
        tableView.register(RecordsProfileTableCell.self, forCellReuseIdentifier: "RecordsProfileTableCell")
        tableView.register(RecordsProfilePersonalCell.self, forCellReuseIdentifier: "RecordsProfilePersonalCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .hero:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsProfileHeroCell", for: indexPath) as! RecordsProfileHeroCell
            cell.configure(profile: profile)
            return cell
        case .bio:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsProfileBioCell", for: indexPath) as! RecordsProfileBioCell
            cell.configure(bio: profile.bio, isCollapsed: isBioCollapsed) { [weak self] in
                guard let self = self else { return }
                self.isBioCollapsed = !self.isBioCollapsed
                self.tableView.reloadSections(IndexSet(integer: Section.bio.rawValue), with: .automatic)
            }
            return cell
        case .overall:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsProfileStatsGridCell", for: indexPath) as! RecordsProfileStatsGridCell
            cell.configure(profile: profile)
            return cell
        case .format:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsProfileTableCell", for: indexPath) as! RecordsProfileTableCell
            cell.configure(title: "Record by Format",
                           firstColumn: "FORMAT",
                           rows: tableRows(sortedProfileRows(profile.byFormat, sort: formatSort, ascending: formatSortAscending)),
                           sortColumn: tableColumn(for: formatSort),
                           sortAscending: formatSortAscending) { [weak self] column in
                self?.updateSort(column, section: .format)
            }
            return cell
        case .year:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsProfileTableCell", for: indexPath) as! RecordsProfileTableCell
            cell.configure(title: "Record by Year",
                           firstColumn: "YEAR",
                           rows: tableRows(sortedProfileRows(profile.byYear, sort: yearSort, ascending: yearSortAscending)),
                           sortColumn: tableColumn(for: yearSort),
                           sortAscending: yearSortAscending) { [weak self] column in
                self?.updateSort(column, section: .year)
            }
            return cell
        case .personal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsProfilePersonalCell", for: indexPath) as! RecordsProfilePersonalCell
            cell.configure(records: profile.personalRecords.map { ($0.title, $0.value) })
            return cell
        }
    }

    private func tableRows(_ rows: [RecordsRankRow]) -> [RecordsProfileTableRow] {
        if rows.isEmpty {
            return [RecordsProfileTableRow(name: "No records found", matches: "-", record: "-", points: "-", winPercent: "-")]
        }
        return rows.map {
            RecordsProfileTableRow(name: $0.title,
                                   matches: "\($0.stats.matches)",
                                   record: $0.stats.wlt,
                                   points: RecordsFormatters.points($0.stats.points),
                                   winPercent: $0.stats.winPctText)
        }
    }

    private func sortedProfileRows(_ rows: [RecordsRankRow], sort: ProfileTableSort, ascending: Bool) -> [RecordsRankRow] {
        return rows.sorted {
            let orderedAscending: Bool
            switch sort {
            case .name:
                let left = Int($0.title)
                let right = Int($1.title)
                if let left = left, let right = right, left != right {
                    orderedAscending = left < right
                } else {
                    orderedAscending = $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            case .matches:
                if $0.stats.matches != $1.stats.matches {
                    orderedAscending = $0.stats.matches < $1.stats.matches
                } else {
                    orderedAscending = $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            case .record:
                if $0.stats.wins != $1.stats.wins {
                    orderedAscending = $0.stats.wins < $1.stats.wins
                } else if $0.stats.losses != $1.stats.losses {
                    orderedAscending = $0.stats.losses > $1.stats.losses
                } else if $0.stats.ties != $1.stats.ties {
                    orderedAscending = $0.stats.ties < $1.stats.ties
                } else {
                    orderedAscending = $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            case .points:
                if $0.stats.points != $1.stats.points {
                    orderedAscending = $0.stats.points < $1.stats.points
                } else {
                    orderedAscending = $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            case .winPercent:
                if $0.stats.winPctValue != $1.stats.winPctValue {
                    orderedAscending = $0.stats.winPctValue < $1.stats.winPctValue
                } else {
                    orderedAscending = $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            }
            return ascending ? orderedAscending : !orderedAscending
        }
    }

    private func updateSort(_ column: RecordsProfileTableColumn, section: Section) {
        let newSort = profileSort(for: column)
        switch section {
        case .format:
            if formatSort == newSort {
                formatSortAscending.toggle()
            } else {
                formatSort = newSort
                formatSortAscending = newSort == .name
            }
            tableView.reloadSections(IndexSet(integer: Section.format.rawValue), with: .automatic)
        case .year:
            if yearSort == newSort {
                yearSortAscending.toggle()
            } else {
                yearSort = newSort
                yearSortAscending = false
            }
            tableView.reloadSections(IndexSet(integer: Section.year.rawValue), with: .automatic)
        default:
            break
        }
    }

    private func profileSort(for column: RecordsProfileTableColumn) -> ProfileTableSort {
        switch column {
        case .name: return .name
        case .matches: return .matches
        case .record: return .record
        case .points: return .points
        case .winPercent: return .winPercent
        }
    }

    private func tableColumn(for sort: ProfileTableSort) -> RecordsProfileTableColumn {
        switch sort {
        case .name: return .name
        case .matches: return .matches
        case .record: return .record
        case .points: return .points
        case .winPercent: return .winPercent
        }
    }
}

private struct RecordsProfileTableRow {
    let name: String
    let matches: String
    let record: String
    let points: String
    let winPercent: String
}

private enum RecordsProfileTableColumn {
    case name
    case matches
    case record
    case points
    case winPercent
}

private final class RecordsProfileHeroCell: UITableViewCell {
    private let card = UIView()
    private let accent = UIView()
    private let imageViewProfile = UIImageView()
    private let nameLabel = UILabel()
    private let metaStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.96)
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.91, green: 0.83, blue: 0.86, alpha: 1).cgColor
        card.clipsToBounds = true
        contentView.addSubview(card)

        accent.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(accent)

        imageViewProfile.translatesAutoresizingMaskIntoConstraints = false
        imageViewProfile.contentMode = .scaleAspectFill
        imageViewProfile.clipsToBounds = true
        imageViewProfile.layer.cornerRadius = 48
        imageViewProfile.layer.borderWidth = 4
        card.addSubview(imageViewProfile)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 27, weight: .heavy)
        nameLabel.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.36, alpha: 1)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        card.addSubview(nameLabel)

        metaStack.translatesAutoresizingMaskIntoConstraints = false
        metaStack.axis = .horizontal
        metaStack.alignment = .center
        metaStack.distribution = .equalCentering
        metaStack.spacing = 20
        card.addSubview(metaStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22),

            accent.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            accent.topAnchor.constraint(equalTo: card.topAnchor),
            accent.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            accent.widthAnchor.constraint(equalToConstant: 10),

            imageViewProfile.topAnchor.constraint(equalTo: card.topAnchor, constant: 26),
            imageViewProfile.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            imageViewProfile.widthAnchor.constraint(equalToConstant: 96),
            imageViewProfile.heightAnchor.constraint(equalToConstant: 96),

            nameLabel.topAnchor.constraint(equalTo: imageViewProfile.bottomAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            metaStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 14),
            metaStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            metaStack.leadingAnchor.constraint(greaterThanOrEqualTo: card.leadingAnchor, constant: 32),
            metaStack.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -32),
            metaStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -26)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        metaStack.arrangedSubviews.forEach { view in
            metaStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        imageViewProfile.image = nil
    }

    func configure(profile: RecordsPlayerProfile) {
        let color = profile.team == "Red" ? UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1) : UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        accent.backgroundColor = color.withAlphaComponent(0.72)
        imageViewProfile.layer.borderColor = color.withAlphaComponent(0.14).cgColor
        nameLabel.text = profile.name
        imageViewProfile.image = UIImage(systemName: "person.crop.circle")
        imageViewProfile.tintColor = color
        if let url = profile.photoURL {
            imageViewProfile.loadBCCImage(url: url, placeholder: UIImage(systemName: "person.crop.circle"), tint: color)
        }

        metaStack.addArrangedSubview(teamPill(profile.team, color: color))
        metaStack.addArrangedSubview(metaLabel("\(profile.overall.matches) matches"))
        metaStack.addArrangedSubview(metaLabel("\(profile.byYear.count) years"))
    }

    private func teamPill(_ text: String, color: UIColor) -> UILabel {
        let label = metaLabel(text)
        label.textColor = UIColor.white
        label.backgroundColor = color
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        label.textAlignment = .center
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 76).isActive = true
        label.heightAnchor.constraint(equalToConstant: 42).isActive = true
        return label
    }

    private func metaLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.34, green: 0.40, blue: 0.52, alpha: 1)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
}

private final class RecordsProfileBioCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let card = UIView()
    private let bioLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private var toggleHandler: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        setupSectionTitle(titleLabel, text: "Bio")
        contentView.addSubview(titleLabel)
        setupCard(card)
        contentView.addSubview(card)

        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        bioLabel.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.36, alpha: 1)
        bioLabel.numberOfLines = 0
        bioLabel.lineBreakMode = .byWordWrapping
        card.addSubview(bioLabel)

        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        toggleButton.tintColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        toggleButton.contentHorizontalAlignment = .left
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        card.addSubview(toggleButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),

            card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26),

            bioLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            bioLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            bioLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            toggleButton.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 12),
            toggleButton.leadingAnchor.constraint(equalTo: bioLabel.leadingAnchor),
            toggleButton.trailingAnchor.constraint(equalTo: bioLabel.trailingAnchor),
            toggleButton.heightAnchor.constraint(equalToConstant: 32),
            toggleButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    func configure(bio: String, isCollapsed: Bool, toggleHandler: @escaping () -> Void) {
        self.toggleHandler = toggleHandler
        bioLabel.text = bio.isEmpty ? "No bio available." : bio
        bioLabel.numberOfLines = isCollapsed ? 5 : 0
        let title = isCollapsed ? "Show full bio" : "Collapse bio"
        let imageName = isCollapsed ? "chevron.down" : "chevron.up"
        toggleButton.setTitle(title, for: .normal)
        toggleButton.setImage(UIImage(systemName: imageName), for: .normal)
        toggleButton.semanticContentAttribute = .forceRightToLeft
        toggleButton.isHidden = bio.isEmpty
    }

    @objc private func toggleTapped() {
        toggleHandler?()
    }
}

private final class RecordsProfileStatsGridCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stack.arrangedSubviews.forEach { row in
            stack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        setupSectionTitle(titleLabel, text: "Overall Record")
        contentView.addSubview(titleLabel)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28)
        ])
    }

    func configure(profile: RecordsPlayerProfile) {
        let items = [
            ("MATCHES", "\(profile.overall.matches)"),
            ("RECORD", profile.overall.wlt),
            ("POINTS", RecordsFormatters.points(profile.overall.points)),
            ("WIN %", profile.overall.winPctText),
            ("WIN + TIE %", profile.overall.winTiePctText),
            ("TOURNAMENTS", "\(profile.byYear.count)")
        ]
        for pair in stride(from: 0, to: items.count, by: 2) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 14
            row.distribution = .fillEqually
            row.addArrangedSubview(tile(title: items[pair].0, value: items[pair].1))
            row.addArrangedSubview(tile(title: items[pair + 1].0, value: items[pair + 1].1))
            stack.addArrangedSubview(row)
        }
    }

    private func tile(title: String, value: String) -> UIView {
        let view = UIView()
        setupCard(view)
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.40, green: 0.40, blue: 0.43, alpha: 1)
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .heavy)
        valueLabel.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.36, alpha: 1)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.75
        view.addSubview(titleLabel)
        view.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 86),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        return view
    }
}

private final class RecordsProfileTableCell: UITableViewCell {
    private let card = UIView()
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let tableStack = UIStackView()
    private var sortHandler: ((RecordsProfileTableColumn) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sortHandler = nil
        tableStack.arrangedSubviews.forEach { row in
            tableStack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        setupCard(card)
        contentView.addSubview(card)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        setupSectionTitle(titleLabel, text: "")
        card.addSubview(titleLabel)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.layer.cornerRadius = 8
        scrollView.layer.borderWidth = 1
        scrollView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.95, alpha: 1).cgColor
        scrollView.clipsToBounds = true
        card.addSubview(scrollView)

        tableStack.translatesAutoresizingMaskIntoConstraints = false
        tableStack.axis = .vertical
        scrollView.addSubview(tableStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            scrollView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            tableStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            tableStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            tableStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            tableStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            tableStack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            tableStack.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    func configure(title: String,
                   firstColumn: String,
                   rows: [RecordsProfileTableRow],
                   sortColumn: RecordsProfileTableColumn,
                   sortAscending: Bool,
                   onSort: @escaping (RecordsProfileTableColumn) -> Void) {
        sortHandler = onSort
        titleLabel.text = title
        tableStack.addArrangedSubview(tableRow(first: headerTitle(firstColumn, column: .name, current: sortColumn, ascending: sortAscending),
                                               matches: headerTitle("MATCHES", column: .matches, current: sortColumn, ascending: sortAscending),
                                               record: headerTitle("W-L-T", column: .record, current: sortColumn, ascending: sortAscending),
                                               points: headerTitle("POINTS", column: .points, current: sortColumn, ascending: sortAscending),
                                               winPercent: headerTitle("WIN %", column: .winPercent, current: sortColumn, ascending: sortAscending),
                                               isHeader: true))
        for row in rows {
            tableStack.addArrangedSubview(tableRow(first: row.name, matches: row.matches, record: row.record, points: row.points, winPercent: row.winPercent, isHeader: false))
        }
    }

    private func headerTitle(_ title: String, column: RecordsProfileTableColumn, current: RecordsProfileTableColumn, ascending: Bool) -> String {
        guard column == current else { return title }
        return "\(title) \(ascending ? "↑" : "↓")"
    }

    private func tableRow(first: String, matches: String, record: String, points: String, winPercent: String, isHeader: Bool) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        row.backgroundColor = isHeader ? UIColor(red: 0.955, green: 0.965, blue: 0.985, alpha: 1) : UIColor.white
        row.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        row.isLayoutMarginsRelativeArrangement = true
        row.heightAnchor.constraint(equalToConstant: isHeader ? 54 : 58).isActive = true

        let firstLabel = columnLabel(first, isHeader: isHeader, alignment: .left)
        let matchesLabel = columnLabel(matches, isHeader: isHeader, alignment: .right)
        let recordLabel = columnLabel(record, isHeader: isHeader, alignment: .right)
        let pointsLabel = columnLabel(points, isHeader: isHeader, alignment: .right)
        let winPercentLabel = columnLabel(winPercent, isHeader: isHeader, alignment: .right)
        firstLabel.widthAnchor.constraint(equalToConstant: 138).isActive = true
        matchesLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        recordLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        pointsLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        winPercentLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true

        if isHeader {
            makeSortable(firstLabel, column: .name)
            makeSortable(matchesLabel, column: .matches)
            makeSortable(recordLabel, column: .record)
            makeSortable(pointsLabel, column: .points)
            makeSortable(winPercentLabel, column: .winPercent)
        }

        row.addArrangedSubview(firstLabel)
        row.addArrangedSubview(matchesLabel)
        row.addArrangedSubview(recordLabel)
        row.addArrangedSubview(pointsLabel)
        row.addArrangedSubview(winPercentLabel)
        return row
    }

    private func columnLabel(_ text: String, isHeader: Bool, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = isHeader ? UIFont.systemFont(ofSize: 13, weight: .heavy) : UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = isHeader ? UIColor(red: 0.31, green: 0.38, blue: 0.51, alpha: 1) : UIColor(red: 0.08, green: 0.18, blue: 0.36, alpha: 1)
        label.textAlignment = alignment
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.72
        return label
    }

    private func makeSortable(_ label: UILabel, column: RecordsProfileTableColumn) {
        label.isUserInteractionEnabled = true
        let tap = RecordsProfileTableHeaderTap(target: self, action: #selector(headerTapped(_:)))
        tap.column = column
        label.addGestureRecognizer(tap)
    }

    @objc private func headerTapped(_ recognizer: RecordsProfileTableHeaderTap) {
        sortHandler?(recognizer.column)
    }
}

private final class RecordsProfileTableHeaderTap: UITapGestureRecognizer {
    var column: RecordsProfileTableColumn = .name
}

private final class RecordsProfilePersonalCell: UITableViewCell {
    private let card = UIView()
    private let titleLabel = UILabel()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stack.arrangedSubviews.forEach { row in
            stack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        setupCard(card)
        contentView.addSubview(card)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        setupSectionTitle(titleLabel, text: "Personal Records")
        card.addSubview(titleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.layer.cornerRadius = 8
        stack.layer.borderWidth = 1
        stack.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.95, alpha: 1).cgColor
        stack.clipsToBounds = true
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -28),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])
    }

    func configure(records: [(String, String)]) {
        for record in records {
            stack.addArrangedSubview(recordRow(title: record.0, value: record.1))
        }
    }

    private func recordRow(title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.31, green: 0.38, blue: 0.51, alpha: 1)
        titleLabel.numberOfLines = 0
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        valueLabel.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.36, alpha: 1)
        valueLabel.numberOfLines = 0
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        return container
    }
}

private func setupCard(_ view: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.white.withAlphaComponent(0.96)
    view.layer.cornerRadius = 8
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor(red: 0.90, green: 0.91, blue: 0.94, alpha: 1).cgColor
}

private func setupSectionTitle(_ label: UILabel, text: String) {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = text
    label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
    label.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.36, alpha: 1)
    label.numberOfLines = 0
}

final class RecordsHeadToHeadViewController: UITableViewController {
    private let viewModel: RecordsViewModel
    private var redPlayer: String?
    private var bluePlayer: String?

    init(viewModel: RecordsViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
        title = "Head-to-Head"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.98, green: 0.985, blue: 0.995, alpha: 1)
        tableView.register(RecordsComparisonCardCell.self, forCellReuseIdentifier: "RecordsComparisonCardCell")
        let pools = viewModel.headToHeadPlayerPools()
        redPlayer = pools.red.first.map { viewModel.displayName(for: $0) }
        bluePlayer = pools.blue.first.map { viewModel.displayName(for: $0) }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Players", "Comparison", "Matches"][section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        let matches = currentMatches()
        if section == 1 { return max(1, viewModel.headToHeadSummary(matches: matches).count) }
        return max(1, matches.count)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "H2HCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "H2HCell")
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.accessoryType = .none

        if indexPath.section == 0 {
            cell.textLabel?.text = indexPath.row == 0 ? "Red Player" : "Blue Player"
            cell.detailTextLabel?.text = indexPath.row == 0 ? (redPlayer ?? "Select") : (bluePlayer ?? "Select")
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        let matches = currentMatches()
        if indexPath.section == 1 {
            let rows = viewModel.headToHeadSummary(matches: matches)
            if rows.isEmpty {
                cell.textLabel?.text = "Select players to compare."
                cell.detailTextLabel?.text = nil
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                return cell
            } else {
                let chartCell = tableView.dequeueReusableCell(withIdentifier: "RecordsComparisonCardCell", for: indexPath) as! RecordsComparisonCardCell
                let row = rows[indexPath.row]
                chartCell.configure(row: row)
                return chartCell
            }
        }

        if matches.isEmpty {
            cell.textLabel?.text = "No head-to-head matches found."
            cell.detailTextLabel?.text = nil
        } else {
            let match = matches[indexPath.row]
            cell.textLabel?.text = "\(match.year) \(match.format): \(match.redResult) / \(match.blueResult) \(match.score)"
            cell.detailTextLabel?.text = "Red \(match.redPlayers.joined(separator: ", ")) vs Blue \(match.bluePlayers.joined(separator: ", "))"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        if indexPath.row == 0 {
            let players = viewModel.headToHeadPlayerPools().red.map { viewModel.displayName(for: $0) }
            showPlayerPicker(title: "Red Player", players: players) { self.redPlayer = $0 }
        } else {
            let players = viewModel.headToHeadPlayerPools().blue.map { viewModel.displayName(for: $0) }
            showPlayerPicker(title: "Blue Player", players: players) { self.bluePlayer = $0 }
        }
    }

    private func showPlayerPicker(title: String, players: [String], completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for player in players {
            alert.addAction(UIAlertAction(title: player, style: .default) { _ in
                completion(player)
                self.tableView.reloadData()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func currentMatches() -> [RecordsHeadToHeadMatch] {
        guard let red = redPlayer, let blue = bluePlayer else { return [] }
        return viewModel.headToHeadMatches(redPlayer: red, bluePlayer: blue)
    }
}

private final class RecordsHeroHeaderView: UIView {
    private let card = UIView()
    private let logoView = UIImageView()
    private let titleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = card.bounds
    }

    private func setup() {
        backgroundColor = UIColor.clear
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 8
        card.layer.masksToBounds = true
        card.layer.shadowColor = UIColor(red: 0.03, green: 0.11, blue: 0.26, alpha: 1).cgColor
        card.layer.shadowOpacity = 0.18
        card.layer.shadowRadius = 18
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        addSubview(card)

        gradientLayer.colors = [
            UIColor(red: 0.024, green: 0.145, blue: 0.345, alpha: 1).cgColor,
            UIColor(red: 0.043, green: 0.219, blue: 0.494, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        card.layer.insertSublayer(gradientLayer, at: 0)

        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.image = UIImage.bccBundledImage(named: "bluffcitycup_v4", extension: "png")
            ?? UIImage.bccBundledImage(named: "bcc_icon_new_800", extension: "png")
            ?? UIImage(systemName: "flag.fill")
        logoView.contentMode = .scaleAspectFit
        logoView.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        logoView.layer.cornerRadius = 8
        logoView.layer.borderWidth = 1
        logoView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        logoView.clipsToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Bluff City Cup Player Records"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 27, weight: .heavy)
        titleLabel.numberOfLines = 0

        card.addSubview(logoView)
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            logoView.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            logoView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            logoView.widthAnchor.constraint(equalToConstant: 78),
            logoView.heightAnchor.constraint(equalToConstant: 78),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -18),
            card.heightAnchor.constraint(greaterThanOrEqualToConstant: 114)
        ])
    }

    func configure(rowCountText: String) {
    }
}

private final class RecordsSectionHeaderView: UIControl {
    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.clear
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.86, green: 0.90, blue: 0.96, alpha: 1).cgColor
        card.isUserInteractionEnabled = false
        addSubview(card)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        card.addSubview(iconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.06, green: 0.13, blue: 0.25, alpha: 1)
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            card.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
    }

    func configure(title: String, isExpanded: Bool, tag: Int) {
        self.tag = tag
        titleLabel.text = title
        iconView.image = UIImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
        accessibilityLabel = title
        accessibilityTraits = .button
    }
}

private class RecordsCardCell: UITableViewCell {
    let card = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCard()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
    }

    private func setupCard() {
        selectionStyle = .default
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white
        card.layer.cornerRadius = 8
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.88, green: 0.91, blue: 0.96, alpha: 1).cgColor
        card.layer.shadowColor = UIColor(red: 0.03, green: 0.11, blue: 0.26, alpha: 1).cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 5)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7)
        ])
    }
}

private final class RecordsDashboardCell: RecordsCardCell {
    private let accentView = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let chevronView = UIImageView()
    var showsChevron: Bool = false {
        didSet {
            chevronView.isHidden = !showsChevron
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        accentView.translatesAutoresizingMaskIntoConstraints = false
        accentView.layer.cornerRadius = 2
        card.addSubview(accentView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.06, green: 0.13, blue: 0.25, alpha: 1)
        titleLabel.numberOfLines = 0
        card.addSubview(titleLabel)

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        detailLabel.textColor = UIColor(red: 0.34, green: 0.40, blue: 0.52, alpha: 1)
        detailLabel.numberOfLines = 0
        card.addSubview(detailLabel)

        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = UIColor(red: 0.34, green: 0.40, blue: 0.52, alpha: 1)
        chevronView.isHidden = true
        card.addSubview(chevronView)

        NSLayoutConstraint.activate([
            accentView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            accentView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            accentView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            accentView.widthAnchor.constraint(equalToConstant: 4),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: accentView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -8),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            chevronView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            chevronView.widthAnchor.constraint(equalToConstant: 16),
            chevronView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(title: String, detail: String, accent: UIColor) {
        accessoryType = .none
        showsChevron = false
        accentView.backgroundColor = accent
        titleLabel.text = title
        detailLabel.text = detail
    }
}

private final class RecordsPointsChartCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let chartView = RecordsPointsChartView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.06, green: 0.13, blue: 0.25, alpha: 1)
        contentView.addSubview(titleLabel)

        chartView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chartView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            chartView.heightAnchor.constraint(equalToConstant: 310),
            chartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(title: String, totals: [RecordsYearPointTotal]) {
        titleLabel.text = title
        chartView.totals = totals
    }
}

private final class RecordsPointsChartView: UIView {
    var totals: [RecordsYearPointTotal] = [] {
        didSet {
            if totals.isEmpty {
                selectedIndex = nil
            } else if let selected = selectedIndex, selected >= totals.count {
                selectedIndex = totals.count - 1
            }
            setNeedsDisplay()
        }
    }

    private let redColor = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1)
    private let blueColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
    private var selectedIndex: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.clear
        isMultipleTouchEnabled = false
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !totals.isEmpty else { return }
        let plot = rect.inset(by: UIEdgeInsets(top: 34, left: 44, bottom: 44, right: 20))
        let maxValue = max(totals.map { max($0.red, $0.blue) }.max() ?? 1, 1)
        let axisColor = UIColor(red: 0.71, green: 0.76, blue: 0.84, alpha: 1)
        let gridColor = UIColor(red: 0.82, green: 0.86, blue: 0.92, alpha: 0.85)
        let labelColor = UIColor(red: 0.35, green: 0.42, blue: 0.54, alpha: 1)

        UIColor(red: 1, green: 1, blue: 1, alpha: 0.34).setFill()
        UIBezierPath(roundedRect: plot.insetBy(dx: -6, dy: -8), cornerRadius: 8).fill()

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: labelColor
        ]

        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(1)
        for step in 0...4 {
            let y = plot.maxY - (plot.height * CGFloat(step) / 4.0)
            context.move(to: CGPoint(x: plot.minX, y: y))
            context.addLine(to: CGPoint(x: plot.maxX, y: y))
            context.strokePath()

            let value = maxValue * Double(step) / 4.0
            let text = String(Int(round(value)))
            let size = text.size(withAttributes: labelAttrs)
            text.draw(at: CGPoint(x: plot.minX - size.width - 8, y: y - size.height / 2), withAttributes: labelAttrs)
        }

        context.setStrokeColor(axisColor.cgColor)
        context.setLineWidth(1.2)
        context.move(to: CGPoint(x: plot.minX, y: plot.minY))
        context.addLine(to: CGPoint(x: plot.minX, y: plot.maxY))
        context.addLine(to: CGPoint(x: plot.maxX, y: plot.maxY))
        context.strokePath()

        let redPoints = points(for: \RecordsYearPointTotal.red, maxValue: maxValue, plot: plot)
        let bluePoints = points(for: \RecordsYearPointTotal.blue, maxValue: maxValue, plot: plot)
        drawLine(points: redPoints, color: redColor)
        drawLine(points: bluePoints, color: blueColor)
        drawPoints(redPoints, color: redColor)
        drawPoints(bluePoints, color: blueColor)

        for (index, total) in totals.enumerated() {
            let shouldDraw = totals.count <= 8 || index % 2 == 0 || index == totals.count - 1
            guard shouldDraw else { continue }
            let x = xPosition(for: index, plot: plot)
            let size = total.year.size(withAttributes: labelAttrs)
            total.year.draw(at: CGPoint(x: x - size.width / 2, y: plot.maxY + 10), withAttributes: labelAttrs)
        }

        if let selected = selectedIndex, selected >= 0, selected < totals.count {
            drawTooltip(index: selected, redPoints: redPoints, bluePoints: bluePoints, plot: plot, rect: rect, context: context)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateSelection(from: touches.first)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateSelection(from: touches.first)
    }

    private func updateSelection(from touch: UITouch?) {
        guard let location = touch?.location(in: self), !totals.isEmpty else { return }
        let plot = bounds.inset(by: UIEdgeInsets(top: 34, left: 44, bottom: 44, right: 20))
        let step = totals.count > 1 ? plot.width / CGFloat(totals.count - 1) : 0
        let rawIndex: CGFloat
        if step == 0 {
            rawIndex = 0
        } else {
            rawIndex = (location.x - plot.minX) / step
        }
        let clamped = max(0, min(totals.count - 1, Int(round(rawIndex))))
        selectedIndex = clamped
        setNeedsDisplay()
    }

    private func points(for keyPath: KeyPath<RecordsYearPointTotal, Double>, maxValue: Double, plot: CGRect) -> [CGPoint] {
        return totals.enumerated().map { index, total in
            let x = xPosition(for: index, plot: plot)
            let ratio = CGFloat(total[keyPath: keyPath] / maxValue)
            let y = plot.maxY - plot.height * ratio
            return CGPoint(x: x, y: y)
        }
    }

    private func xPosition(for index: Int, plot: CGRect) -> CGFloat {
        guard totals.count > 1 else { return plot.midX }
        let step = plot.width / CGFloat(totals.count - 1)
        return plot.minX + CGFloat(index) * step
    }

    private func drawLine(points: [CGPoint], color: UIColor) {
        guard let first = points.first else { return }
        let path = UIBezierPath()
        path.move(to: first)
        guard points.count > 2 else {
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.lineWidth = 3
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            color.setStroke()
            path.stroke()
            return
        }

        let smoothness: CGFloat = 0.18
        for index in 0..<(points.count - 1) {
            let previous = index == 0 ? points[index] : points[index - 1]
            let current = points[index]
            let next = points[index + 1]
            let following = index + 2 < points.count ? points[index + 2] : next
            let firstControl = CGPoint(x: current.x + (next.x - previous.x) * smoothness,
                                       y: current.y + (next.y - previous.y) * smoothness)
            let secondControl = CGPoint(x: next.x - (following.x - current.x) * smoothness,
                                        y: next.y - (following.y - current.y) * smoothness)
            path.addCurve(to: next, controlPoint1: firstControl, controlPoint2: secondControl)
        }
        path.lineWidth = 3
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        color.setStroke()
        path.stroke()
    }

    private func drawPoints(_ points: [CGPoint], color: UIColor) {
        color.setFill()
        UIColor.white.setStroke()
        for point in points {
            let rect = CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)
            let path = UIBezierPath(ovalIn: rect)
            path.lineWidth = 2
            path.fill()
            path.stroke()
        }
    }

    private func drawTooltip(index: Int, redPoints: [CGPoint], bluePoints: [CGPoint], plot: CGRect, rect: CGRect, context: CGContext) {
        let total = totals[index]
        let x = xPosition(for: index, plot: plot)

        context.setStrokeColor(UIColor(red: 0.24, green: 0.29, blue: 0.38, alpha: 0.32).cgColor)
        context.setLineWidth(1)
        context.setLineDash(phase: 0, lengths: [4, 4])
        context.move(to: CGPoint(x: x, y: plot.minY))
        context.addLine(to: CGPoint(x: x, y: plot.maxY))
        context.strokePath()
        context.setLineDash(phase: 0, lengths: [])

        if index < redPoints.count {
            drawSelectedPoint(redPoints[index], color: redColor)
        }
        if index < bluePoints.count {
            drawSelectedPoint(bluePoints[index], color: blueColor)
        }

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        let detailAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.92)
        ]
        let locationParagraph = NSMutableParagraphStyle()
        locationParagraph.lineBreakMode = .byTruncatingTail
        let locationAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.84),
            .paragraphStyle: locationParagraph
        ]
        let title = total.year
        let location = total.location.bccNormalized
        let detail = "Red \(RecordsFormatters.points(total.red))   Blue \(RecordsFormatters.points(total.blue))"
        let titleSize = title.size(withAttributes: titleAttrs)
        let locationSize = location.size(withAttributes: locationAttrs)
        let detailSize = detail.size(withAttributes: detailAttrs)
        let contentWidth = max(titleSize.width, max(locationSize.width, detailSize.width))
        let width = min(rect.width - 16, contentWidth + 22)
        let locationHeight = location.isEmpty ? 0 : locationSize.height + 2
        let height = titleSize.height + locationHeight + detailSize.height + 18
        var tooltip = CGRect(x: x - width / 2, y: plot.minY - 28, width: width, height: height)
        if tooltip.minX < rect.minX + 8 {
            tooltip.origin.x = rect.minX + 8
        }
        if tooltip.maxX > rect.maxX - 8 {
            tooltip.origin.x = rect.maxX - width - 8
        }
        if tooltip.minY < rect.minY + 4 {
            tooltip.origin.y = rect.minY + 4
        }
        if tooltip.maxY > rect.maxY - 4 {
            tooltip.origin.y = rect.maxY - height - 4
        }

        UIColor(red: 0.04, green: 0.11, blue: 0.24, alpha: 0.94).setFill()
        UIBezierPath(roundedRect: tooltip, cornerRadius: 8).fill()
        title.draw(at: CGPoint(x: tooltip.minX + 11, y: tooltip.minY + 8), withAttributes: titleAttrs)
        var nextY = tooltip.minY + 8 + titleSize.height + 2
        if !location.isEmpty {
            let locationRect = CGRect(x: tooltip.minX + 11, y: nextY, width: tooltip.width - 22, height: locationSize.height)
            NSString(string: location).draw(with: locationRect, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: locationAttrs, context: nil)
            nextY += locationSize.height + 2
        }
        detail.draw(at: CGPoint(x: tooltip.minX + 11, y: nextY), withAttributes: detailAttrs)
    }

    private func drawSelectedPoint(_ point: CGPoint, color: UIColor) {
        color.setFill()
        UIColor.white.setStroke()
        let path = UIBezierPath(ovalIn: CGRect(x: point.x - 6, y: point.y - 6, width: 12, height: 12))
        path.lineWidth = 3
        path.fill()
        path.stroke()
    }
}

private final class RecordsProfileButton: UIButton {
    var recordsTeam = ""
    var recordsName = ""
}

private final class RecordsProfileGridCell: RecordsCardCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stack = UIStackView()
    private var selectionHandler: ((String, String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stack.arrangedSubviews.forEach { view in
            stack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func setup() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Player Profiles"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.06, green: 0.13, blue: 0.25, alpha: 1)
        card.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Select a player photo to view a profile with bio and historical records."
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.36, green: 0.43, blue: 0.55, alpha: 1)
        subtitleLabel.numberOfLines = 0
        card.addSubview(subtitleLabel)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            stack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    func configure(redPlayers: [(String, String, URL?)], bluePlayers: [(String, String, URL?)], handler: @escaping (String, String) -> Void) {
        selectionHandler = handler
        stack.addArrangedSubview(teamGrid(title: "Red Team", teamColor: UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1), players: redPlayers))
        stack.addArrangedSubview(teamGrid(title: "Blue Team", teamColor: UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1), players: bluePlayers))
    }

    private func teamGrid(title: String, teamColor: UIColor, players: [(String, String, URL?)]) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        label.textColor = teamColor
        container.addSubview(label)

        let grid = UIStackView()
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.axis = .vertical
        grid.spacing = 10
        container.addSubview(grid)

        let rows = stride(from: 0, to: players.count, by: 3).map { start in
            Array(players[start..<min(start + 3, players.count)])
        }
        rows.forEach { rowPlayers in
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.distribution = .fillEqually
            rowPlayers.forEach { row.addArrangedSubview(playerButton(team: $0.0, name: $0.1, url: $0.2, color: teamColor)) }
            while row.arrangedSubviews.count < 3 {
                row.addArrangedSubview(UIView())
            }
            grid.addArrangedSubview(row)
        }

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            grid.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            grid.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            grid.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func playerButton(team: String, name: String, url: URL?, color: UIColor) -> UIView {
        let button = RecordsProfileButton(type: .system)
        button.recordsTeam = team
        button.recordsName = name
        button.tintColor = color
        button.backgroundColor = color.withAlphaComponent(0.08)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = color.withAlphaComponent(0.28).cgColor
        button.addTarget(self, action: #selector(playerTapped(_:)), for: .touchUpInside)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = color
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 27
        imageView.clipsToBounds = true
        button.addSubview(imageView)
        if let url = url {
            imageView.loadBCCImage(url: url, placeholder: UIImage(systemName: "person.crop.circle"), tint: color)
        }

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = name
        nameLabel.textColor = UIColor(red: 0.08, green: 0.13, blue: 0.23, alpha: 1)
        nameLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.78
        button.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 100),
            imageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 9),
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 54),
            imageView.heightAnchor.constraint(equalToConstant: 54),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -6)
        ])

        return button
    }

    @objc private func playerTapped(_ sender: RecordsProfileButton) {
        selectionHandler?(sender.recordsTeam, sender.recordsName)
    }
}

private final class RecordsComparisonCardCell: RecordsCardCell {
    private let titleLabel = UILabel()
    private let redLabel = UILabel()
    private let blueLabel = UILabel()
    private let trackView = UIView()
    private let redFill = UIView()
    private var redWidthConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 0.06, green: 0.13, blue: 0.25, alpha: 1)
        card.addSubview(titleLabel)

        trackView.translatesAutoresizingMaskIntoConstraints = false
        trackView.backgroundColor = UIColor(red: 0.87, green: 0.91, blue: 0.97, alpha: 1)
        trackView.layer.cornerRadius = 8
        trackView.clipsToBounds = true
        card.addSubview(trackView)

        redFill.translatesAutoresizingMaskIntoConstraints = false
        redFill.backgroundColor = UIColor(red: 0.98, green: 0.89, blue: 0.90, alpha: 1)
        trackView.addSubview(redFill)

        redLabel.translatesAutoresizingMaskIntoConstraints = false
        redLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .heavy)
        redLabel.textColor = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1)
        redLabel.textAlignment = .center
        redLabel.numberOfLines = 2
        card.addSubview(redLabel)

        blueLabel.translatesAutoresizingMaskIntoConstraints = false
        blueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .heavy)
        blueLabel.textColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        blueLabel.textAlignment = .center
        blueLabel.numberOfLines = 2
        card.addSubview(blueLabel)
        card.bringSubviewToFront(titleLabel)
        card.bringSubviewToFront(redLabel)
        card.bringSubviewToFront(blueLabel)

        redWidthConstraint = redFill.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.5)
        redWidthConstraint?.isActive = true

        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            trackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            trackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            trackView.heightAnchor.constraint(equalToConstant: 64),
            trackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            titleLabel.centerXAnchor.constraint(equalTo: trackView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.34),
            redLabel.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            redLabel.leadingAnchor.constraint(equalTo: trackView.leadingAnchor, constant: 10),
            redLabel.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.32),
            blueLabel.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            blueLabel.trailingAnchor.constraint(equalTo: trackView.trailingAnchor, constant: -10),
            blueLabel.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.32),
            redFill.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            redFill.topAnchor.constraint(equalTo: trackView.topAnchor),
            redFill.bottomAnchor.constraint(equalTo: trackView.bottomAnchor)
        ])
    }

    func configure(row: RecordsComparisonRow) {
        titleLabel.text = row.label
        redLabel.text = "\(row.red.winPctText)\n\(row.red.wlt)"
        blueLabel.text = "\(row.blue.winPctText)\n\(row.blue.wlt)"
        let total = max(1, row.red.winPctValue + row.blue.winPctValue)
        let multiplier = max(0.04, min(0.96, row.red.winPctValue / total))
        if let old = redWidthConstraint {
            old.isActive = false
        }
        redWidthConstraint = redFill.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: CGFloat(multiplier))
        redWidthConstraint?.isActive = true
    }
}

private final class RecordsRankCardCell: RecordsCardCell {
    private let rankLabel = UILabel()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let statLabel = UILabel()
    private let chevronView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        rankLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .heavy)
        rankLabel.textAlignment = .center
        rankLabel.layer.cornerRadius = 8
        rankLabel.clipsToBounds = true
        card.addSubview(rankLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.numberOfLines = 0
        card.addSubview(titleLabel)

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        detailLabel.textColor = UIColor(red: 0.34, green: 0.40, blue: 0.52, alpha: 1)
        detailLabel.numberOfLines = 0
        card.addSubview(detailLabel)

        statLabel.translatesAutoresizingMaskIntoConstraints = false
        statLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        statLabel.textColor = UIColor(red: 0.06, green: 0.13, blue: 0.25, alpha: 1)
        statLabel.numberOfLines = 0
        card.addSubview(statLabel)

        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = UIColor(red: 0.34, green: 0.40, blue: 0.52, alpha: 1)
        card.addSubview(chevronView)

        NSLayoutConstraint.activate([
            rankLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            rankLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            rankLabel.widthAnchor.constraint(equalToConstant: 42),
            rankLabel.heightAnchor.constraint(equalToConstant: 42),
            titleLabel.topAnchor.constraint(equalTo: rankLabel.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -10),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            statLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 8),
            statLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            statLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            chevronView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            chevronView.widthAnchor.constraint(equalToConstant: 16),
            chevronView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(row: RecordsRankRow) {
        rankLabel.text = "#\(row.rank)"
        let teamColor = row.team == "Red" ? UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1) : UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        rankLabel.textColor = teamColor
        rankLabel.backgroundColor = teamColor.withAlphaComponent(0.10)
        titleLabel.text = row.format.isEmpty ? row.title : "\(row.title) - \(row.format)"
        detailLabel.text = "\(row.team) Team"
        statLabel.text = "\(row.stats.winPctText)  \(row.stats.wlt)  \(row.stats.matches) matches  \(RecordsFormatters.points(row.stats.points)) pts"
    }
}

private final class RecordsMatchCardCell: RecordsCardCell {
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let winnerLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        titleLabel.numberOfLines = 0
        card.addSubview(titleLabel)

        winnerLabel.translatesAutoresizingMaskIntoConstraints = false
        winnerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .bold)
        winnerLabel.textAlignment = .center
        winnerLabel.layer.cornerRadius = 8
        winnerLabel.clipsToBounds = true
        card.addSubview(winnerLabel)

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        detailLabel.textColor = UIColor(red: 0.34, green: 0.40, blue: 0.52, alpha: 1)
        detailLabel.numberOfLines = 0
        card.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: winnerLabel.leadingAnchor, constant: -10),
            winnerLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            winnerLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            winnerLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 72),
            winnerLabel.heightAnchor.constraint(equalToConstant: 30),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            detailLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    func configure(row: RecordsMatchOutcomeRow, viewModel: RecordsViewModel) {
        titleLabel.text = "\(row.year) \(row.format)"
        winnerLabel.text = "\(row.winner) \(row.score)"
        let winnerColor = row.winner == "Red" ? UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1) : (row.winner == "Blue" ? UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1) : UIColor.gray)
        winnerLabel.textColor = winnerColor
        winnerLabel.backgroundColor = winnerColor.withAlphaComponent(0.10)
        detailLabel.text = "Red \(row.redPlayers.map(viewModel.playerLastName).joined(separator: ", ")) vs Blue \(row.bluePlayers.map(viewModel.playerLastName).joined(separator: ", "))\(row.course.isEmpty ? "" : "\n\(row.course) \(row.tees)")"
    }
}

private extension UIImageView {
    func loadBCCImage(url: URL, placeholder: UIImage?, tint: UIColor) {
        image = placeholder
        tintColor = tint
        accessibilityIdentifier = url.absoluteString

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                if self.accessibilityIdentifier == url.absoluteString {
                    self.tintColor = nil
                    self.contentMode = .scaleAspectFill
                    self.clipsToBounds = true
                    self.image = image
                }
            }
        }.resume()
    }
}

private extension UIImage {
    static func bccBundledImage(named name: String, extension ext: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: ext) else { return nil }
        return UIImage(contentsOfFile: path)
    }
}
