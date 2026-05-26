import SwiftUI

// MARK: - Card shell

struct TravelCard<Content: View>: View {
    var accent: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .travelElevatedPanel(
                cornerRadius: 16,
                accent: accent,
                elevation: accent ? .high : .medium
            )
    }
}

struct TravelInsetCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(12)
            .travelInsetPanel(cornerRadius: 12)
    }
}

// MARK: - Icon badge

struct TravelIconBadge: View {
    let systemImage: String
    var size: CGFloat = 44
    var style: BadgeStyle = .primary

    enum BadgeStyle {
        case primary, accent, muted
    }

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(iconColor)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [backgroundColor, Color("AppBackground").opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Circle()
                    .stroke(Color("AppTextPrimary").opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color("AppBackground").opacity(0.2), radius: 2, y: 1)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return Color("AppPrimary").opacity(0.25)
        case .accent: return Color("AppAccent").opacity(0.22)
        case .muted: return Color("AppBackground").opacity(0.55)
        }
    }

    private var iconColor: Color {
        switch style {
        case .primary: return Color("AppPrimary")
        case .accent: return Color("AppAccent")
        case .muted: return Color("AppTextSecondary")
        }
    }
}

// MARK: - Progress

struct TravelProgressBar: View {
    let progress: Double
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color("AppBackground").opacity(0.5))
                Capsule()
                    .fill(TravelVisualStyle.progressGradient)
                    .frame(width: max(0, geo.size.width * min(1, max(0, progress))))
            }
        }
        .frame(height: height)
    }
}

// MARK: - Section & empty state

struct TravelSectionHeader: View {
    let title: String
    var action: String?
    var actionHandler: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            if let action, let actionHandler {
                Button(action) {
                    FeedbackManager.lightTap()
                    actionHandler()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppPrimary"))
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}

struct TravelEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            TravelIconBadge(systemImage: icon, size: 72, style: .primary)
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
            if let buttonTitle, let action {
                Button(buttonTitle, action: {
                    FeedbackManager.lightTap()
                    action()
                })
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Generic list cell

struct TravelListCell: View {
    let icon: String
    let title: String
    var subtitle: String?
    var detail: String?
    var badge: String?
    var badgeStyle: TravelIconBadge.BadgeStyle = .accent
    var showsChevron: Bool = true
    var trailingIcon: String?

    var body: some View {
        HStack(spacing: 14) {
            TravelIconBadge(systemImage: icon, style: badgeStyle)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }
            Spacer(minLength: 8)
            if let badge {
                Text(badge)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .travelTagCapsule()
            }
            if let detail {
                Text(detail)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                    .monospacedDigit()
            }
            if let trailingIcon {
                Image(systemName: trailingIcon)
                    .foregroundStyle(Color("AppAccent"))
            }
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.8))
            }
        }
    }
}

struct TravelMetricTile: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .travelInsetPanel(cornerRadius: 12)
    }
}

// MARK: - Feature cells

struct DestinationListCell: View {
    let destination: Destination
    var packingPercent: Int?
    var showsChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            TravelIconBadge(
                systemImage: TripType(rawValue: destination.tripType)?.systemImage ?? "mappin.circle.fill",
                style: destination.isVisited ? .muted : .primary
            )
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(destination.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if destination.isVisited {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                Text(destination.country)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                HStack(spacing: 8) {
                    Text(destination.plannedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                    if destination.estimatedBudget > 0 {
                        Label("$\(Int(destination.estimatedBudget))", systemImage: "dollarsign.circle")
                            .font(.caption2)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                if let packingPercent, !destination.isVisited {
                    HStack(spacing: 8) {
                        TravelProgressBar(progress: Double(packingPercent) / 100, height: 6)
                            .frame(maxWidth: 120)
                        Text("\(packingPercent)% packed")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
            }
            Spacer(minLength: 0)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.8))
            }
        }
    }
}

struct PlanToolCell: View {
    let tool: PlanTool

    var body: some View {
        TravelListCell(
            icon: tool.icon,
            title: tool.rawValue,
            subtitle: tool.subtitle,
            badgeStyle: .primary,
            showsChevron: true
        )
    }
}

extension PlanTool {
    var subtitle: String {
        switch self {
        case .organizer: return "Packing & itinerary for your active trip"
        case .worldTime: return "Live clocks across cities"
        case .meetingPlanner: return "Convert meeting times between zones"
        case .phrases: return "Essential phrases for travelers"
        case .jetLag: return "Sleep schedule adjustment plan"
        }
    }
}

struct TaskListCell: View {
    let task: TravelTask
    var isPulsing: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(task.isCompleted ? Color("AppAccent") : Color("AppTextSecondary"))
                .scaleEffect(isPulsing ? 0.88 : 1)
                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isPulsing)
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(task.isCompleted ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .strikethrough(task.isCompleted)
                    .lineLimit(2)
                Text(task.category)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary").opacity(0.5))
        }
        .padding(.vertical, 4)
    }
}

struct WorldClockCell: View {
    let clock: CityClock
    var isLive: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            TravelIconBadge(systemImage: "clock.fill", size: 52, style: .accent)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(clock.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    if isLive {
                        Circle()
                            .fill(Color("AppAccent"))
                            .frame(width: 6, height: 6)
                    }
                }
                if isLive, let tz = clock.timeZone {
                    TravelLiveClockLabel(
                        timeZone: tz,
                        showsSeconds: true,
                        font: .system(size: 28, weight: .bold, design: .rounded)
                    )
                } else {
                    Text(staticTime)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppAccent"))
                        .monospacedDigit()
                }
                Text(offsetLabel)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
        }
    }

    private var staticTime: String {
        guard let tz = clock.timeZone else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeZone = tz
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private var offsetLabel: String {
        guard let tz = clock.timeZone else { return "GMT" }
        let offset = tz.secondsFromGMT(for: Date()) / 3600
        return String(format: "GMT%+d", offset)
    }
}

struct DocumentListCell: View {
    let document: TravelDocument

    var body: some View {
        HStack(spacing: 14) {
            TravelIconBadge(
                systemImage: document.type.systemImage,
                style: document.isExpired || document.isExpiringSoon ? .accent : .primary
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(document.type.rawValue)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(document.expiryDate.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                statusLabel
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var statusLabel: some View {
        if document.isExpired {
            Text("Expired")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.red)
                .travelTagCapsule(top: Color.red.opacity(0.35), bottom: Color.red.opacity(0.15))
        } else if document.isExpiringSoon {
            Text("\(document.daysUntilExpiry) days left")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .travelTagCapsule(
                    top: Color("AppAccent").opacity(0.45),
                    bottom: Color("AppAccent").opacity(0.22)
                )
        }
    }
}

struct PhraseListCell: View {
    let english: String
    let translation: String
    let language: String
    let isViewed: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            TravelIconBadge(systemImage: "text.bubble.fill", style: isViewed ? .muted : .primary)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(english)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    if isViewed {
                        Image(systemName: "eye.fill")
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                if !translation.isEmpty {
                    Text(translation)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppAccent"))
                }
                Text(language)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }
}

struct AchievementGridCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isUnlocked
                                ? [Color("AppPrimary").opacity(0.35), Color("AppAccent").opacity(0.15)]
                                : [Color("AppBackground").opacity(0.6), Color("AppSurface").opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle().stroke(Color("AppTextPrimary").opacity(0.08), lineWidth: 1)
                    )
                Image(systemName: achievement.systemImage)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.6))
            }
            Text(achievement.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
            if isUnlocked {
                Text("Unlocked")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .travelTagCapsule(
                        top: Color("AppAccent").opacity(0.5),
                        bottom: Color("AppAccent").opacity(0.25)
                    )
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 168)
        .travelElevatedPanel(
            cornerRadius: 16,
            accent: isUnlocked,
            elevation: isUnlocked ? .medium : .low
        )
        .opacity(isUnlocked ? 1 : 0.88)
    }
}

struct SettingsActionCell: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false

    var body: some View {
        TravelListCell(
            icon: icon,
            title: title,
            badgeStyle: isDestructive ? .muted : .primary,
            showsChevron: !isDestructive
        )
        .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))
    }
}

// MARK: - List helpers

extension View {
    func travelListRow() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    func travelScreenStyle() -> some View {
        self
            .toolbarBackground(TravelVisualStyle.navBarGradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}
