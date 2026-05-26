import Foundation

enum TripMood: String, CaseIterable, Identifiable, Codable {
    case amazing = "🤩"
    case happy = "😊"
    case calm = "😐"
    case tired = "😴"
    case sad = "😢"

    var id: String { rawValue }
}

struct DiaryEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var tripId: UUID
    var date: Date
    var mood: String
    var text: String

    init(
        id: UUID = UUID(),
        tripId: UUID,
        date: Date = Date(),
        mood: String = TripMood.happy.rawValue,
        text: String = ""
    ) {
        self.id = id
        self.tripId = tripId
        self.date = date
        self.mood = mood
        self.text = text
    }
}
