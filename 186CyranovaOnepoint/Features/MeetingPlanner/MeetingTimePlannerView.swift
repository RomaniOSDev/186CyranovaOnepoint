import SwiftUI

struct MeetingTimePlannerView: View {
    @EnvironmentObject private var store: AppDataStore

    @State private var sourceClockId: UUID?
    @State private var targetClockId: UUID?
    @State private var hour = 10
    @State private var minute = 0

    private var clocks: [CityClock] { store.clocksForMeetingPlanner() }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    if clocks.count < 2 {
                        TravelCard {
                            TravelEmptyState(
                                icon: "person.2.fill",
                                title: "Need more cities",
                                message: "Add at least two cities in World Time to plan meetings across zones."
                            )
                        }
                    } else {
                        TravelCard {
                            VStack(spacing: 14) {
                                clockPicker("When it's this time in…", selection: $sourceClockId)
                                clockPicker("It will be this time in…", selection: $targetClockId)
                            }
                        }
                        TravelCard {
                            timePickerSection
                        }
                        resultSection
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Meeting Planner")
        .navigationBarTitleDisplayMode(.inline)
        .travelScreenStyle()
        .onAppear {
            if sourceClockId == nil { sourceClockId = clocks.first?.id }
            if targetClockId == nil { targetClockId = clocks.dropFirst().first?.id }
        }
        .preferredColorScheme(.dark)
    }

    private func clockPicker(_ title: String, selection: Binding<UUID?>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
            Picker(title, selection: Binding(
                get: { selection.wrappedValue ?? clocks.first?.id ?? UUID() },
                set: { selection.wrappedValue = $0 }
            )) {
                ForEach(clocks) { clock in
                    Text(clock.name).tag(clock.id)
                }
            }
            .pickerStyle(.menu)
            .tint(Color("AppPrimary"))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .travelInsetPanel(cornerRadius: 10)
        }
    }

    private var timePickerSection: some View {
        VStack(spacing: 10) {
            Text("Select source time")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
            HStack {
                Picker("Hour", selection: $hour) {
                    ForEach(0..<24, id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: 90, height: 110)
                Text(":")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Picker("Minute", selection: $minute) {
                    ForEach([0, 15, 30, 45], id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                }
                .pickerStyle(.wheel)
                .frame(width: 90, height: 110)
            }
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if let source = clocks.first(where: { $0.id == sourceClockId }),
           let target = clocks.first(where: { $0.id == targetClockId }) {
            let result = store.formattedTimeInTarget(hour: hour, minute: minute, from: source, to: target)
            TravelCard(accent: true) {
                VStack(spacing: 10) {
                    Text(String(format: "%02d:%02d in %@", hour, minute, source.name))
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(result)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppAccent"))
                        .monospacedDigit()
                    Text("in \(target.name)")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
