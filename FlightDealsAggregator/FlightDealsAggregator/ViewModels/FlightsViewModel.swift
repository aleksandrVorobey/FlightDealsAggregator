//
//  FlightsViewModel.swift
//  FlightDealsAggregator
//

import Foundation
import Observation

@Observable
final class FlightsViewModel {
    // Inputs
    var origin: String = "MOW"
    var destination: String? = nil
    var currency: String = "RUB"
    var date: Date? = nil

    // Outputs
    private(set) var flights: [Flight] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil

    private let repository: FlightsRepositoryType

    init?(client: TravelpayoutsClient? = TravelpayoutsClient()) {
        guard let client else { return nil }
        self.repository = FlightsRepository(client: client)
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let result = try await repository.fetchDeals(origin: origin, destination: destination, currency: currency, date: date)
            flights = result
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }
}


