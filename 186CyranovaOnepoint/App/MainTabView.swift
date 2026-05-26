import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case plan
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .plan: return "Plan"
        case .achievements: return "Badges"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .plan: return "suitcase.fill"
        case .achievements: return "star.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedTab: MainTab = .home
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()

            VStack(spacing: 0) {
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                customTabBar
            }

            if let banner = store.pendingAchievementBanner {
                AchievementBannerView(achievement: banner) {
                    store.dismissAchievementBanner()
                }
                .zIndex(10)
            }
        }
        .onAppear {
            store.evaluateAchievements()
            store.startSessionTimer(isActive: scenePhase == .active)
        }
        .onChange(of: scenePhase) { phase in
            store.startSessionTimer(isActive: phase == .active)
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView()
                .environmentObject(store)
        case .plan:
            NavigationStack {
                PlanHubView()
                    .environmentObject(store)
            }
            .background(Color.clear)
        case .achievements:
            AchievementsView()
                .environmentObject(store)
        case .settings:
            SettingsView()
                .environmentObject(store)
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(TravelVisualStyle.surfaceGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(TravelVisualStyle.shineGradient)
                .opacity(0.35)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color("AppTextPrimary").opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color("AppBackground").opacity(0.32), radius: 8, y: -2)
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            FeedbackManager.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: isSelected ? 22 : 20, weight: .semibold))
                Text(tab.title)
                    .font(.caption2.weight(isSelected ? .bold : .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(TravelVisualStyle.primaryButtonGradient)
                    }
                }
            )
            .shadow(
                color: isSelected ? Color("AppBackground").opacity(0.28) : Color.clear,
                radius: isSelected ? 4 : 0,
                y: isSelected ? 2 : 0
            )
            .scaleEffect(isSelected ? 1 : 0.96)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 52)
    }
}
