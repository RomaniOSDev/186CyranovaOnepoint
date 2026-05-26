import SwiftUI

struct JetLagCalculatorView: View {
    @State private var hourDifference = 6

    private var result: (days: Int, hoursPerDay: Int, direction: String) {
        let absHours = abs(hourDifference)
        let days = max(1, min(7, Int(ceil(Double(absHours) / 2.0))))
        let hoursPerDay = max(1, absHours / days)
        let direction = hourDifference >= 0 ? "Advance bedtime gradually" : "Delay bedtime gradually"
        return (days, hoursPerDay, direction)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
                VStack(spacing: 16) {
                    TravelCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                TravelIconBadge(systemImage: "bed.double.fill", size: 48, style: .primary)
                                Text("Adjust your sleep schedule after crossing time zones.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            Stepper("Difference: \(signedHours) hours", value: $hourDifference, in: -12...12)
                                .onChange(of: hourDifference) { _ in FeedbackManager.lightTap() }
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }

                    TravelCard(accent: true) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Suggested Plan")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            planRow("Duration", "\(result.days) day(s)")
                            planRow("Daily shift", "\(result.hoursPerDay) hour(s) per day")
                            planRow("Strategy", result.direction)
                            Text("Start adjusting 2–3 nights before departure.")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Jet Lag Helper")
        .navigationBarTitleDisplayMode(.inline)
        .travelScreenStyle()
        .preferredColorScheme(.dark)
    }

    private var signedHours: String {
        hourDifference >= 0 ? "+\(hourDifference)" : "\(hourDifference)"
    }

    private func planRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
                .multilineTextAlignment(.trailing)
        }
    }
}
