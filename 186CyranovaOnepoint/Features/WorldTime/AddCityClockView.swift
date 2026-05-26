import SwiftUI

struct AddCityClockView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let onAdded: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(PresetCities.all) { city in
                            Button {
                                addCity(city)
                            } label: {
                                TravelCard {
                                    HStack(spacing: 14) {
                                        TravelIconBadge(systemImage: "building.2.fill", style: .primary)
                                        Text(city.name)
                                            .font(.headline)
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        if store.worldClocks.contains(where: { $0.timeZoneIdentifier == city.timeZoneIdentifier }) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color("AppAccent"))
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add City")
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
        }
        .preferredColorScheme(.dark)
    }

    private func addCity(_ preset: PresetCity) {
        guard !store.worldClocks.contains(where: { $0.timeZoneIdentifier == preset.timeZoneIdentifier }) else {
            FeedbackManager.warning()
            return
        }
        let clock = CityClock(name: preset.name, timeZoneIdentifier: preset.timeZoneIdentifier)
        store.addWorldClock(clock)
        FeedbackManager.softSuccess()
        onAdded()
        dismiss()
    }
}
