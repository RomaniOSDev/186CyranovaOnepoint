import Combine
import Foundation

@MainActor
final class WorldTimeViewModel: ObservableObject {
    @Published var showingAddSheet = false
}
