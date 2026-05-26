import Combine
import Foundation

@MainActor
final class TravelOrganizerViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var sortOrder: TaskSortOrder = .name
    @Published var pulsingTaskID: UUID?
    @Published var expandedCategories: Set<String> = []

    func toggleCategory(_ category: String) {
        FeedbackManager.lightTap()
        if expandedCategories.contains(category) {
            expandedCategories.remove(category)
        } else {
            expandedCategories.insert(category)
        }
    }

    func ensureExpanded(_ categories: [String]) {
        if expandedCategories.isEmpty {
            expandedCategories = Set(categories)
        }
    }

    func triggerTaskAnimation(id: UUID) {
        pulsingTaskID = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.pulsingTaskID = nil
        }
    }

    func sortedTasks(_ tasks: [TravelTask]) -> [TravelTask] {
        switch sortOrder {
        case .name:
            return tasks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .status:
            return tasks.sorted {
                if $0.isCompleted != $1.isCompleted { return !$0.isCompleted && $1.isCompleted }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        }
    }
}
