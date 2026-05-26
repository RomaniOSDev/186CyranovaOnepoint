import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    func isUnlocked(store: AppDataStore) -> Bool {
        store.achievementsUnlocked[id] != nil
    }

    func meetsCondition(store: AppDataStore) -> Bool {
        switch id {
        case "first_destination":
            return store.destinationsAdded >= 1
        case "packing_pro":
            return store.checklistsCompleted >= 3
        case "travel_enthusiast":
            return store.destinationsAdded >= 10
        case "language_learner":
            return store.phrasesViewed >= 5
        case "power_user":
            return store.destinationsAdded >= 50
        case "active_user":
            return store.totalSessionsCompleted >= 10
        case "dedicated_user":
            return store.totalSessionsCompleted >= 50
        case "three_day_streak":
            return store.streakDays >= 3
        default:
            return false
        }
    }
}

enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_destination",
            title: "First Destination",
            description: "Added your first destination to the wishlist.",
            systemImage: "mappin.and.ellipse"
        ),
        AchievementDefinition(
            id: "packing_pro",
            title: "Packing Pro",
            description: "Completed three packing checklists.",
            systemImage: "suitcase.fill"
        ),
        AchievementDefinition(
            id: "travel_enthusiast",
            title: "Travel Enthusiast",
            description: "Added ten destinations to your wishlist.",
            systemImage: "globe.americas.fill"
        ),
        AchievementDefinition(
            id: "language_learner",
            title: "Language Learner",
            description: "Viewed five essential phrases.",
            systemImage: "text.bubble.fill"
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 items.",
            systemImage: "star.fill"
        ),
        AchievementDefinition(
            id: "active_user",
            title: "Active User",
            description: "Completed 10 sessions.",
            systemImage: "figure.walk"
        ),
        AchievementDefinition(
            id: "dedicated_user",
            title: "Dedicated User",
            description: "Completed 50 sessions.",
            systemImage: "medal.fill"
        ),
        AchievementDefinition(
            id: "three_day_streak",
            title: "Three-Day Streak",
            description: "Used the app 3 days in a row.",
            systemImage: "flame.fill"
        )
    ]
}
