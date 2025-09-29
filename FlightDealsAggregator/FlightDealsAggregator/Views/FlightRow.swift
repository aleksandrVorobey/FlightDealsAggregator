//
//  File.swift
//  FlightDealsAggregator
//
//  Created by Александр Воробей on 29.09.2025.
//

import SwiftUI

 struct FlightRow: View {
    let flight: Flight?

    init(flight: Flight) { self.flight = flight }
    private init() { self.flight = nil }

    static var skeleton: some View { FlightRow() }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(colorTag)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(priceText)
                .font(.headline)
        }
        .padding(.vertical, 8)
    }

    private var colorTag: Color {
        guard let flight else { return .gray.opacity(0.3) }
        let tier = Theme.tier(for: flight.price)
        return Theme.color(for: tier)
    }

    private var title: String {
        guard let f = flight else { return "XXX → YYY" }
        return "\(f.origin) → \(f.destination)"
    }

    private var subtitle: String {
        guard let f = flight else { return "SU · 2025-01-01" }
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        let date = df.string(from: f.departureDate)
        return "\(f.airlineCode) · \(date)"
    }

    private var priceText: String {
        guard let f = flight else { return "$---" }
        let ns = NSDecimalNumber(decimal: f.price)
        return "\(f.currency.uppercased()) \(ns)"
    }
}
