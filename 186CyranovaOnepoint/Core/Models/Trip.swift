import Foundation

struct Trip: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var destinationId: UUID
    var title: String
    var notes: String
    var createdAt: Date
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        destinationId: UUID,
        title: String,
        notes: String = "",
        createdAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.destinationId = destinationId
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.isArchived = isArchived
    }
}
