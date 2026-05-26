import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        summaryCard
                        TravelSectionHeader(title: "Badges", action: nil, actionHandler: nil)
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(AchievementCatalog.all) { achievement in
                                AchievementGridCell(
                                    achievement: achievement,
                                    isUnlocked: achievement.isUnlocked(store: store)
                                )
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Badges")
            .navigationBarTitleDisplayMode(.inline)
            .travelScreenStyle()
        }
        .preferredColorScheme(.dark)
    }

    private var summaryCard: some View {
        TravelCard(accent: true) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    TravelIconBadge(systemImage: "star.fill", size: 48, style: .primary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Progress")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("\(unlockedCount) of \(AchievementCatalog.all.count) unlocked")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                TravelProgressBar(progress: Double(unlockedCount) / Double(AchievementCatalog.all.count))
                HStack(spacing: 8) {
                    TravelMetricTile(icon: "globe", label: "Places", value: "\(store.destinations.count)")
                    TravelMetricTile(icon: "flame.fill", label: "Streak", value: "\(store.streakDays)d")
                    TravelMetricTile(icon: "figure.walk", label: "Sessions", value: "\(store.totalSessionsCompleted)")
                }
            }
        }
    }

    private var unlockedCount: Int {
        AchievementCatalog.all.filter { $0.isUnlocked(store: store) }.count
    }
}
