import Foundation

enum TripType: String, Codable, CaseIterable, Identifiable {
    case beach = "Beach"
    case city = "City"
    case business = "Business"
    case hiking = "Hiking"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .beach: return "sun.max.fill"
        case .city: return "building.2.fill"
        case .business: return "briefcase.fill"
        case .hiking: return "figure.hiking"
        }
    }
}
