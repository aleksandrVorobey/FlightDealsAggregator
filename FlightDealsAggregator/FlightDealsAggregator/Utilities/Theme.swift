//
//  Theme.swift
//  FlightDealsAggregator
//

import SwiftUI

enum PriceTier: Int, Comparable {
    case low
    case medium
    case high

    static func < (lhs: PriceTier, rhs: PriceTier) -> Bool { lhs.rawValue < rhs.rawValue }
}

enum Theme {
    static func tier(for price: Decimal) -> PriceTier {
        if price < 100 { return .low }
        if price < 300 { return .medium }
        return .high
    }

    static func color(for tier: PriceTier) -> Color {
        switch tier {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}


