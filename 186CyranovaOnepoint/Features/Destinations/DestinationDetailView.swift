import SwiftUI

struct DestinationDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    let destination: Destination
    let onVisited: () -> Void

    @State private var showEdit = false

    private var current: Destination {
        store.destinations.first(where: { $0.id == destination.id }) ?? destination
    }

    private var trip: Trip? { store.trip(for: current) }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 14) {
                    TravelCard {
                        DestinationListCell(
                            destination: current,
                            packingPercent: trip.map { store.packingProgressPercent(for: $0.id) },
                            showsChevron: false
                        )
                    }

                    if let trip {
                        TravelCard {
                            HStack(spacing: 8) {
                                TravelProgressBar(progress: store.packingProgress(for: trip.id))
                                Text("\(store.packingProgressPercent(for: trip.id))%")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color("AppAccent"))
                            }
                        }
                    }

                    TravelCard {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            infoTile("Type", current.tripType)
                            infoTile("Duration", "\(current.durationDays) days")
                            if current.estimatedBudget > 0 {
                                infoTile("Budget", "$\(Int(current.estimatedBudget))")
                            }
                            if !current.preferredSeason.isEmpty {
                                infoTile("Season", current.preferredSeason)
                            }
                        }
                    }

                    if !current.notes.isEmpty {
                        TravelCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Notes")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color("AppAccent"))
                                Text(current.notes)
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                    }

                    TravelCard {
                        HStack {
                            Image(systemName: current.isVisited ? "checkmark.seal.fill" : "circle")
                                .foregroundStyle(current.isVisited ? Color("AppAccent") : Color("AppTextSecondary"))
                            Text(current.isVisited ? "Visited" : "Not yet visited")
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer()
                        }
                    }

                    if !current.isVisited {
                        Button("Mark as Visited") {
                            store.markDestinationVisited(id: current.id)
                            onVisited()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 4)
                    }

                    actionLinks
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.large)
        .travelScreenStyle()
        .navigationDestination(for: Trip.self) { trip in
            TripDetailView(trip: trip)
                .environmentObject(store)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    FeedbackManager.lightTap()
                    showEdit = true
                }
                .foregroundStyle(Color("AppPrimary"))
            }
        }
        .sheet(isPresented: $showEdit) {
            DestinationFormView(existing: current) {
                FeedbackManager.mediumAction()
            }
            .environmentObject(store)
        }
        .preferredColorScheme(.dark)
    }

    private func infoTile(_ title: String, _ value: String) -> some View {
        TravelInsetCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actionLinks: some View {
        VStack(spacing: 10) {
            NavigationLink {
                CountryBriefView(country: current.country)
                    .environmentObject(store)
            } label: {
                TravelCard {
                    TravelListCell(icon: "book.fill", title: "Country Brief", subtitle: "Currency, tips & phrases", badgeStyle: .primary)
                }
            }
            .buttonStyle(.plain)

            if let trip {
                NavigationLink(value: trip) {
                    TravelCard {
                        TravelListCell(icon: "folder.fill", title: "Trip Project", subtitle: "Full trip hub", badgeStyle: .accent)
                    }
                }
                .buttonStyle(.plain)

                if current.isVisited {
                    NavigationLink {
                        TripDiaryView(trip: trip)
                            .environmentObject(store)
                    } label: {
                        TravelCard {
                            TravelListCell(icon: "book.closed.fill", title: "Trip Diary", subtitle: "Write your memories", badgeStyle: .primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
