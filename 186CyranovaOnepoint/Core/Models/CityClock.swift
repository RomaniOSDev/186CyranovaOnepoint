import Foundation

struct CityClock: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var timeZoneIdentifier: String
    var tripId: UUID?

    init(id: UUID = UUID(), name: String, timeZoneIdentifier: String, tripId: UUID? = nil) {
        self.id = id
        self.name = name
        self.timeZoneIdentifier = timeZoneIdentifier
        self.tripId = tripId
    }

    var timeZone: TimeZone? {
        TimeZone(identifier: timeZoneIdentifier)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, timeZoneIdentifier, tripId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        timeZoneIdentifier = try container.decode(String.self, forKey: .timeZoneIdentifier)
        tripId = try container.decodeIfPresent(UUID.self, forKey: .tripId)
    }
}

struct PresetCity: Identifiable {
    let id = UUID()
    let name: String
    let timeZoneIdentifier: String
}

enum PresetCities {
    static let all: [PresetCity] = [
        PresetCity(name: "London", timeZoneIdentifier: "Europe/London"),
        PresetCity(name: "Paris", timeZoneIdentifier: "Europe/Paris"),
        PresetCity(name: "New York", timeZoneIdentifier: "America/New_York"),
        PresetCity(name: "Tokyo", timeZoneIdentifier: "Asia/Tokyo"),
        PresetCity(name: "Sydney", timeZoneIdentifier: "Australia/Sydney"),
        PresetCity(name: "Dubai", timeZoneIdentifier: "Asia/Dubai"),
        PresetCity(name: "Singapore", timeZoneIdentifier: "Asia/Singapore"),
        PresetCity(name: "Los Angeles", timeZoneIdentifier: "America/Los_Angeles")
    ]
}
