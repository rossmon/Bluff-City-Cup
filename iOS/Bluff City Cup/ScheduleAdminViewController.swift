//
//  ScheduleAdminViewController.swift
//  Bluff City Cup
//

import UIKit

protocol ScheduleEditorViewControllerDelegate: AnyObject {
    func scheduleEditorDidSave()
}

final class ScheduleAdminViewController: UITableViewController {
    private let tournamentName: String
    private let viewModel = ScheduleViewModel()
    private var isLoading = false
    private var loadError: String?

    private let blue = UIColor(red: 0.071, green: 0.176, blue: 0.451, alpha: 1.0)
    private let red = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1.0)
    private let surface = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1.0)
    private let secondaryText = UIColor(red: 0.365, green: 0.392, blue: 0.439, alpha: 1.0)

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
        tableView.estimatedRowHeight = 108
        tableView.register(ScheduleAdminEventCell.self, forCellReuseIdentifier: ScheduleAdminEventCell.reuseIdentifier)
        tableView.register(ScheduleAdminStatusCell.self, forCellReuseIdentifier: ScheduleAdminStatusCell.reuseIdentifier)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        configureNavigationStyle()
        loadEvents(forceRefresh: true)
    }

    private func configureNavigationStyle() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = blue
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    private func loadEvents(forceRefresh: Bool) {
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

    @objc private func addTapped() {
        let editor = ScheduleEditorViewController(draft: ScheduleEventDraft(tournament: tournamentName))
        editor.delegate = self
        navigationController?.pushViewController(editor, animated: true)
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isLoading, loadError == nil, viewModel.hasSchedule else { return nil }
        return ScheduleFormatters.displayDay(viewModel.days[section].date)
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = secondaryText
        header.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading || loadError != nil || !viewModel.hasSchedule {
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAdminStatusCell.reuseIdentifier, for: indexPath) as! ScheduleAdminStatusCell
            if isLoading {
                cell.configure(title: "Loading schedule...", detail: nil)
            } else if let loadError = loadError {
                cell.configure(title: "Schedule unavailable", detail: loadError)
            } else {
                cell.configure(title: "No schedule events", detail: "Tap + to add the first event.")
            }
            return cell
        }

        let event = viewModel.days[indexPath.section].events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleAdminEventCell.reuseIdentifier, for: indexPath) as! ScheduleAdminEventCell
        cell.configure(event: event, blue: blue, red: red)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !isLoading, loadError == nil, viewModel.hasSchedule else { return }

        let event = viewModel.days[indexPath.section].events[indexPath.row]
        let editor = ScheduleEditorViewController(draft: ScheduleEventDraft(event: event))
        editor.delegate = self
        navigationController?.pushViewController(editor, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isLoading && loadError == nil && viewModel.hasSchedule
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let event = viewModel.days[indexPath.section].events[indexPath.row]
        confirmDelete(event: event)
    }

    private func confirmDelete(event: ScheduleEvent) {
        let alert = UIAlertController(title: "Delete Event", message: "Delete \(event.displayTitle)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            ScheduleAPIService.shared.deleteEvent(id: event.id, tournamentName: self.tournamentName) { [weak self] success, error in
                guard let self = self else { return }
                if success {
                    self.loadEvents(forceRefresh: true)
                } else {
                    self.showError(error?.localizedDescription ?? "The event could not be deleted.")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Schedule Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ScheduleAdminViewController: ScheduleEditorViewControllerDelegate {
    func scheduleEditorDidSave() {
        loadEvents(forceRefresh: true)
    }
}

final class ScheduleEditorViewController: UITableViewController {
    enum Section: Int {
        case type
        case timing
        case details
        case location
        case golf
        case note

        static let all: [Section] = [.type, .timing, .details, .location, .golf, .note]
    }

    weak var delegate: ScheduleEditorViewControllerDelegate?
    private var draft: ScheduleEventDraft
    private var fields: [String: UITextField] = [:]
    private let typeControl = UISegmentedControl(items: ["Golf", "Meal", "Event"])
    private let datePicker = UIDatePicker()
    private let startTimePicker = UIDatePicker()
    private let endTimePicker = UIDatePicker()
    private let blue = UIColor(red: 0.071, green: 0.176, blue: 0.451, alpha: 1.0)
    private let red = UIColor(red: 0.718, green: 0.039, blue: 0.110, alpha: 1.0)
    private let surface = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1.0)

    init(draft: ScheduleEventDraft) {
        self.draft = draft
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        self.draft = ScheduleEventDraft(tournament: "")
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = draft.id == nil ? "Add Event" : "Edit Event"
        tableView.backgroundColor = surface
        tableView.keyboardDismissMode = .interactive
        tableView.register(ScheduleEditorTextFieldCell.self, forCellReuseIdentifier: ScheduleEditorTextFieldCell.reuseIdentifier)
        tableView.register(ScheduleEditorTypeCell.self, forCellReuseIdentifier: ScheduleEditorTypeCell.reuseIdentifier)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        configureNavigationStyle()
        configurePickers()
    }

    private func configureNavigationStyle() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = blue
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let editorSection = Section(rawValue: section) else { return 0 }
        switch editorSection {
        case .type:
            return 1
        case .timing:
            return draft.eventType == .golf ? 3 : 2
        case .details:
            return 1
        case .location:
            return 3
        case .golf:
            return draft.eventType == .golf ? 3 : 0
        case .note:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let editorSection = Section(rawValue: section) else { return nil }
        switch editorSection {
        case .type: return "Type"
        case .timing: return "When"
        case .details: return "Details"
        case .location: return "Location"
        case .golf: return draft.eventType == .golf ? "Golf Round" : nil
        case .note: return "Notes"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let editorSection = Section(rawValue: indexPath.section) else { return UITableViewCell() }

        if editorSection == .type {
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleEditorTypeCell.reuseIdentifier, for: indexPath) as! ScheduleEditorTypeCell
            typeControl.selectedSegmentIndex = selectedTypeIndex()
            typeControl.removeTarget(self, action: #selector(typeChanged), for: .valueChanged)
            typeControl.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
            cell.configure(control: typeControl)
            return cell
        }

        let field = fieldConfig(for: editorSection, row: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleEditorTextFieldCell.reuseIdentifier, for: indexPath) as! ScheduleEditorTextFieldCell
        cell.configure(label: field.label, value: value(for: field.key), placeholder: field.placeholder, keyboardType: field.keyboard)
        configurePickerInput(for: cell.textField, key: field.key)
        fields[field.key] = cell.textField
        return cell
    }

    private func fieldConfig(for section: Section, row: Int) -> (key: String, label: String, placeholder: String, keyboard: UIKeyboardType) {
        switch section {
        case .timing:
            if row == 0 { return ("eventDate", "Date", "Select date", .default) }
            if row == 1 { return ("startTime", draft.eventType == .golf ? "First Tee Time" : "Time", "Select time", .default) }
            return ("endTime", "End Time", "Select time", .default)
        case .details:
            return ("title", draft.eventType == .golf ? "Round Name" : "Name", "Event name", .default)
        case .location:
            if row == 0 { return ("locationName", draft.eventType == .golf ? "Course/Place" : "Place", "Location name", .default) }
            if row == 1 { return ("locationAddress", "Address", "Street, city, state", .default) }
            return ("locationURL", "Map Link", "https://maps.apple.com/...", .URL)
        case .golf:
            if row == 0 { return ("courseName", "Course", "Course name", .default) }
            if row == 1 { return ("scoringFormat", "Format", "Best Ball, Singles...", .default) }
            return ("pointsPerMatch", "Points", "1.00", .decimalPad)
        case .note:
            if row == 0 { return ("note", "Note", "Short note", .default) }
            return ("tournament", "Tournament", draft.tournament, .default)
        case .type:
            return ("", "", "", .default)
        }
    }

    private func value(for key: String) -> String {
        switch key {
        case "eventDate": return draft.eventDate
        case "startTime": return draft.startTime
        case "endTime": return draft.endTime
        case "title": return draft.title
        case "locationName": return draft.locationName
        case "locationAddress": return draft.locationAddress
        case "locationURL": return draft.locationURL
        case "courseName": return draft.courseName
        case "scoringFormat": return draft.scoringFormat
        case "pointsPerMatch": return draft.pointsPerMatch
        case "note": return draft.note
        case "tournament": return draft.tournament
        default: return ""
        }
    }

    private func selectedTypeIndex() -> Int {
        switch draft.eventType {
        case .golf: return 0
        case .meal: return 1
        case .misc: return 2
        }
    }

    private func configurePickers() {
        datePicker.datePickerMode = .date
        startTimePicker.datePickerMode = .time
        endTimePicker.datePickerMode = .time
        startTimePicker.locale = Locale(identifier: "en_US")
        endTimePicker.locale = Locale(identifier: "en_US")

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            startTimePicker.preferredDatePickerStyle = .wheels
            endTimePicker.preferredDatePickerStyle = .wheels
        }

        datePicker.date = ScheduleFormatters.apiDate.date(from: draft.eventDate) ?? Date()
        startTimePicker.date = ScheduleFormatters.apiTime.date(from: draft.startTime) ?? Date()
        endTimePicker.date = ScheduleFormatters.apiTime.date(from: draft.endTime) ?? Date()
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        startTimePicker.addTarget(self, action: #selector(startTimePickerChanged), for: .valueChanged)
        endTimePicker.addTarget(self, action: #selector(endTimePickerChanged), for: .valueChanged)
    }

    private func configurePickerInput(for textField: UITextField, key: String) {
        switch key {
        case "eventDate":
            textField.inputView = datePicker
            textField.inputAccessoryView = pickerToolbar()
            textField.text = displayDateText(from: draft.eventDate)
        case "startTime":
            textField.inputView = startTimePicker
            textField.inputAccessoryView = pickerToolbar()
            textField.text = displayTimeText(from: draft.startTime)
        case "endTime":
            textField.inputView = endTimePicker
            textField.inputAccessoryView = pickerToolbar()
            textField.text = displayTimeText(from: draft.endTime)
        default:
            textField.inputView = nil
            textField.inputAccessoryView = nil
        }
    }

    private func pickerToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicking))
        ]
        return toolbar
    }

    @objc private func donePicking() {
        view.endEditing(true)
    }

    @objc private func datePickerChanged() {
        draft.eventDate = ScheduleFormatters.apiDate.string(from: datePicker.date)
        fields["eventDate"]?.text = displayDateText(from: draft.eventDate)
    }

    @objc private func startTimePickerChanged() {
        draft.startTime = ScheduleFormatters.apiTime.string(from: startTimePicker.date)
        fields["startTime"]?.text = displayTimeText(from: draft.startTime)
    }

    @objc private func endTimePickerChanged() {
        draft.endTime = ScheduleFormatters.apiTime.string(from: endTimePicker.date)
        fields["endTime"]?.text = displayTimeText(from: draft.endTime)
    }

    private func displayDateText(from value: String) -> String {
        guard let date = ScheduleFormatters.apiDate.date(from: value) else { return "" }
        return ScheduleFormatters.formDate.string(from: date)
    }

    private func displayTimeText(from value: String) -> String {
        return ScheduleFormatters.displayTime(from: value)
    }

    @objc private func typeChanged() {
        switch typeControl.selectedSegmentIndex {
        case 0: draft.eventType = .golf
        case 1: draft.eventType = .meal
        default: draft.eventType = .misc
        }
        tableView.reloadData()
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        readFields()

        guard validateDraft() else { return }
        navigationItem.rightBarButtonItem?.isEnabled = false
        ScheduleAPIService.shared.saveEvent(draft) { [weak self] success, error in
            guard let self = self else { return }
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            if success {
                self.delegate?.scheduleEditorDidSave()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(error?.localizedDescription ?? "The schedule event could not be saved.")
            }
        }
    }

    private func readFields() {
        draft.eventDate = text("eventDate")
        draft.startTime = text("startTime")
        draft.endTime = text("endTime")
        draft.title = text("title")
        draft.locationName = text("locationName")
        draft.locationAddress = text("locationAddress")
        draft.locationURL = text("locationURL")
        draft.courseName = text("courseName")
        draft.scoringFormat = text("scoringFormat")
        draft.pointsPerMatch = text("pointsPerMatch")
        draft.note = text("note")
        draft.sortOrder = "0"

        if draft.eventType != .golf {
            draft.courseName = ""
            draft.scoringFormat = ""
            draft.pointsPerMatch = ""
            draft.endTime = ""
        }
    }

    private func text(_ key: String) -> String {
        if key == "eventDate" {
            return draft.eventDate
        }
        if key == "startTime" {
            return draft.startTime
        }
        if key == "endTime" {
            return draft.endTime
        }
        return fields[key]?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? value(for: key)
    }

    private func validateDraft() -> Bool {
        guard ScheduleFormatters.apiDate.date(from: draft.eventDate) != nil else {
            showError("Enter the date as YYYY-MM-DD.")
            return false
        }

        if !draft.startTime.isEmpty && ScheduleFormatters.apiTime.date(from: draft.startTime) == nil {
            showError("Enter start time as HH:MM, like 08:05.")
            return false
        }

        if !draft.endTime.isEmpty && ScheduleFormatters.apiTime.date(from: draft.endTime) == nil {
            showError("Enter end time as HH:MM, like 08:45.")
            return false
        }

        if draft.displayNameForValidation.isEmpty {
            showError("Enter a name or location for the event.")
            return false
        }

        return true
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Schedule Event", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

private extension ScheduleEventDraft {
    var displayNameForValidation: String {
        if eventType == .golf {
            return courseName.isEmpty ? locationName : courseName
        }
        return title.isEmpty ? locationName : title
    }
}

final class ScheduleAdminEventCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleAdminEventCell"

    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let typeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        backgroundColor = .clear

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.847, green: 0.882, blue: 0.941, alpha: 1).cgColor
        contentView.addSubview(card)

        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .heavy)
        typeLabel.textAlignment = .center
        typeLabel.layer.cornerRadius = 8
        typeLabel.layer.masksToBounds = true
        card.addSubview(typeLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.071, green: 0.176, blue: 0.451, alpha: 1.0)
        titleLabel.numberOfLines = 0
        card.addSubview(titleLabel)

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        detailLabel.textColor = UIColor(red: 0.365, green: 0.392, blue: 0.439, alpha: 1.0)
        detailLabel.numberOfLines = 0
        card.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            typeLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            typeLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            typeLabel.widthAnchor.constraint(equalToConstant: 58),
            typeLabel.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: typeLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(event: ScheduleEvent, blue: UIColor, red: UIColor) {
        titleLabel.text = event.displayTitle
        var details = event.displayTime
        if let location = event.displayLocation {
            details += " • \(location)"
        }
        if event.type == .golf && !event.scoringFormat.isEmpty {
            details += " • \(event.scoringFormat)"
        }
        detailLabel.text = details
        typeLabel.text = event.type.title.uppercased()

        let color: UIColor
        switch event.type {
        case .golf: color = blue
        case .meal: color = red
        case .misc: color = UIColor(red: 0.329, green: 0.431, blue: 0.612, alpha: 1)
        }
        typeLabel.textColor = color
        typeLabel.backgroundColor = color.withAlphaComponent(0.10)
    }
}

final class ScheduleAdminStatusCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleAdminStatusCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, detail: String?) {
        textLabel?.text = title
        detailTextLabel?.text = detail
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        textLabel?.textColor = UIColor(red: 0.071, green: 0.176, blue: 0.451, alpha: 1.0)
        detailTextLabel?.textColor = UIColor.gray
        selectionStyle = .none
        backgroundColor = .clear
    }
}

final class ScheduleEditorTypeCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleEditorTypeCell"

    func configure(control: UISegmentedControl) {
        selectionStyle = .none
        control.translatesAutoresizingMaskIntoConstraints = false
        if control.superview !== contentView {
            contentView.addSubview(control)
            NSLayoutConstraint.activate([
                control.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                control.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                control.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                control.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
        }
    }
}

final class ScheduleEditorTextFieldCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleEditorTextFieldCell"

    let textField = UITextField()
    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(red: 0.365, green: 0.392, blue: 0.439, alpha: 1.0)
        contentView.addSubview(label)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.textAlignment = .right
        textField.clearButtonMode = .whileEditing
        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 118),
            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 34)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(label: String, value: String, placeholder: String, keyboardType: UIKeyboardType) {
        self.label.text = label
        textField.text = value
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .words
        if keyboardType == .URL {
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
    }
}
