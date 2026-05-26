import SwiftUI

// MARK: - Steps

private enum OnboardingStep: Int, CaseIterable {
    case plan
    case pack
    case start

    var headline: String {
        switch self {
        case .plan: return "Plan Your Trip"
        case .pack: return "Pack Smartly"
        case .start: return "Get Started Now"
        }
    }

    var description: String {
        switch self {
        case .plan:
            return "Explore destinations and curate your personal travel wishlist."
        case .pack:
            return "Create and manage packing checklists for your upcoming adventures."
        case .start:
            return "Add your first destination to start planning your next journey."
        }
    }

    var illustration: HomeIllustration {
        switch self {
        case .plan: return .hero
        case .pack: return .hiking
        case .start: return .city
        }
    }

    var icon: String {
        switch self {
        case .plan: return "map.fill"
        case .pack: return "suitcase.fill"
        case .start: return "location.north.circle.fill"
        }
    }

    var highlights: [(icon: String, label: String)] {
        switch self {
        case .plan:
            return [
                ("heart.fill", "Wishlist"),
                ("globe.europe.africa.fill", "Countries"),
                ("calendar", "Dates")
            ]
        case .pack:
            return [
                ("checklist", "Checklists"),
                ("tag.fill", "Categories"),
                ("chart.bar.fill", "Progress")
            ]
        case .start:
            return [
                ("plus.circle.fill", "Add trip"),
                ("clock.fill", "World time"),
                ("star.fill", "Badges")
            ]
        }
    }
}

// MARK: - Root

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0

    private var steps: [OnboardingStep] { OnboardingStep.allCases }
    private var currentStep: OnboardingStep { steps[currentPage] }

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        OnboardingPageView(step: step, isActive: index == currentPage)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: currentPage)

                footerControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color("AppAccent"))
                Text("Your travel hub")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Text("\(currentPage + 1) / \(steps.count)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .travelInsetPanel(cornerRadius: 20)
        }
    }

    private var footerControls: some View {
        VStack(spacing: 20) {
            progressBar
            pageIndicator

            Button(buttonTitle) {
                FeedbackManager.lightTap()
                if currentPage < steps.count - 1 {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        currentPage += 1
                    }
                } else {
                    FeedbackManager.mediumAction()
                    store.completeOnboarding()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.top, 8)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color("AppBackground").opacity(0.5))
                Capsule()
                    .fill(TravelVisualStyle.progressGradient)
                    .frame(width: geo.size.width * progressFraction)
            }
        }
        .frame(height: 6)
        .animation(.easeInOut(duration: 0.35), value: currentPage)
    }

    private var progressFraction: CGFloat {
        CGFloat(currentPage + 1) / CGFloat(steps.count)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentPage
                            ? AnyShapeStyle(TravelVisualStyle.primaryButtonGradient)
                            : AnyShapeStyle(Color("AppTextSecondary").opacity(0.35))
                    )
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentPage)
    }

    private var buttonTitle: String {
        currentPage < steps.count - 1 ? "Next" : "Get Started"
    }
}

// MARK: - Page

private struct OnboardingPageView: View {
    let step: OnboardingStep
    let isActive: Bool

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 16) {
            OnboardingHeroCard(step: step)
                .scaleEffect(appeared ? 1 : 0.94)
                .opacity(appeared ? 1 : 0.6)

            featureChips
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .onAppear {
            guard isActive else { return }
            playEntrance()
        }
        .onChange(of: isActive) { active in
            if active { playEntrance() }
        }
    }

    private var featureChips: some View {
        HStack(spacing: 10) {
            ForEach(Array(step.highlights.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 6) {
                    Image(systemName: item.icon)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                    Text(item.label)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .travelInsetPanel(cornerRadius: 12)
            }
        }
    }

    private func playEntrance() {
        appeared = false
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            appeared = true
        }
    }
}

// MARK: - Hero card

private struct OnboardingHeroCard: View {
    let step: OnboardingStep

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                IllustrationHeader(illustration: step.illustration, height: 200)

                HStack(alignment: .bottom) {
                    TravelIconBadge(systemImage: step.icon, size: 52, style: .accent)
                    Spacer()
                }
                .padding(14)
            }

            VStack(spacing: 14) {
                Text(step.headline)
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(step.description)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .travelElevatedPanel(cornerRadius: 22, accent: true, elevation: .hero)
    }
}
