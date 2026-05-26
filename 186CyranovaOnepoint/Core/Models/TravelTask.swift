import Foundation

enum ChecklistType: String, Codable, CaseIterable {
    case packing = "Packing"
    case itinerary = "Itinerary"
}

enum TaskSortOrder: String, CaseIterable {
    case name = "Name"
    case status = "Status"
}

struct TravelTask: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var completedAt: Date?
    var category: String
    var checklistType: String
    var sortOrder: Int
    var tripId: UUID?

    init(
        id: UUID = UUID(),
        title: String = "",
        completedAt: Date? = nil,
        category: String = "Clothes",
        checklistType: String = ChecklistType.packing.rawValue,
        sortOrder: Int = 0,
        tripId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.completedAt = completedAt
        self.category = category
        self.checklistType = checklistType
        self.sortOrder = sortOrder
        self.tripId = tripId
    }

    var isCompleted: Bool { completedAt != nil }

    enum CodingKeys: String, CodingKey {
        case id, title, completedAt, category, checklistType, sortOrder, tripId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        category = try container.decode(String.self, forKey: .category)
        checklistType = try container.decode(String.self, forKey: .checklistType)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        tripId = try container.decodeIfPresent(UUID.self, forKey: .tripId)
    }
}
