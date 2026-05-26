import Foundation

enum PackingTemplates {
    static func tasks(for type: TripType, tripId: UUID) -> [TravelTask] {
        let items = templateItems[type] ?? []
        return items.enumerated().map { index, item in
            TravelTask(
                title: item.title,
                category: item.category,
                checklistType: ChecklistType.packing.rawValue,
                sortOrder: index,
                tripId: tripId
            )
        }
    }

    private static let templateItems: [TripType: [(title: String, category: String)]] = [
        .beach: [
            ("Swimsuit", "Clothes"), ("Sunscreen SPF 50", "Toiletries"), ("Sandals", "Clothes"),
            ("Beach towel", "Misc"), ("Sunglasses", "Misc"), ("Snorkel mask", "Misc"),
            ("Light cover-up", "Clothes"), ("After-sun lotion", "Toiletries"), ("Water bottle", "Misc"),
            ("Passport copy", "Documents")
        ],
        .city: [
            ("Comfortable walking shoes", "Clothes"), ("Day backpack", "Misc"), ("Power bank", "Electronics"),
            ("Universal adapter", "Electronics"), ("City map offline", "Misc"), ("Light jacket", "Clothes"),
            ("Transit card", "Documents"), ("Reusable water bottle", "Misc"), ("Camera / phone", "Electronics"),
            ("Local currency cash", "Misc")
        ],
        .business: [
            ("Business attire", "Clothes"), ("Laptop + charger", "Electronics"), ("Presentation materials", "Documents"),
            ("Business cards", "Documents"), ("Portable steamer", "Misc"), ("Notebook", "Misc"),
            ("Formal shoes", "Clothes"), ("Toiletry kit", "Toiletries"), ("Noise-canceling earbuds", "Electronics"),
            ("Meeting itinerary", "Documents")
        ],
        .hiking: [
            ("Hiking boots", "Clothes"), ("Moisture-wicking layers", "Clothes"), ("Rain jacket", "Clothes"),
            ("Trekking poles", "Misc"), ("First aid kit", "Misc"), ("Headlamp", "Electronics"),
            ("Trail snacks", "Misc"), ("Water filtration", "Misc"), ("Bug repellent", "Toiletries"),
            ("National park permit", "Documents")
        ]
    ]
}
