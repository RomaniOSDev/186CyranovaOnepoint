import Foundation

enum DocumentType: String, Codable, CaseIterable, Identifiable {
    case passport = "Passport"
    case visa = "Visa"
    case insurance = "Insurance"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .passport: return "person.text.rectangle.fill"
        case .visa: return "doc.text.fill"
        case .insurance: return "cross.case.fill"
        }
    }
}

struct TravelDocument: Identifiable, Codable, Equatable {
    var id: UUID
    var type: DocumentType
    var expiryDate: Date
    var notes: String

    init(
        id: UUID = UUID(),
        type: DocumentType,
        expiryDate: Date,
        notes: String = ""
    ) {
        self.id = id
        self.type = type
        self.expiryDate = expiryDate
        self.notes = notes
    }

    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: expiryDate)).day ?? 0
    }

    var isExpiringSoon: Bool {
        daysUntilExpiry >= 0 && daysUntilExpiry <= 30
    }

    var isExpired: Bool {
        daysUntilExpiry < 0
    }
}
