import Foundation

struct Destination: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var country: String
    var plannedDate: Date
    var notes: String
    var isVisited: Bool
    var tripType: String
    var estimatedBudget: Double
    var preferredSeason: String
    var durationDays: Int
    var tripId: UUID?

    init(
        id: UUID = UUID(),
        name: String = "",
        country: String = "",
        plannedDate: Date = Date(),
        notes: String = "",
        isVisited: Bool = false,
        tripType: String = TripType.city.rawValue,
        estimatedBudget: Double = 0,
        preferredSeason: String = "",
        durationDays: Int = 7,
        tripId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.plannedDate = plannedDate
        self.notes = notes
        self.isVisited = isVisited
        self.tripType = tripType
        self.estimatedBudget = estimatedBudget
        self.preferredSeason = preferredSeason
        self.durationDays = durationDays
        self.tripId = tripId
    }

    enum CodingKeys: String, CodingKey {
        case id, name, country, plannedDate, notes, isVisited
        case tripType, estimatedBudget, preferredSeason, durationDays, tripId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
        plannedDate = try container.decode(Date.self, forKey: .plannedDate)
        notes = try container.decode(String.self, forKey: .notes)
        isVisited = try container.decode(Bool.self, forKey: .isVisited)
        tripType = try container.decodeIfPresent(String.self, forKey: .tripType) ?? TripType.city.rawValue
        estimatedBudget = try container.decodeIfPresent(Double.self, forKey: .estimatedBudget) ?? 0
        preferredSeason = try container.decodeIfPresent(String.self, forKey: .preferredSeason) ?? ""
        durationDays = try container.decodeIfPresent(Int.self, forKey: .durationDays) ?? 7
        tripId = try container.decodeIfPresent(UUID.self, forKey: .tripId)
    }
}
