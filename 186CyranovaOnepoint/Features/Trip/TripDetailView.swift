import SwiftUI

struct TripDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    let trip: Trip

    @State private var notes: String = ""

    private var destination: Destination? { store.destination(for: trip) }
    private var currentTrip: Trip { store.trips.first(where: { $0.id == trip.id }) ?? trip }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if let destination {
                        TravelCard(accent: true) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Trip Overview")
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                TravelProgressBar(progress: store.packingProgress(for: trip.id))
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    TravelMetricTile(icon: "calendar", label: "Departure", value: destination.plannedDate.formatted(date: .abbreviated, time: .omitted))
                                    TravelMetricTile(icon: "clock", label: "Duration", value: "\(destination.durationDays)d")
                                    TravelMetricTile(icon: "sun.max", label: "Season", value: destination.preferredSeason.isEmpty ? "Any" : destination.preferredSeason)
                                    TravelMetricTile(icon: "dollarsign.circle", label: "Budget", value: destination.estimatedBudget > 0 ? "$\(Int(destination.estimatedBudget))" : "—")
                                }
                            }
                        }
                    }

                    TravelCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Trip Notes")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            TextField("Add notes for this trip…", text: $notes, axis: .vertical)
                                .lineLimit(3...8)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .onChange(of: notes) { newValue in
                                    store.updateTripNotes(tripId: trip.id, notes: newValue)
                                }
                        }
                    }

                    linksSection
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(currentTrip.title)
        .navigationBarTitleDisplayMode(.large)
        .travelScreenStyle()
        .onAppear {
            notes = currentTrip.notes
            if store.activeTripId != trip.id {
                store.setActiveTrip(trip.id)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var linksSection: some View {
        VStack(spacing: 10) {
            if let destination {
                NavigationLink {
                    CountryBriefView(country: destination.country)
                        .environmentObject(store)
                } label: {
                    TravelCard {
                        TravelListCell(icon: "book.fill", title: "Country Brief", subtitle: destination.country, badgeStyle: .primary)
                    }
                }
                .buttonStyle(.plain)
            }
            NavigationLink {
                TripDiaryView(trip: currentTrip)
                    .environmentObject(store)
            } label: {
                TravelCard {
                    TravelListCell(icon: "book.closed.fill", title: "Trip Diary", subtitle: "Text memories & mood", badgeStyle: .accent)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
