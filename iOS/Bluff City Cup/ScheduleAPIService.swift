//
//  ScheduleAPIService.swift
//  Bluff City Cup
//

import Foundation

extension Notification.Name {
    static let bccScheduleEventsDidChange = Notification.Name("bccScheduleEventsDidChange")
}

enum ScheduleAPIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(String)
}

final class ScheduleAPIService {
    static let shared = ScheduleAPIService()

    private let baseURL = URL(string: "https://glizzyattheturn.app/bluffcitycup/schedule_api.php")!
    private let upsertURL = URL(string: "https://glizzyattheturn.app/bluffcitycup/update_schedule_event.php")!
    private let deleteURL = URL(string: "https://glizzyattheturn.app/bluffcitycup/delete_schedule_event.php")!
    private let decoder = JSONDecoder()
    private var cachedPayloads: [String: SchedulePayload] = [:]

    private init() {}

    func fetchSchedule(tournamentName: String, forceRefresh: Bool = false, completion: @escaping (SchedulePayload?, Error?) -> Void) {
        let cacheKey = tournamentName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !forceRefresh, let payload = cachedPayloads[cacheKey] {
            completion(payload, nil)
            return
        }

        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            completion(nil, ScheduleAPIError.invalidURL)
            return
        }

        components.queryItems = [URLQueryItem(name: "tournament", value: cacheKey)]
        guard let url = components.url else {
            completion(nil, ScheduleAPIError.invalidURL)
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 20

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async { completion(nil, ScheduleAPIError.invalidResponse) }
                return
            }

            do {
                let payload = try self?.decoder.decode(SchedulePayload.self, from: data)
                guard let decodedPayload = payload, decodedPayload.success else {
                    DispatchQueue.main.async { completion(nil, ScheduleAPIError.serverError("Schedule API returned an unsuccessful response.")) }
                    return
                }

                self?.cachedPayloads[cacheKey] = decodedPayload
                DispatchQueue.main.async { completion(decodedPayload, nil) }
            } catch {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }.resume()
    }

    func saveEvent(_ draft: ScheduleEventDraft, completion: @escaping (Bool, Error?) -> Void) {
        requestStatus(url: upsertURL, queryItems: draft.queryItems) { [weak self] success, error in
            if success {
                self?.invalidate(tournamentName: draft.tournament)
                NotificationCenter.default.post(name: .bccScheduleEventsDidChange, object: nil, userInfo: ["tournamentName": draft.tournament])
            }
            completion(success, error)
        }
    }

    func deleteEvent(id: String, tournamentName: String, completion: @escaping (Bool, Error?) -> Void) {
        requestStatus(url: deleteURL, queryItems: [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "tournament", value: tournamentName)
        ]) { [weak self] success, error in
            if success {
                self?.invalidate(tournamentName: tournamentName)
                NotificationCenter.default.post(name: .bccScheduleEventsDidChange, object: nil, userInfo: ["tournamentName": tournamentName])
            }
            completion(success, error)
        }
    }

    func invalidate(tournamentName: String) {
        cachedPayloads.removeValue(forKey: tournamentName.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func requestStatus(url: URL, queryItems: [URLQueryItem], completion: @escaping (Bool, Error?) -> Void) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(false, ScheduleAPIError.invalidURL)
            return
        }

        components.queryItems = queryItems
        guard let requestURL = components.url else {
            completion(false, ScheduleAPIError.invalidURL)
            return
        }

        var request = URLRequest(url: requestURL)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 20

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(false, error) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async { completion(false, ScheduleAPIError.invalidResponse) }
                return
            }

            let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            DispatchQueue.main.async {
                completion(text == "OK", text == "OK" ? nil : ScheduleAPIError.serverError(text.isEmpty ? "Schedule update failed." : text))
            }
        }.resume()
    }
}
