//
//  ScheduleModels.swift
//  Bluff City Cup
//

import Foundation

struct SchedulePayload: Decodable {
    let success: Bool
    let tournament: String
    let rowCount: Int
    let events: [ScheduleEvent]
}

struct ScheduleEvent: Decodable {
    let id: String
    let tournament: String
    let eventType: String
    let eventDate: String
    let startTime: String
    let endTime: String
    let title: String
    let locationName: String
    let locationAddress: String
    let locationURL: String
    let courseName: String
    let scoringFormat: String
    let pointsPerMatch: String
    let note: String
    let sortOrder: String

    enum CodingKeys: String, CodingKey {
        case id, tournament, title, note
        case eventType = "event_type"
        case eventDate = "event_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case locationName = "location_name"
        case locationAddress = "location_address"
        case locationURL = "location_url"
        case courseName = "course_name"
        case scoringFormat = "scoring_format"
        case pointsPerMatch = "points_per_match"
        case sortOrder = "sort_order"
    }
}

enum ScheduleEventType: String {
    case golf
    case meal
    case misc

    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "golf":
            self = .golf
        case "meal":
            self = .meal
        default:
            self = .misc
        }
    }

    var title: String {
        switch self {
        case .golf:
            return "Golf"
        case .meal:
            return "Meal"
        case .misc:
            return "Event"
        }
    }

    var symbolName: String {
        switch self {
        case .golf:
            return "flag.fill"
        case .meal:
            return "fork.knife"
        case .misc:
            return "calendar"
        }
    }
}

struct ScheduleDay {
    let date: Date
    let events: [ScheduleEvent]
}

struct ScheduleEventDraft {
    var id: String?
    var tournament: String
    var eventType: ScheduleEventType
    var eventDate: String
    var startTime: String
    var endTime: String
    var title: String
    var locationName: String
    var locationAddress: String
    var locationURL: String
    var courseName: String
    var scoringFormat: String
    var pointsPerMatch: String
    var note: String
    var sortOrder: String

    init(tournament: String) {
        self.id = nil
        self.tournament = tournament
        self.eventType = .golf
        self.eventDate = ScheduleFormatters.apiDate.string(from: Date())
        self.startTime = ""
        self.endTime = ""
        self.title = ""
        self.locationName = ""
        self.locationAddress = ""
        self.locationURL = ""
        self.courseName = ""
        self.scoringFormat = ""
        self.pointsPerMatch = ""
        self.note = ""
        self.sortOrder = "0"
    }

    init(event: ScheduleEvent) {
        self.id = event.id
        self.tournament = event.tournament
        self.eventType = event.type
        self.eventDate = event.eventDate
        self.startTime = event.startTime
        self.endTime = event.endTime
        self.title = event.title
        self.locationName = event.locationName
        self.locationAddress = event.locationAddress
        self.locationURL = event.locationURL
        self.courseName = event.courseName
        self.scoringFormat = event.scoringFormat
        self.pointsPerMatch = event.pointsPerMatch
        self.note = event.note
        self.sortOrder = event.sortOrder
    }

    var queryItems: [URLQueryItem] {
        return [
            URLQueryItem(name: "id", value: id ?? ""),
            URLQueryItem(name: "tournament", value: tournament),
            URLQueryItem(name: "event_type", value: eventType.rawValue),
            URLQueryItem(name: "event_date", value: eventDate),
            URLQueryItem(name: "start_time", value: startTime),
            URLQueryItem(name: "end_time", value: endTime),
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "location_name", value: locationName),
            URLQueryItem(name: "location_address", value: locationAddress),
            URLQueryItem(name: "location_url", value: locationURL),
            URLQueryItem(name: "course_name", value: courseName),
            URLQueryItem(name: "scoring_format", value: scoringFormat),
            URLQueryItem(name: "points_per_match", value: pointsPerMatch),
            URLQueryItem(name: "note", value: note),
            URLQueryItem(name: "sort_order", value: "0")
        ]
    }
}

extension ScheduleEvent {
    var type: ScheduleEventType {
        return ScheduleEventType(rawValue: eventType)
    }

    var idValue: Int {
        return Int(id) ?? 0
    }

    var dateValue: Date? {
        return ScheduleFormatters.apiDate.date(from: eventDate)
    }

    var startTimeValue: Date? {
        return ScheduleFormatters.apiTime.date(from: startTime)
    }

    var displayTitle: String {
        switch type {
        case .golf:
            return courseName.bccScheduleNilIfEmpty ?? title.bccScheduleNilIfEmpty ?? "Golf round"
        case .meal:
            return title.bccScheduleNilIfEmpty ?? locationName.bccScheduleNilIfEmpty ?? "Meal"
        case .misc:
            return title.bccScheduleNilIfEmpty ?? locationName.bccScheduleNilIfEmpty ?? "Event"
        }
    }

    var displayLocation: String? {
        switch type {
        case .golf:
            let course = courseName.bccScheduleNilIfEmpty
            let place = locationName.bccScheduleNilIfEmpty
            if let place, place.caseInsensitiveCompare(course ?? "") != .orderedSame {
                return place
            }
            return locationAddress.bccScheduleNilIfEmpty
        case .meal, .misc:
            return locationName.bccScheduleNilIfEmpty
        }
    }

    var displayTime: String {
        let start = ScheduleFormatters.displayTime(from: startTime)
        let end = ScheduleFormatters.displayTime(from: endTime)

        if !start.isEmpty && !end.isEmpty {
            return "\(start)-\(end)"
        }

        return start.isEmpty ? "Time TBD" : start
    }

    var pointsText: String? {
        guard let points = Double(pointsPerMatch), points > 0 else { return nil }
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = points.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        formatter.maximumFractionDigits = 2
        let text = formatter.string(from: NSNumber(value: points)) ?? pointsPerMatch
        return "\(text) \(points == 1 ? "point" : "points") per match"
    }

    var mapURL: URL? {
        if let url = URL(string: locationURL), !locationURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return url
        }

        let query = (locationAddress.bccScheduleNilIfEmpty ?? displayLocation)?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let encodedQuery = query else { return nil }
        return URL(string: "https://maps.apple.com/?q=\(encodedQuery)")
    }
}

enum ScheduleFormatters {
    static let apiDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let apiTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let dayHeader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    static let formDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let timeOutput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static func displayDay(_ date: Date) -> String {
        let base = dayHeader.string(from: date)
        let day = Calendar.current.component(.day, from: date)
        return base + ordinalSuffix(for: day)
    }

    static func displayTime(from time: String) -> String {
        guard let date = apiTime.date(from: time) else { return "" }
        return timeOutput.string(from: date)
    }

    private static func ordinalSuffix(for day: Int) -> String {
        let tens = day % 100
        if tens >= 11 && tens <= 13 {
            return "th"
        }

        switch day % 10 {
        case 1:
            return "st"
        case 2:
            return "nd"
        case 3:
            return "rd"
        default:
            return "th"
        }
    }
}

private extension String {
    var bccScheduleNilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
