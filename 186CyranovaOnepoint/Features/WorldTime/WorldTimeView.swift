import SwiftUI

struct WorldTimeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = WorldTimeViewModel()

    private var isActive: Bool { scenePhase == .active }

    var body: some View {
        ZStack {
            AppBackgroundView()
            if store.worldClocks.isEmpty {
                TravelEmptyState(
                    icon: "globe",
                    title: "No clocks yet",
                    message: "Tap + to add your first city and track time abroad.",
                    buttonTitle: "Add City",
                    action: { viewModel.showingAddSheet = true }
                )
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.worldClocks) { clock in
                            TravelCard(accent: isActive) {
                                WorldClockCell(clock: clock, isLive: isActive)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    store.deleteWorldClock(id: clock.id)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("World Time")
        .travelScreenStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    FeedbackManager.lightTap()
                    viewModel.showingAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            AddCityClockView {
                FeedbackManager.softSuccess()
            }
            .environmentObject(store)
        }
        .preferredColorScheme(.dark)
    }
}
