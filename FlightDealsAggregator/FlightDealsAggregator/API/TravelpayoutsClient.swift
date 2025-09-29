//
//  TravelpayoutsClient.swift
//  FlightDealsAggregator
//

import Foundation

final class TravelpayoutsClient {
    struct Configuration {
        let baseURL: URL
        let apiKey: String
        let session: URLSession
    }

    enum ClientError: Error {
        case missingAPIKey
        case invalidURL
        case httpStatus(Int)
        case decoding(Error)
        case transport(Error)
    }

    private let config: Configuration

    init(config: Configuration) {
        self.config = config
    }

    convenience init?() {
        guard let apiKey = AppConfig.travelpayoutsAPIKey(), !apiKey.isEmpty,
              let baseURL = URL(string: "https://api.travelpayouts.com") else {
            return nil
        }
        let session = URLSession(configuration: .default)
        self.init(config: .init(baseURL: baseURL, apiKey: apiKey, session: session))
    }

    // MARK: - Public API
    func fetchCheapPrices(origin: String,
                          destination: String,
                          currency: String = "RUB",
                          departureDate: Date?) async throws -> Data {
        let path = "/v1/prices/cheap"
        var components = URLComponents(url: config.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        var query: [URLQueryItem] = [
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination),
            URLQueryItem(name: "currency", value: currency)
        ]
        if let departureDate = departureDate {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            query.append(URLQueryItem(name: "depart_date", value: df.string(from: departureDate)))
        }
        components?.queryItems = query

        guard let url = components?.url else { throw ClientError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(config.apiKey, forHTTPHeaderField: "X-Access-Token")

        do {
            let (data, response) = try await config.session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw ClientError.invalidURL }
            guard (200..<300).contains(http.statusCode) else { throw ClientError.httpStatus(http.statusCode) }
            return data
        } catch let error as ClientError {
            throw error
        } catch {
            throw ClientError.transport(error)
        }
    }
}


