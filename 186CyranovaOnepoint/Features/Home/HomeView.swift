import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = DestinationsViewModel()
    @State private var showCompare = false
    @State private var showDocuments = false

    private let widgetColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        dashboardHeader

                        ActiveTripHeroWidget()
                            .environmentObject(store)
                            .padding(.horizontal, 16)

                        widgetGrid
                            .padding(.horizontal, 16)

                        if !store.expiringDocuments.isEmpty {
                            DocumentsAlertWidget(count: store.expiringDocuments.count) {
                                showDocuments = true
                            }
                            .padding(.horizontal, 16)
                        }

                        quickActionsSection
                            .padding(.horizontal, 16)

                        destinationsSection
                    }
                    .padding(.bottom, 96)
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingAddButton { viewModel.openAdd() }
                            .padding(.trailing, 20)
                            .padding(.bottom, 16)
                    }
                }

                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .travelScreenStyle()
            .navigationDestination(for: Destination.self) { destination in
                DestinationDetailView(destination: destination) {
                    viewModel.triggerSuccessFeedback()
                    viewModel.triggerRowPulse(for: destination.id)
                }
                .environmentObject(store)
            }
            .navigationDestination(for: Trip.self) { trip in
                TripDetailView(trip: trip)
                    .environmentObject(store)
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                DestinationFormView(existing: viewModel.editingDestination) {
                    viewModel.triggerSuccessFeedback()
                    if let last = store.destinations.last {
                        viewModel.triggerRowPulse(for: last.id)
                    }
                }
                .environmentObject(store)
            }
            .sheet(isPresented: $showCompare) {
                NavigationStack {
                    DestinationCompareView()
                        .environmentObject(store)
                }
            }
            .sheet(isPresented: $showDocuments) {
                NavigationStack {
                    TravelDocumentsView()
                        .environmentObject(store)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Dashboard

    private var dashboardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Your travel dashboard")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Menu {
                Button("Compare Destinations") { showCompare = true }
                Button("Travel Documents") { showDocuments = true }
            } label: {
                TravelIconBadge(systemImage: "ellipsis.circle.fill", size: 40, style: .primary)
            }
            .onTapGesture { FeedbackManager.lightTap() }
        }
        .padding(.horizontal, 16)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    private var widgetGrid: some View {
        LazyVGrid(columns: widgetColumns, spacing: 12) {
            packingWidget
            destinationsCountWidget
            streakWidget
            sessionsWidget
            WorldClockMiniWidget()
                .environmentObject(store)
            phrasesWidget
        }
    }

    @ViewBuilder
    private var packingWidget: some View {
        if let trip = store.activeTrip {
            HomeStatWidget(
                illustration: .beach,
                icon: "suitcase.fill",
                title: "Packing",
                value: "\(store.packingProgressPercent(for: trip.id))%",
                subtitle: "Ready for departure",
                accent: store.packingProgress(for: trip.id) >= 1
            )
        } else {
            HomeStatWidget(
                illustration: .beach,
                icon: "suitcase.fill",
                title: "Packing",
                value: "0%",
                subtitle: "Start a trip first"
            )
        }
    }

    private var destinationsCountWidget: some View {
        HomeStatWidget(
            illustration: .hero,
            icon: "globe.europe.africa.fill",
            title: "Wishlist",
            value: "\(store.destinations.count)",
            subtitle: "\(store.destinations.filter { $0.isVisited }.count) visited"
        )
    }

    private var streakWidget: some View {
        HomeStatWidget(
            illustration: .hiking,
            icon: "flame.fill",
            title: "Streak",
            value: "\(store.streakDays)",
            subtitle: store.streakDays > 0 ? "Days in a row" : "Use app daily",
            accent: store.streakDays >= 3
        )
    }

    private var sessionsWidget: some View {
        HomeStatWidget(
            illustration: .city,
            icon: "figure.walk",
            title: "Sessions",
            value: "\(store.totalSessionsCompleted)",
            subtitle: "\(store.totalMinutesUsed) min total"
        )
    }

    private var phrasesWidget: some View {
        HomeStatWidget(
            illustration: nil,
            icon: "text.bubble.fill",
            title: "Phrases",
            value: "\(store.phrasesViewed)",
            subtitle: "Phrases learned"
        )
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            TravelSectionHeader(title: "Quick Actions", action: nil, actionHandler: nil)
            HStack(spacing: 10) {
                QuickActionWidget(
                    illustration: .city,
                    title: "Compare",
                    subtitle: "Pick your next trip"
                ) { showCompare = true }
                QuickActionWidget(
                    illustration: .hiking,
                    title: "Documents",
                    subtitle: "Passport & visa dates"
                ) { showDocuments = true }
            }
        }
    }

    private var destinationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TravelSectionHeader(
                title: "Your Destinations",
                action: store.destinations.isEmpty ? nil : "See all",
                actionHandler: nil
            )

            if store.destinations.isEmpty {
                VStack(spacing: 0) {
                    IllustrationHeader(illustration: .hero, height: 120)
                    TravelEmptyState(
                        icon: "plus.circle.fill",
                        title: "No destinations yet",
                        message: "Tap + to add your first dream destination.",
                        buttonTitle: "Add Destination",
                        action: { viewModel.openAdd() }
                    )
                    .padding(.bottom, 16)
                }
                .travelElevatedPanel(cornerRadius: 20, elevation: .medium)
            } else {
                ForEach(store.destinations.prefix(6)) { destination in
                    destinationWidgetLink(destination)
                }
                if store.destinations.count > 6 {
                    Text("+ \(store.destinations.count - 6) more in your wishlist")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func destinationWidgetLink(_ destination: Destination) -> some View {
        let packing = destination.tripId.map { store.packingProgressPercent(for: $0) }
        let isActive = store.activeTrip?.destinationId == destination.id
        return NavigationLink(value: destination) {
            DestinationWidgetCard(
                destination: destination,
                packingPercent: destination.isVisited ? nil : packing,
                isActive: isActive
            )
        }
        .buttonStyle(.plain)
        .rowPulse(viewModel.pulsingDestinationID == destination.id)
        .contextMenu {
            Button { viewModel.openEdit(destination) } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                store.deleteDestination(id: destination.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
