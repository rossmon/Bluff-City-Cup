//
//  RecordsAPIService.swift
//  Bluff City Cup
//

import Foundation

enum RecordsAPIError: Error {
    case invalidResponse
    case serverError(String)
}

final class RecordsAPIService {
    static let shared = RecordsAPIService()

    private let recordsURL = URL(string: "https://glizzyattheturn.app/bluffcitycup/api.php")!
    private let decoder = JSONDecoder()
    private var cachedPayload: RecordsPayload?

    private init() {}

    func fetchRecords(forceRefresh: Bool = false, completion: @escaping (RecordsPayload?, Error?) -> Void) {
        if !forceRefresh, let payload = cachedPayload {
            completion(payload, nil)
            return
        }

        var request = URLRequest(url: recordsURL)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async { completion(nil, RecordsAPIError.invalidResponse) }
                return
            }

            do {
                let payload = try self?.decoder.decode(RecordsPayload.self, from: data)
                guard let decodedPayload = payload, decodedPayload.success else {
                    DispatchQueue.main.async { completion(nil, RecordsAPIError.serverError("Records API returned an unsuccessful response.")) }
                    return
                }

                self?.cachedPayload = decodedPayload
                DispatchQueue.main.async { completion(decodedPayload, nil) }
            } catch {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }.resume()
    }
}
