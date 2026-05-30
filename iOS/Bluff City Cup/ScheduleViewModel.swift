//
//  ScheduleViewModel.swift
//  Bluff City Cup
//

import Foundation

final class ScheduleViewModel {
    private(set) var payload: SchedulePayload?
    private(set) var days: [ScheduleDay] = []

    var hasSchedule: Bool {
        return !days.isEmpty
    }

    func load(tournamentName: String, forceRefresh: Bool = false, completion: @escaping (Error?) -> Void) {
        ScheduleAPIService.shared.fetchSchedule(tournamentName: tournamentName, forceRefresh: forceRefresh) { [weak self] payload, error in
            guard let self = self else { return }

            if let payload = payload {
                self.payload = payload
                self.days = self.group(events: payload.events)
            }

            completion(error)
        }
    }

    private func group(events: [ScheduleEvent]) -> [ScheduleDay] {
        let datedEvents = events.compactMap { event -> (Date, ScheduleEvent)? in
            guard let date = event.dateValue else { return nil }
            return (date, event)
        }

        let grouped = Dictionary(grouping: datedEvents, by: { Calendar.current.startOfDay(for: $0.0) })

        return grouped.keys.sorted().map { date in
            let eventsForDay = grouped[date]?.map { $0.1 }.sorted(by: sortEvents) ?? []
            return ScheduleDay(date: date, events: eventsForDay)
        }
    }

    private func sortEvents(_ left: ScheduleEvent, _ right: ScheduleEvent) -> Bool {
        let leftTime = left.startTimeValue ?? Date.distantFuture
        let rightTime = right.startTimeValue ?? Date.distantFuture
        if leftTime != rightTime {
            return leftTime < rightTime
        }

        return left.idValue < right.idValue
    }
}
