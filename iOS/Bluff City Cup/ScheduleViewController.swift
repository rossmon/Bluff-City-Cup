//
//  ScheduleViewController.swift
//  Bluff City Cup
//

import UIKit

@objc
protocol ScheduleViewControllerDelegate: AnyObject {
    @objc optional func toggleTopPanelSchedule()
    @objc optional func collapseTopPanelSchedule()
    @objc optional func changeViewSchedule(_ menu: String, scorecardMatch: Match?)
}

final class ScheduleViewController: UITableViewController {
    weak var delegate: ScheduleViewControllerDelegate?

    private let tournamentName: String
    private let viewModel = ScheduleViewModel()
    private var isLoading = false
    private var loadError: String?

    private let blue = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
    private let red = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1)
    private let surface = UIColor(red: 0.947, green: 0.961, blue: 0.984, alpha: 1)

    init(tournamentName: String) {
        self.tournamentName = tournamentName
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        self.tournamentName = ""
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Schedule"
        tableView.backgroundColor = surface
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 136
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        tableView.register(ScheduleEventCell.self, forCellReuseIdentifier: ScheduleEventCell.reuseIdentifier)
        tableView.register(ScheduleStatusCell.self, forCellReuseIdentifier: ScheduleStatusCell.reuseIdentifier)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(menuTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        configureNavigationStyle()
        loadSchedule(forceRefresh: false)
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

    @objc private func menuTapped() {
        delegate?.toggleTopPanelSchedule?()
    }

    @objc private func refreshTapped() {
        loadSchedule(forceRefresh: true)
    }

    private func loadSchedule(forceRefresh: Bool) {
        isLoading = true
        loadError = nil
        tableView.reloadData()

        viewModel.load(tournamentName: tournamentName, forceRefresh: forceRefresh) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.loadError = error?.localizedDescription
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isLoading || loadError != nil || !viewModel.hasSchedule {
            return 1
        }

        return viewModel.days.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || loadError != nil || !viewModel.hasSchedule {
            return 1
        }

        return viewModel.days[section].events.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !isLoading, loadError == nil, viewModel.hasSchedule else { return nil }

        let header = ScheduleDayHeaderView()
        header.configure(title: ScheduleFormatters.displayDay(viewModel.days[section].date))
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (isLoading || loadError != nil || !viewModel.hasSchedule) ? 0.01 : 58
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading || loadError != nil || !viewModel.hasSchedule {
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleStatusCell.reuseIdentifier, for: indexPath) as! ScheduleStatusCell
            if isLoading {
                cell.configure(title: "Loading schedule...", message: nil)
            } else if let loadError = loadError {
                cell.configure(title: "Schedule unavailable", message: loadError)
            } else {
                cell.configure(title: "No schedule yet", message: "This tournament does not have schedule events.")
            }
            return cell
        }

        let event = viewModel.days[indexPath.section].events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleEventCell.reuseIdentifier, for: indexPath) as! ScheduleEventCell
        cell.configure(event: event, red: red, blue: blue)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !isLoading, loadError == nil, viewModel.hasSchedule else { return }

        let event = viewModel.days[indexPath.section].events[indexPath.row]
        guard let url = event.mapURL else { return }
        UIApplication.shared.open(url)
    }
}

extension ScheduleViewController: TopPanelViewControllerDelegate {
    func settingSelected(_ menu: String, scorecardMatch: Match?) {
        delegate?.changeViewSchedule?(menu, scorecardMatch: scorecardMatch)
    }
}

final class ScheduleDayHeaderView: UIView {
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 23, weight: .heavy)
        titleLabel.textColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}

final class ScheduleStatusCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleStatusCell"

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 0.847, green: 0.882, blue: 0.941, alpha: 1).cgColor
        contentView.addSubview(cardView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = UIColor(red: 0.337, green: 0.404, blue: 0.529, alpha: 1)
        messageLabel.numberOfLines = 0

        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, message: String?) {
        titleLabel.text = title
        messageLabel.text = message ?? ""
        messageLabel.isHidden = (message ?? "").isEmpty
    }
}

final class ScheduleEventCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleEventCell"

    private let cardView = UIView()
    private let accentView = UIView()
    private let iconView = UIImageView()
    private let typeLabel = UILabel()
    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let detailStack = UIStackView()
    private let roundLabel = UILabel()
    private let formatLabel = UILabel()
    private let pointsLabel = UILabel()
    private let noteLabel = UILabel()
    private let mapLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(red: 0.847, green: 0.882, blue: 0.941, alpha: 1).cgColor
        contentView.addSubview(cardView)

        accentView.translatesAutoresizingMaskIntoConstraints = false
        accentView.layer.cornerRadius = 2
        cardView.addSubview(accentView)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        cardView.addSubview(iconView)

        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        typeLabel.textColor = UIColor(red: 0.337, green: 0.404, blue: 0.529, alpha: 1)
        cardView.addSubview(typeLabel)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        timeLabel.textColor = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1)
        timeLabel.textAlignment = .right
        cardView.addSubview(timeLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 21, weight: .heavy)
        titleLabel.textColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        locationLabel.textColor = UIColor(red: 0.337, green: 0.404, blue: 0.529, alpha: 1)
        locationLabel.numberOfLines = 0
        cardView.addSubview(locationLabel)

        detailStack.translatesAutoresizingMaskIntoConstraints = false
        detailStack.axis = .vertical
        detailStack.spacing = 8
        cardView.addSubview(detailStack)

        [roundLabel, formatLabel, pointsLabel, noteLabel].forEach { label in
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = UIColor(red: 0.157, green: 0.231, blue: 0.365, alpha: 1)
            label.numberOfLines = 0
            detailStack.addArrangedSubview(label)
        }
        roundLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        pointsLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        pointsLabel.textColor = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1)
        noteLabel.font = UIFont.italicSystemFont(ofSize: 13)
        noteLabel.textColor = UIColor(red: 0.337, green: 0.404, blue: 0.529, alpha: 1)

        mapLabel.translatesAutoresizingMaskIntoConstraints = false
        mapLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        mapLabel.textColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        let mapTextColor = UIColor(red: 0.067, green: 0.176, blue: 0.451, alpha: 1)
        let mapText = NSMutableAttributedString()
        if let icon = UIImage(systemName: "map.fill")?.withTintColor(mapTextColor, renderingMode: .alwaysOriginal) {
            let attachment = NSTextAttachment()
            attachment.image = icon
            attachment.bounds = CGRect(x: 0, y: -2, width: 13, height: 13)
            mapText.append(NSAttributedString(attachment: attachment))
            mapText.append(NSAttributedString(string: " "))
        }
        mapText.append(NSAttributedString(
            string: "Open in Maps",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .bold),
                .foregroundColor: mapTextColor
            ]
        ))
        mapLabel.attributedText = mapText
        cardView.addSubview(mapLabel)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            accentView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            accentView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            accentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
            accentView.widthAnchor.constraint(equalToConstant: 5),

            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            typeLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            typeLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: typeLabel.trailingAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            timeLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),

            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),

            detailStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailStack.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),

            mapLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            mapLabel.topAnchor.constraint(equalTo: detailStack.bottomAnchor, constant: 12),
            mapLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(event: ScheduleEvent, red: UIColor, blue: UIColor) {
        let accentColor: UIColor
        switch event.type {
        case .golf:
            accentColor = blue
        case .meal:
            accentColor = red
        case .misc:
            accentColor = UIColor(red: 0.329, green: 0.431, blue: 0.612, alpha: 1)
        }

        accentView.backgroundColor = accentColor
        iconView.tintColor = accentColor
        iconView.image = UIImage(systemName: event.type.symbolName)
        typeLabel.text = event.type.title.uppercased()
        timeLabel.text = event.displayTime
        titleLabel.text = event.displayTitle
        locationLabel.text = event.displayLocation ?? event.locationAddress
        locationLabel.isHidden = (locationLabel.text ?? "").isEmpty

        let roundName = event.type == .golf ? event.title.trimmingCharacters(in: .whitespacesAndNewlines) : ""
        roundLabel.text = roundName.isEmpty ? nil : roundName
        roundLabel.isHidden = (roundLabel.text ?? "").isEmpty

        formatLabel.text = event.scoringFormat.isEmpty ? nil : "Format: \(event.scoringFormat)"
        formatLabel.isHidden = (formatLabel.text ?? "").isEmpty

        pointsLabel.text = event.pointsText
        pointsLabel.isHidden = (pointsLabel.text ?? "").isEmpty

        noteLabel.text = event.note.isEmpty ? nil : "Note: \(event.note)"
        noteLabel.isHidden = event.note.isEmpty

        mapLabel.isHidden = event.mapURL == nil
    }
}
