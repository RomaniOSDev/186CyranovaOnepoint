import Foundation

struct CountryBrief: Codable, Equatable {
    let country: String
    let currency: String
    let exchangeRateUSD: Double
    let tipping: String
    let power: String
    let voltage: String
    let emergency: String
    let phrases: [String]
    let timeZoneIdentifier: String?
}

enum CountryBriefService {
    private static let cache: [CountryBrief] = loadAll()

    static func brief(for country: String) -> CountryBrief? {
        let normalized = country.trimmingCharacters(in: .whitespaces).lowercased()
        return cache.first { $0.country.lowercased() == normalized }
    }

    static func allCountries() -> [String] {
        cache.map(\.country).sorted()
    }

    static func loadAll() -> [CountryBrief] {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let briefs = try? JSONDecoder().decode([CountryBrief].self, from: data) else {
            return fallback
        }
        return briefs
    }

    private static let fallback: [CountryBrief] = [
        CountryBrief(
            country: "France",
            currency: "Euro (EUR)",
            exchangeRateUSD: 1.08,
            tipping: "Service included; round up 5–10% for great service.",
            power: "Type C / E",
            voltage: "230V",
            emergency: "112",
            phrases: ["Bonjour", "Merci", "L'addition, s'il vous plaît", "Où est la gare?", "Parlez-vous anglais?"],
            timeZoneIdentifier: "Europe/Paris"
        )
    ]
}
