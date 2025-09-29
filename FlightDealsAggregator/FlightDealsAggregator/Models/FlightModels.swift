//
//  FlightModels.swift
//  FlightDealsAggregator
//

import Foundation

// MARK: - Domain Models

struct Flight: Identifiable, Hashable, Codable {
    let id: String
    let airlineCode: String
    let origin: String
    let destination: String
    let departureDate: Date
    let returnDate: Date?
    let price: Decimal
    let currency: String
}

// MARK: - API DTOs for v1/prices/cheap (exact schema per provided example)

struct APIResponseDTO: Decodable {
    let success: Bool
    let data: [String: [String: FlightDataDTO]]?
    let error: String?
}

struct FlightDataDTO: Decodable {
    let price: Double
    let airline: String
    let flightNumber: Int
    let departureAt: String
    let returnAt: String?
    let expiresAt: String

    private enum CodingKeys: String, CodingKey {
        case price
        case airline
        case flightNumber = "flight_number"
        case departureAt = "departure_at"
        case returnAt = "return_at"
        case expiresAt = "expires_at"
    }
}

// MARK: - Mapping

enum FlightMapper {
    static func mapAPIResponse(origin: String, currency: String, dto: APIResponseDTO) -> [Flight] {
        guard dto.success, let data = dto.data else { return [] }
        var flights: [Flight] = []
        for (destination, flightsMap) in data {
            for (_, item) in flightsMap {
                let depDate = parseAPIDate(item.departureAt) ?? Date()
                let retDate = parseAPIDate(item.returnAt)
                let priceDecimal = Decimal(item.price)
                let id = [origin, destination, String(item.flightNumber), item.departureAt].joined(separator: "-")
                let flight = Flight(
                    id: id,
                    airlineCode: item.airline,
                    origin: origin,
                    destination: destination,
                    departureDate: depDate,
                    returnDate: retDate,
                    price: priceDecimal,
                    currency: currency
                )
                flights.append(flight)
            }
        }
        return flights.sorted { $0.price < $1.price }
    }

    private static func parseAPIDate(_ string: String?) -> Date? {
        guard let string else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }

    private static func parseYYYYMMDD(_ string: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df.date(from: string)
    }
}


