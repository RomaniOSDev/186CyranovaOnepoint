import SwiftUI

struct DestinationCompareView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIds: Set<UUID> = []

    private var candidates: [Destination] {
        store.destinations.filter { !$0.isVisited }
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    TravelCard {
                        Text("Select up to 3 destinations to compare side by side.")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    ForEach(candidates) { destination in
                        Button {
                            FeedbackManager.lightTap()
                            toggle(destination.id)
                        } label: {
                            TravelCard(accent: selectedIds.contains(destination.id)) {
                                HStack(spacing: 14) {
                                    DestinationListCell(destination: destination, showsChevron: false)
                                    Image(systemName: selectedIds.contains(destination.id) ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(
                                            selectedIds.contains(destination.id) ? Color("AppPrimary") : Color("AppTextSecondary")
                                        )
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    if selectedIds.count >= 2 {
                        comparisonTable
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .travelScreenStyle()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    FeedbackManager.lightTap()
                    dismiss()
                }
                .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .preferredColorScheme(.dark)
    }

    private var comparisonTable: some View {
        let items = store.compareDestinations(ids: Array(selectedIds).prefix(3).map(\.self))
        return TravelCard(accent: true) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Comparison")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                comparisonRow("Budget", values: items.map { $0.estimatedBudget > 0 ? "$\(Int($0.estimatedBudget))" : "—" })
                comparisonRow("Season", values: items.map { $0.preferredSeason.isEmpty ? "—" : $0.preferredSeason })
                comparisonRow("Duration", values: items.map { "\($0.durationDays)d" })
                comparisonRow("Departure", values: items.map { $0.plannedDate.formatted(date: .abbreviated, time: .omitted) })
                comparisonRow("Type", values: items.map { $0.tripType })
            }
        }
    }

    private func comparisonRow(_ title: String, values: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppAccent"))
            HStack(alignment: .top, spacing: 8) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                    Text(value)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .travelInsetPanel(cornerRadius: 8)
                }
            }
        }
    }

    private func toggle(_ id: UUID) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else if selectedIds.count < 3 {
            selectedIds.insert(id)
        } else {
            FeedbackManager.warning()
        }
    }
}
