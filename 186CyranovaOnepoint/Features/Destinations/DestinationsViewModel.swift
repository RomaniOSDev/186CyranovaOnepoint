import Combine
import Foundation

@MainActor
final class DestinationsViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var editingDestination: Destination?
    @Published var pulsingDestinationID: UUID?
    @Published var showSuccessCheckmark = false

    func openAdd() {
        editingDestination = nil
        showingAddSheet = true
    }

    func openEdit(_ destination: Destination) {
        editingDestination = destination
        showingAddSheet = true
    }

    func triggerRowPulse(for id: UUID) {
        pulsingDestinationID = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.pulsingDestinationID = nil
        }
    }

    func triggerSuccessFeedback() {
        FeedbackManager.mediumAction()
        showSuccessCheckmark = true
    }
}
