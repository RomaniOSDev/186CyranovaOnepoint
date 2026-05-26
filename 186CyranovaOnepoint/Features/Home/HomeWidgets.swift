import SwiftUI

// MARK: - Hero widget

struct ActiveTripHeroWidget: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        if let trip = store.activeTrip, let destination = store.destination(for: trip) {
            NavigationLink(value: trip) {
                heroContent(trip: trip, destination: destination)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded { FeedbackManager.lightTap() })
        } else {
            emptyHero
        }
    }

    private func heroContent(trip: Trip, destination: Destination) -> some View {
        let illustration = HomeIllustration.forTripType(destination.tripType)
        return VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                IllustrationHeader(illustration: illustration, height: 160)
                VStack(alignment: .leading, spacing: 4) {
                    Text("ACTIVE TRIP")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(Color("AppAccent"))
                    Text(destination.name)
                        .font(.title.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(destination.country)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(14)
            }
            heroDetails(trip: trip, destination: destination)
        }
        .travelElevatedPanel(cornerRadius: 20, accent: true, elevation: .hero)
    }

    private func heroDetails(trip: Trip, destination: Destination) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TravelProgressBar(progress: store.packingProgress(for: trip.id))
            HStack {
                Text("Packing")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Spacer()
                Text("\(store.packingProgressPercent(for: trip.id))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
            }
            HStack(spacing: 8) {
                miniStat(
                    icon: "calendar",
                    value: countdownValue(for: trip),
                    label: countdownLabel(for: trip)
                )
                miniStat(
                    icon: "clock.fill",
                    value: store.timeZoneOffsetLabel(for: trip.id) ?? "—",
                    label: "Zone"
                )
                miniStat(icon: "suitcase.fill", value: "\(destination.durationDays)d", label: "Trip")
            }
            Text("Open Trip Project →")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(TravelVisualStyle.primaryButtonGradient)
                )
                .shadow(color: Color("AppBackground").opacity(0.25), radius: 4, y: 2)
        }
        .padding(14)
    }

    private var emptyHero: some View {
        VStack(spacing: 0) {
            IllustrationHeader(illustration: .hero, height: 140)
            VStack(spacing: 12) {
                Text("Plan your next adventure")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Add a destination to unlock trip widgets and packing tracking.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
            }
            .padding(16)
        }
        .travelElevatedPanel(cornerRadius: 20, elevation: .medium)
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color("AppAccent"))
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .travelInsetPanel(cornerRadius: 10)
    }

    private func countdownLabel(for trip: Trip) -> String {
        guard let days = store.daysUntilDeparture(for: trip) else { return "Status" }
        if days > 0 { return "Depart" }
        if days == 0 { return "Today" }
        return "Started"
    }

    private func countdownValue(for trip: Trip) -> String {
        guard let days = store.daysUntilDeparture(for: trip) else { return "—" }
        if days > 0 { return "\(days)d" }
        if days == 0 { return "Now" }
        return "\(abs(days))d"
    }
}

// MARK: - Small widgets

struct HomeStatWidget: View {
    let illustration: HomeIllustration?
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    var accent: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let illustration {
                HomeIllustrationImage(illustration: illustration, height: 56)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                    Text(title)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, minHeight: illustration == nil ? 110 : 150, alignment: .leading)
        .travelElevatedPanel(cornerRadius: 16, accent: accent, elevation: accent ? .medium : .low)
    }
}

struct DocumentsAlertWidget: View {
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            onTap()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    HomeIllustrationImage(illustration: .city, height: 52)
                        .frame(width: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(Color("AppPrimary"))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Documents")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text("\(count) need attention")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Tap to review expiry dates")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppAccent"))
            }
            .padding(12)
            .travelElevatedPanel(cornerRadius: 16, accent: true, elevation: .medium)
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionWidget: View {
    let illustration: HomeIllustration
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                HomeIllustrationImage(illustration: illustration, height: 64)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                }
                .padding(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .travelElevatedPanel(cornerRadius: 14, elevation: .low)
        }
        .buttonStyle(.plain)
    }
}

struct DestinationWidgetCard: View {
    let destination: Destination
    let packingPercent: Int?
    let isActive: Bool

    var body: some View {
        VStack(spacing: 0) {
            HomeIllustrationImage(
                illustration: HomeIllustration.forTripType(destination.tripType),
                height: 72
            )
            .overlay(alignment: .topTrailing) {
                if destination.isVisited {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color("AppAccent"))
                        .padding(8)
                }
            }
            DestinationListCell(
                destination: destination,
                packingPercent: packingPercent,
                showsChevron: true
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .travelElevatedPanel(cornerRadius: 16, accent: isActive, elevation: isActive ? .medium : .low)
    }
}

struct WorldClockMiniWidget: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        if let clock = store.worldClocks.first, let tz = clock.timeZone {
            VStack(alignment: .leading, spacing: 0) {
                HomeIllustrationImage(illustration: .city, height: 56)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                        Text(clock.name)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    TravelLiveClockLabel(
                        timeZone: tz,
                        showsSeconds: false,
                        font: .title2.bold()
                    )
                    Text("World clock")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .padding(12)
            }
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .travelElevatedPanel(cornerRadius: 16, elevation: .low)
        } else {
            HomeStatWidget(
                illustration: nil,
                icon: "globe",
                title: "World Time",
                value: "—",
                subtitle: "Add a city clock"
            )
        }
    }
}
