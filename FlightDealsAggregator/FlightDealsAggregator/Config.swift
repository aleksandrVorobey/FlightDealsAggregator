//
//  Config.swift
//  FlightDealsAggregator
//
//  Centralized configuration and API key access
//

import Foundation

protocol APIKeyProvider {
    func value(for key: String) -> String?
}

struct InfoPlistAPIKeyProvider: APIKeyProvider {
    func value(for key: String) -> String? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
}

enum AppConfig {
    static let travelpayoutsAPIKeyInfoPlistKey = "TRAVELPAYOUTS_API_KEY"

    private static var keyProvider: APIKeyProvider = InfoPlistAPIKeyProvider()

    static func setAPIKeyProvider(_ provider: APIKeyProvider) {
        keyProvider = provider
    }

    static func travelpayoutsAPIKey() -> String? {
        if let fromPlist = keyProvider.value(for: travelpayoutsAPIKeyInfoPlistKey)?.trimmingCharacters(in: .whitespacesAndNewlines), !fromPlist.isEmpty {
            return fromPlist
        }
        // API key.
        return ""
    }
}


