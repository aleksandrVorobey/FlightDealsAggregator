//
//  FlightsRepository.swift
//  FlightDealsAggregator
//

import Foundation

protocol FlightsRepositoryType {
    func fetchDeals(origin: String, destination: String?, currency: String, date: Date?) async throws -> [Flight]
}

final class FlightsRepository: FlightsRepositoryType {
    private struct CacheKey: Hashable { let origin: String; let destination: String; let currency: String; let dateKey: String }
    private struct CacheEntry { let timestamp: Date; let flights: [Flight] }

    private let client: TravelpayoutsClient
    private var cache: [CacheKey: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 60

    init(client: TravelpayoutsClient) { self.client = client }

    func fetchDeals(origin: String, destination: String?, currency: String, date: Date?) async throws -> [Flight] {
        let destinationParam = (destination?.isEmpty ?? true) ? "-" : destination!.uppercased()
        let originParam = origin.uppercased()
        let dateKey: String = {
            guard let date else { return "" }
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            return df.string(from: date)
        }()
        let key = CacheKey(origin: originParam, destination: destinationParam, currency: currency.uppercased(), dateKey: dateKey)
        if let entry = cache[key], Date().timeIntervalSince(entry.timestamp) < cacheTTL {
            return Self.filter(entry.flights, destination: destination)
        }

        let data = try await client.fetchCheapPrices(origin: originParam, destination: destinationParam, currency: currency.uppercased(), departureDate: date)
        let dto = try JSONDecoder().decode(APIResponseDTO.self, from: data)
        let mapped = FlightMapper.mapAPIResponse(origin: originParam, currency: currency.uppercased(), dto: dto)
        cache[key] = CacheEntry(timestamp: Date(), flights: mapped)
        return Self.filter(mapped, destination: destination)
    }

    private static func filter(_ flights: [Flight], destination: String?) -> [Flight] {
        guard let destination, !destination.isEmpty else { return flights }
        return flights.filter { $0.destination == destination.uppercased() }
    }
}


