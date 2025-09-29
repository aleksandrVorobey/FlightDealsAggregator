//
//  FlightDetailsView.swift
//  FlightDealsAggregator
//

import SwiftUI

struct FlightDetailsView: View {
    let flight: Flight

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                priceCard
                meta
            }
            .padding()
        }
        .navigationTitle("\(flight.origin) → \(flight.destination)")
        .navigationBarTitleDisplayMode(.inline)
        .background(gradient)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "airplane")
                .font(.title2)
                .foregroundStyle(.white)
                .padding(8)
                .background(circleColor, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("Airline: \(flight.airlineCode)")
                    .font(.headline)
                Text(dateText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var priceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(priceText)
                .font(.largeTitle.weight(.bold))
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let returnDate = flight.returnDate {
                Text("Return: \(format(date: returnDate))")
            }
            Text("Currency: \(flight.currency.uppercased())")
            Text("Route: \(flight.origin) - \(flight.destination)")
        }
        .padding()
        .background(Color.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
    }

    private var priceText: String {
        let ns = NSDecimalNumber(decimal: flight.price)
        return "\(flight.currency.uppercased()) \(ns)"
    }

    private var dateText: String {
        format(date: flight.departureDate)
    }

    private func format(date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }

    private var circleColor: Color { tierColor }

    private var gradient: some View {
        LinearGradient(colors: [tierColor.opacity(0.12), .clear], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }

    private var tierColor: Color {
        Theme.color(for: Theme.tier(for: flight.price))
    }
}

#Preview {
    let sample = Flight(id: "1", airlineCode: "SU", origin: "MOW", destination: "DXB", departureDate: Date(), returnDate: nil, price: 199, currency: "usd")
    NavigationStack { FlightDetailsView(flight: sample) }
}


